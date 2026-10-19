from django.urls import path
from .views import (
    ProductListCreateView, 
    MyProductsView, 
    ProductDetailView, 
    AdminProductListView
)

urlpatterns = [
    path('', ProductListCreateView.as_view()),
    path('mine/', MyProductsView.as_view()),
    path('<int:pk>/', ProductDetailView.as_view()),
    # NEW: Admin route
    path('admin/all/', AdminProductListView.as_view()),
]