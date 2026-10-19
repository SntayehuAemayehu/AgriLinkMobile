from decimal import Decimal
from django.db import models
from django.conf import settings
from products.models import Product
from settings_app.models import SystemSetting


class Order(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'), ('accepted', 'Accepted'), ('rejected', 'Rejected'),
        ('completed', 'Completed'), ('cancelled', 'Cancelled'),
    )
    PAYMENT_STATUS_CHOICES = (
        ('unpaid', 'Unpaid'), ('buyer_marked_paid', 'Buyer Marked Paid'),
        ('farmer_confirmed', 'Farmer Confirmed'), ('disputed', 'Disputed'),
    )
    DELIVERY_STATUS_CHOICES = (
        ('not_started', 'Not Started'), ('requested', 'Transport Requested'),
        ('in_transit', 'In Transit'), ('delivered', 'Delivered'),
    )
    buyer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='orders')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='orders')
    quantity_kg = models.DecimalField(max_digits=10, decimal_places=2)
    total_price = models.DecimalField(max_digits=12, decimal_places=2)
    commission = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='unpaid')
    delivery_status = models.CharField(max_length=20, choices=DELIVERY_STATUS_CHOICES, default='not_started')
    message = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        self.total_price = self.quantity_kg * self.product.price_per_kg
        rate_str = SystemSetting.get('commission_rate', '3')
        try:
            rate = Decimal(rate_str) / Decimal('100')
        except Exception:
            rate = Decimal('0.03')
        self.commission = self.total_price * rate
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Order #{self.id} - {self.product.title}"


class Rating(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='ratings')
    rater = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='given_ratings')
    ratee = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='received_ratings')
    stars = models.IntegerField()
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('order', 'rater')

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)
        if is_new:
            ratee = self.ratee
            ratee.total_ratings += 1
            ratee.rating_sum += self.stars
            ratee.save()