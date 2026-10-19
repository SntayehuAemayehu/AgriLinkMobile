from django.contrib import admin
from .models import TransportRequest


@admin.register(TransportRequest)
class TransportRequestAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'requester', 'transporter', 'status', 'pickup_location', 'dropoff_location')
    list_filter = ('status',)