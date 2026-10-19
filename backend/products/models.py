from django.db import models
from django.conf import settings


class Product(models.Model):
    CROP_CHOICES = (
        ('teff', 'Teff'), ('maize', 'Maize'), ('wheat', 'Wheat'),
        ('barley', 'Barley'), ('sorghum', 'Sorghum'), ('coffee', 'Coffee'),
        ('vegetables', 'Vegetables'), ('fruits', 'Fruits'), ('other', 'Other'),
    )
    STATUS_CHOICES = (
        ('available', 'Available'), ('sold', 'Sold'), ('reserved', 'Reserved'),
    )
    farmer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='products')
    crop_type = models.CharField(max_length=20, choices=CROP_CHOICES)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    quantity_kg = models.DecimalField(max_digits=10, decimal_places=2)
    price_per_kg = models.DecimalField(max_digits=10, decimal_places=2)
    region = models.CharField(max_length=100)
    woreda = models.CharField(max_length=100)
    image = models.ImageField(upload_to='products/', blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='available')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.farmer.username}"