from django.contrib import admin
from .models import Product


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('title', 'crop_type', 'quantity_kg', 'price_per_kg', 'region', 'status', 'farmer')
    list_filter = ('crop_type', 'status', 'region')
    search_fields = ('title', 'farmer__username')