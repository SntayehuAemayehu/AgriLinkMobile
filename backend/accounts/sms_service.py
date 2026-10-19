import requests
from decouple import config
from settings_app.models import SystemSetting

# Your API Key from the .env file
TEXTBEE_API_KEY = config('TEXTBEE_API_KEY', default='')

# Base URL from your screenshot
TEXTBEE_URL = 'https://api.textbee.dev/api/v1'


def get_company_name():
    return SystemSetting.get('company_name', 'AgriLink')

def get_sms_signature():
    return SystemSetting.get('sms_signature', '- AgriLink')

def is_sms_enabled():
    value = SystemSetting.get('sms_enabled', 'True')
    return str(value).lower() in ('true', '1', 'yes')


def send_sms(phone: str, message: str) -> dict:
    if not is_sms_enabled():
        return {'status': 'skipped', 'message': 'SMS disabled in settings'}

    if not phone.startswith('+'):
        phone = '+251' + phone.lstrip('0')

    signature = get_sms_signature()
    if signature:
        message = f"{message}\n{signature}"

    try:
        # Since Device ID is optional, we send directly to the endpoint
        response = requests.post(
            f'{TEXTBEE_URL}/gateway/send-sms',
            headers={
                'x-api-key': TEXTBEE_API_KEY,
                'Content-Type': 'application/json',
            },
            json={'recipients': [phone], 'message': message},
            timeout=15,
        )
        if response.status_code == 200:
            return {'status': 'success', 'data': response.json()}
        return {'status': 'error', 'code': response.status_code, 'message': response.text}
    except Exception as e:
        return {'status': 'error', 'message': str(e)}


def notify_farmer_new_order(order):
    company = get_company_name()
    msg = f"{company}: New order! {order.buyer.username} ordered {order.quantity_kg}kg of {order.product.title}."
    return send_sms(order.product.farmer.phone, msg)

def notify_buyer_order_accepted(order):
    company = get_company_name()
    msg = f"{company}: Your order for {order.product.title} was accepted by {order.product.farmer.username}."
    return send_sms(order.buyer.phone, msg)

def notify_buyer_payment_confirmed(order):
    company = get_company_name()
    msg = f"{company}: Payment confirmed for order #{order.id}. Thank you!"
    return send_sms(order.buyer.phone, msg)