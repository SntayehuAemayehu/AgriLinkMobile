from django.contrib import admin
from .models import Order, Rating


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'buyer', 'product', 'quantity_kg', 'total_price', 'status', 'payment_status', 'delivery_status')
    list_filter = ('status', 'payment_status', 'delivery_status')


@admin.register(Rating)
class RatingAdmin(admin.ModelAdmin):
    list_display = ('order', 'rater', 'ratee', 'stars', 'created_at')
    list_filter = ('stars',)