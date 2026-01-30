from django.urls import path
from .views import CartView, AddItemView, UpdateItemView, RemoveItemView

urlpatterns = [
    path('', CartView.as_view(), name='cart'),
    path('add_item/', AddItemView.as_view(), name='cart-add'),
    path('update_item/', UpdateItemView.as_view(), name='cart-update'),
    path('remove_item/', RemoveItemView.as_view(), name='cart-remove'),
]
