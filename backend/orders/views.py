from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Order, Rating
from .serializers import OrderSerializer, RatingSerializer
from accounts.sms_service import (
    notify_farmer_new_order,
    notify_buyer_order_accepted,
    notify_buyer_payment_confirmed,
)


class CreateOrderView(generics.CreateAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        order = serializer.save(buyer=self.request.user)
        try:
            notify_farmer_new_order(order)
        except Exception as e:
            print(f"SMS error: {e}")

    def get_serializer_context(self):
        return {'request': self.request}


class MyOrdersView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(buyer=self.request.user).order_by('-created_at')

    def get_serializer_context(self):
        return {'request': self.request}


class FarmerOrdersView(generics.ListAPIView):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(product__farmer=self.request.user).order_by('-created_at')

    def get_serializer_context(self):
        return {'request': self.request}


class UpdateOrderStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        try:
            order = Order.objects.get(pk=pk)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found'}, status=404)

        if order.product.farmer == request.user:
            new_status = request.data.get('status')
            if new_status in ['accepted', 'rejected', 'completed', 'cancelled']:
                old_status = order.status
                order.status = new_status
                if new_status == 'completed':
                    order.product.status = 'sold'
                    order.product.save()
                order.save()
                if new_status == 'accepted' and old_status == 'pending':
                    try:
                        notify_buyer_order_accepted(order)
                    except Exception as e:
                        print(f"SMS error: {e}")

        payment = request.data.get('payment_status')
        if payment:
            if payment == 'buyer_marked_paid' and order.buyer == request.user:
                order.payment_status = 'buyer_marked_paid'
            elif payment == 'farmer_confirmed' and order.product.farmer == request.user:
                order.payment_status = 'farmer_confirmed'
                try:
                    notify_buyer_payment_confirmed(order)
                except Exception as e:
                    print(f"SMS error: {e}")
            elif payment == 'disputed':
                order.payment_status = 'disputed'
            order.save()

        delivery = request.data.get('delivery_status')
        if delivery:
            order.delivery_status = delivery
            order.save()

        return Response(OrderSerializer(order, context={'request': request}).data)


class CreateRatingView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        order_id = request.data.get('order')
        stars = request.data.get('stars')
        comment = request.data.get('comment', '')
        if not order_id or not stars:
            return Response({'error': 'order and stars required'}, status=400)
        try:
            order = Order.objects.get(pk=order_id)
        except Order.DoesNotExist:
            return Response({'error': 'Order not found'}, status=404)
        if order.status != 'completed':
            return Response({'error': 'Order not completed'}, status=400)

        if request.user == order.buyer:
            ratee = order.product.farmer
        elif request.user == order.product.farmer:
            ratee = order.buyer
        else:
            return Response({'error': 'Not allowed'}, status=403)

        if Rating.objects.filter(order=order, rater=request.user).exists():
            return Response({'error': 'Already rated'}, status=400)

        rating = Rating.objects.create(
            order=order, rater=request.user, ratee=ratee,
            stars=int(stars), comment=comment,
        )
        return Response(RatingSerializer(rating).data, status=201)