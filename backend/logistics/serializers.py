from rest_framework import serializers
from .models import TransportRequest


class TransportSerializer(serializers.ModelSerializer):
    requester_name = serializers.CharField(source='requester.username', read_only=True)
    transporter_name = serializers.CharField(source='transporter.username', read_only=True)

    class Meta:
        model = TransportRequest
        fields = '__all__'
        read_only_fields = ['requester', 'transporter', 'status']