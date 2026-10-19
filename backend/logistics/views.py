from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import TransportRequest
from .serializers import TransportSerializer


class CreateTransportView(generics.CreateAPIView):
    serializer_class = TransportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(requester=self.request.user)


class OpenTransportsView(generics.ListAPIView):
    serializer_class = TransportSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = TransportRequest.objects.filter(status='open').order_by('-created_at')


class MyTransportsView(generics.ListAPIView):
    serializer_class = TransportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return TransportRequest.objects.filter(requester=self.request.user).order_by('-created_at')


class MyJobsView(generics.ListAPIView):
    serializer_class = TransportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return TransportRequest.objects.filter(transporter=self.request.user).order_by('-created_at')


class AcceptTransportView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            t = TransportRequest.objects.get(pk=pk, status='open')
        except TransportRequest.DoesNotExist:
            return Response({'error': 'Not found or already accepted'}, status=404)
        t.transporter = request.user
        t.status = 'accepted'
        t.save()
        return Response(TransportSerializer(t).data)


class UpdateTransportStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        try:
            t = TransportRequest.objects.get(pk=pk, transporter=request.user)
        except TransportRequest.DoesNotExist:
            return Response({'error': 'Not found'}, status=404)
        new_status = request.data.get('status')
        if new_status in ['in_transit', 'delivered', 'cancelled']:
            t.status = new_status
            t.save()
        return Response(TransportSerializer(t).data)