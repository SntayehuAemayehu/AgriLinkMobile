from django.urls import path
from .views import PriceListView

urlpatterns = [
    path('', PriceListView.as_view()),
]