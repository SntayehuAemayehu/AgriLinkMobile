from django.urls import path
from .views import (
    CreateOrderView, MyOrdersView, FarmerOrdersView,
    UpdateOrderStatusView, CreateRatingView,
)

urlpatterns = [
    path('create/', CreateOrderView.as_view()),
    path('mine/', MyOrdersView.as_view()),
    path('farmer/', FarmerOrdersView.as_view()),
    path('<int:pk>/status/', UpdateOrderStatusView.as_view()),
    path('rate/', CreateRatingView.as_view()),
]