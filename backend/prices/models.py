from django.db import models


class MarketPrice(models.Model):
    CROP_CHOICES = (
        ('teff', 'Teff'), ('maize', 'Maize'), ('wheat', 'Wheat'),
        ('barley', 'Barley'), ('sorghum', 'Sorghum'), ('coffee', 'Coffee'),
    )
    crop_type = models.CharField(max_length=20, choices=CROP_CHOICES)
    region = models.CharField(max_length=100)
    price_per_kg = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField(auto_now_add=True)

    class Meta:
        ordering = ['-date']

    def __str__(self):
        return f"{self.crop_type} - {self.region} - {self.price_per_kg}"