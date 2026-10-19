from django.core.management.base import BaseCommand
from settings_app.models import SystemSetting


class Command(BaseCommand):
    help = 'Seed default system settings'

    def handle(self, *args, **kwargs):
        defaults = [
            ('company_name', 'AgriLink', 'Company name shown in SMS'),
            ('company_phone', '+251911234567', 'Official AgriLink SMS number'),
            ('sms_enabled', 'True', 'Enable or disable SMS sending'),
            ('sms_signature', '- AgriLink Ethiopia', 'Appended to every SMS'),
            ('commission_rate', '3', 'Commission percentage per order'),
            ('market_price_alert_hour', '8', 'Hour (0-23) to send price alerts'),
        ]
        for key, value, desc in defaults:
            SystemSetting.set(key, value, desc)
            self.stdout.write(self.style.SUCCESS(f'Set {key} = {value}'))