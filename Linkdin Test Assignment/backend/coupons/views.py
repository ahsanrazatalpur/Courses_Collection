from decimal import Decimal
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import Coupon

class CouponViewSet(viewsets.ViewSet):
    """
    Validate and apply coupon
    """
    @action(detail=False, methods=['post'])
    def validate(self, request):
        code = request.data.get('code')
        cart_total = request.data.get('cart_total', 0)

        # Convert cart_total to Decimal for safe math
        cart_total = Decimal(str(cart_total))

        try:
            coupon = Coupon.objects.get(code=code, is_active=True)
        except Coupon.DoesNotExist:
            return Response({"error": "Coupon invalid or inactive"}, status=400)

        now = timezone.now()
        if coupon.start_date > now or coupon.end_date < now:
            return Response({"error": "Coupon expired"}, status=400)

        if cart_total < coupon.minimum_cart_value:
            return Response({"error": "Minimum cart value not met"}, status=400)

        if coupon.discount_type == 'percentage':
            discount = cart_total * (coupon.discount_value / Decimal('100'))
        else:
            discount = coupon.discount_value

        # Convert back to float for JSON response
        return Response({
            "discount": float(discount),
            "new_total": float(cart_total - discount)
        })
