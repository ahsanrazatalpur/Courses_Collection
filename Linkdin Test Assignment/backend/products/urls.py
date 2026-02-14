from django.urls import path
from .views import (
    ProductListCreateAPIView,
    ProductRetrieveUpdateDestroyAPIView
)

urlpatterns = [
    # List all products or create a new product
    path('', ProductListCreateAPIView.as_view(), name='product-list-create'),

    # Retrieve, update, or delete a product by ID
    path('<int:id>/', ProductRetrieveUpdateDestroyAPIView.as_view(), name='product-rud'),
]
