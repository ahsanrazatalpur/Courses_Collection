from django.urls import path
from .views import (
    ProductListAPIView,
    ProductDetailAPIView,
    ProductCreateAPIView,
    ProductUpdateAPIView,
    ProductDeleteAPIView
)

urlpatterns = [
    # Public
    path('', ProductListAPIView.as_view(), name='product-list'),
    path('<int:id>/', ProductDetailAPIView.as_view(), name='product-detail'),

    # Admin only
    path('create/', ProductCreateAPIView.as_view(), name='product-create'),
    path('update/<int:id>/', ProductUpdateAPIView.as_view(), name='product-update'),
    path('delete/<int:id>/', ProductDeleteAPIView.as_view(), name='product-delete'),
]
