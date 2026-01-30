from rest_framework import serializers
from .models import Coupon

class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = Coupon
        fields = [
            'id',
            'code',
            'discount_type',
            'discount_value',
            'start_date',
            'end_date',
            'minimum_cart_value',
            'usage_limit',
            'is_active',
            'applicable_products',
            'times_used',
        ]
        read_only_fields = ['times_used']
