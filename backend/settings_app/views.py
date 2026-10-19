from rest_framework import generics, permissions
from .models import SystemSetting
from .serializers import SystemSettingSerializer


class PublicSettingsView(generics.ListAPIView):
    serializer_class = SystemSettingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return SystemSetting.objects.filter(
            key__in=['company_name', 'company_phone', 'commission_rate']
        )