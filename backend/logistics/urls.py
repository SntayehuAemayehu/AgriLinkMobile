from django.urls import path
from .views import (
    CreateTransportView, OpenTransportsView, MyTransportsView,
    MyJobsView, AcceptTransportView, UpdateTransportStatusView,
)

urlpatterns = [
    path('create/', CreateTransportView.as_view()),
    path('open/', OpenTransportsView.as_view()),
    path('mine/', MyTransportsView.as_view()),
    path('jobs/', MyJobsView.as_view()),
    path('<int:pk>/accept/', AcceptTransportView.as_view()),
    path('<int:pk>/status/', UpdateTransportStatusView.as_view()),
]