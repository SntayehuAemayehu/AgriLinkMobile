from rest_framework import serializers
from .models import User

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['username', 'password', 'phone', 'role', 'region', 'woreda', 'first_name', 'last_name']

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)

class UserSerializer(serializers.ModelSerializer):
    average_rating = serializers.FloatField(read_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'phone', 'role', 'region', 'woreda',
                  'is_verified', 'first_name', 'last_name', 'average_rating', 'language', 
                  'is_staff', 'is_superuser'] # ADDED THESE FIELDS