from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models


class UserManager(BaseUserManager):
    def create_user(self, username, phone, password=None, **extra_fields):
        if not username:
            raise ValueError('Username is required')
        if not phone:
            raise ValueError('Phone is required')
        user = self.model(username=username, phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, phone, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(username, phone, password, **extra_fields)


class User(AbstractUser):
    ROLE_CHOICES = (
        ('farmer', 'Farmer'),
        ('buyer', 'Buyer'),
        ('transporter', 'Transporter'),
        ('admin', 'Admin'),
    )
    role = models.CharField(max_length=15, choices=ROLE_CHOICES, default='farmer')
    phone = models.CharField(max_length=15, unique=True)
    region = models.CharField(max_length=100, blank=True)
    woreda = models.CharField(max_length=100, blank=True)
    is_verified = models.BooleanField(default=False)
    total_ratings = models.IntegerField(default=0)
    rating_sum = models.IntegerField(default=0)
    language = models.CharField(max_length=5, default='en')

    objects = UserManager()
    REQUIRED_FIELDS = ['phone']

    def __str__(self):
        return f"{self.username} ({self.role})"

    @property
    def average_rating(self):
        if self.total_ratings == 0:
            return 0
        return round(self.rating_sum / self.total_ratings, 2)