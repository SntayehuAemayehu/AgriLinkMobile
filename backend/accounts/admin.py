from django.contrib import admin
from .models import User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'phone', 'role', 'region', 'is_verified', 'average_rating')
    list_filter = ('role', 'is_verified', 'region')
    search_fields = ('username', 'phone')