from django.contrib import admin
from .models import MarketPrice


@admin.register(MarketPrice)
class MarketPriceAdmin(admin.ModelAdmin):
    list_display = ('crop_type', 'region', 'price_per_kg', 'date')
    list_filter = ('crop_type', 'region')