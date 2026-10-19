from rest_framework import generics, permissions
from .models import MarketPrice
from .serializers import MarketPriceSerializer


class PriceListView(generics.ListCreateAPIView):
    queryset = MarketPrice.objects.all()
    serializer_class = MarketPriceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = MarketPrice.objects.all()
        crop = self.request.query_params.get('crop')
        region = self.request.query_params.get('region')
        if crop:
            qs = qs.filter(crop_type=crop)
        if region:
            qs = qs.filter(region__icontains=region)
        return qs[:50]