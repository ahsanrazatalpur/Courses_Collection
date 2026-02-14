# orders/serializers.py

from rest_framework import serializers
from .models import Order, OrderItem
from products.serializers import ProductSerializer


class OrderItemSerializer(serializers.ModelSerializer):
    """Serializer for order items"""
    
    # Include nested product details (optional)
    product = ProductSerializer(read_only=True)
    
    # Direct fields for Flutter
    name = serializers.CharField(source='product_name', read_only=True)

    class Meta:
        model = OrderItem
        fields = [
            'id',
            'product',
            'name',           # Flutter uses this
            'product_name',   # original
            'quantity',
            'price'
        ]


class OrderSerializer(serializers.ModelSerializer):
    """Serializer for orders"""
    
    items = OrderItemSerializer(many=True, read_only=True)
    
    # User info
    user_username = serializers.CharField(
        source='user.username',
        read_only=True
    )
    
    # For Flutter compatibility
    customerName = serializers.CharField(source='full_name', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id',
            'user',
            'user_username',
            'customerName',    # Flutter uses this
            'full_name',       # original
            'email',
            'phone',
            'address',
            'city',
            'state',
            'postal_code',
            'country',
            'status',
            'payment_status',
            'total_amount',
            'coupon',
            'discount_amount',
            'tracking_number',
            'estimated_delivery',
            'items',
            'created_at',
            'updated_at'
        ]
        read_only_fields = [
            'user',
            'total_amount',
            'discount_amount',
            'created_at',
            'updated_at'
        ]