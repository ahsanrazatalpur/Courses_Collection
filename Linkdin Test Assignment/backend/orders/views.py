from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Order, OrderItem
from .serializers import OrderSerializer
from cart.models import Cart
from coupons.models import Coupon
from django.utils import timezone

class OrderViewSet(viewsets.ViewSet):
    """
    Handle orders: create from cart, apply coupons, return order details
    """

    permission_classes = [IsAuthenticated]

    def list(self, request):
        orders = Order.objects.filter(user=request.user).order_by('-created_at')
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)

    def retrieve(self, request, pk=None):
        try:
            order = Order.objects.get(id=pk, user=request.user)
        except Order.DoesNotExist:
            return Response({"message": "Order not found"}, status=status.HTTP_404_NOT_FOUND)
        serializer = OrderSerializer(order)
        return Response(serializer.data)

    def create(self, request):
        user = request.user
        try:
            cart = Cart.objects.get(user=user)
        except Cart.DoesNotExist:
            return Response({"message": "Cart not found"}, status=status.HTTP_404_NOT_FOUND)

        if not cart.items.exists():
            return Response({"message": "Cart is empty"}, status=status.HTTP_400_BAD_REQUEST)

        coupon_code = request.data.get("coupon_code")
        discount_amount = 0
        applied_coupon = None

        # Validate coupon
        if coupon_code:
            try:
                coupon = Coupon.objects.get(code=coupon_code, is_active=True)
                now = timezone.now()
                if coupon.start_date <= now <= coupon.end_date:
                    if cart.get_total() >= coupon.minimum_cart_value:
                        applied_coupon = coupon
                        if coupon.discount_type == "percentage":
                            discount_amount = (cart.get_total() * coupon.discount_value) / 100
                        elif coupon.discount_type == "flat":
                            discount_amount = coupon.discount_value
                        # Increase usage count
                        coupon.times_used += 1
                        coupon.save()
                    else:
                        return Response(
                            {"message": "Cart total does not meet coupon minimum value."},
                            status=status.HTTP_400_BAD_REQUEST
                        )
                else:
                    return Response(
                        {"message": "Coupon is not valid at this time."},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            except Coupon.DoesNotExist:
                return Response({"message": "Invalid coupon code"}, status=status.HTTP_404_NOT_FOUND)

        # Create order
        order = Order.objects.create(
            user=user,
            full_name=request.data.get("full_name", user.username),
            email=request.data.get("email", user.email if user.email else "guest@example.com"),
            total_amount=cart.get_total() - discount_amount,
            coupon=applied_coupon,
            discount_amount=discount_amount
        )

        # Move cart items to order
        for item in cart.items.all():
            OrderItem.objects.create(
                order=order,
                product=item.product,
                quantity=item.quantity,
                price=item.product.price
            )

        # Clear cart
        cart.items.all().delete()

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
