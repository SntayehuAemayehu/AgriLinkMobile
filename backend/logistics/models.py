from django.db import models
from django.conf import settings
from orders.models import Order


class TransportRequest(models.Model):
    STATUS_CHOICES = (
        ('open', 'Open'), ('accepted', 'Accepted'), ('in_transit', 'In Transit'),
        ('delivered', 'Delivered'), ('cancelled', 'Cancelled'),
    )
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='transports')
    requester = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='transport_requests')
    transporter = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='transport_jobs')
    pickup_location = models.CharField(max_length=200)
    dropoff_location = models.CharField(max_length=200)
    price_etb = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='open')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Transport #{self.id} - {self.status}"