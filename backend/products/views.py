from rest_framework import generics, permissions
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .models import Product
from .serializers import ProductSerializer


class ProductListCreateView(generics.ListCreateAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_queryset(self):
        queryset = Product.objects.all().order_by('-created_at')
        crop = self.request.query_params.get('crop')
        region = self.request.query_params.get('region')
        min_qty = self.request.query_params.get('min_qty')
        max_price = self.request.query_params.get('max_price')
        if crop:
            queryset = queryset.filter(crop_type=crop)
        if region:
            queryset = queryset.filter(region__icontains=region)
        if min_qty:
            queryset = queryset.filter(quantity_kg__gte=min_qty)
        if max_price:
            queryset = queryset.filter(price_per_kg__lte=max_price)
        return queryset

    def perform_create(self, serializer):
        serializer.save(farmer=self.request.user)

    def get_serializer_context(self):
        return {'request': self.request}


class MyProductsView(generics.ListAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Product.objects.filter(farmer=self.request.user).order_by('-created_at')

    def get_serializer_context(self):
        return {'request': self.request}


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Product.objects.all()
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_serializer_context(self):
        return {'request': self.request}


# NEW: Admin-only view to see all products
class AdminProductListView(generics.ListAPIView):
    queryset = Product.objects.all().order_by('-created_at')
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAdminUser]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_serializer_context(self):
        return {'request': self.request}