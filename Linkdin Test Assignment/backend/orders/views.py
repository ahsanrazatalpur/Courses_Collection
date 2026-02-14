# orders/views.py - WITH AUTOMATIC STOCK REDUCTION

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .models import Order, OrderItem
from .serializers import OrderSerializer
from cart.models import Cart
from products.models import Product
from coupons.models import Coupon
from django.utils import timezone
from django.db import transaction


class OrderViewSet(viewsets.ViewSet):
    """
    Handle orders: create from cart, apply coupons, return order details
    """
    permission_classes = [IsAuthenticated]

    # GET /api/orders/ - User's orders
    def list(self, request):
        orders = Order.objects.filter(user=request.user).order_by('-created_at')
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)

    # GET /api/orders/{id}/ - Single order detail
    def retrieve(self, request, pk=None):
        try:
            order = Order.objects.get(id=pk, user=request.user)
        except Order.DoesNotExist:
            return Response(
                {"message": "Order not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = OrderSerializer(order)
        return Response(serializer.data)

    # POST /api/orders/ - Create order from cart
    def create(self, request):
        user = request.user

        # Get the user's cart from DB
        try:
            cart = Cart.objects.get(user=user)
        except Cart.DoesNotExist:
            return Response(
                {"message": "Cart not found. Please add items to your cart first."},
                status=status.HTTP_404_NOT_FOUND
            )

        if not cart.items.exists():
            return Response(
                {"message": "Cart is empty. Please add items before ordering."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ✅ Check stock availability BEFORE creating order
        for item in cart.items.all():
            if item.product.stock < item.quantity:
                return Response(
                    {"message": f"Insufficient stock for {item.product.name}. Only {item.product.stock} available."},
                    status=status.HTTP_400_BAD_REQUEST
                )

        # Calculate subtotal from cart
        subtotal = cart.get_total()
        
        coupon_code = request.data.get("coupon_code", "").strip()
        discount_amount = 0
        applied_coupon = None

        # Validate coupon if provided
        if coupon_code:
            try:
                coupon = Coupon.objects.get(code=coupon_code, is_active=True)
                now = timezone.now()
                if coupon.start_date <= now <= coupon.end_date:
                    if subtotal >= coupon.minimum_cart_value:
                        applied_coupon = coupon
                        if coupon.discount_type == "percentage":
                            discount_amount = (subtotal * coupon.discount_value) / 100
                        elif coupon.discount_type == "flat":
                            discount_amount = coupon.discount_value
                        
                        discount_amount = min(discount_amount, subtotal)
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
                return Response(
                    {"message": "Invalid coupon code"},
                    status=status.HTTP_404_NOT_FOUND
                )

        # Get customer details
        full_name = request.data.get("full_name") or request.data.get("name") or user.username
        email = request.data.get("email") or (user.email if user.email else "guest@example.com")
        phone = request.data.get("phone", "")
        address = request.data.get("address", "")

        final_total = subtotal - discount_amount

        # Create the order
        order = Order.objects.create(
            user=user,
            full_name=full_name,
            email=email,
            phone=phone,
            address=address,
            total_amount=final_total,
            coupon=applied_coupon,
            discount_amount=discount_amount,
            status='Pending'
        )

        # Move cart items → order items
        for item in cart.items.all():
            OrderItem.objects.create(
                order=order,
                product=item.product,
                product_name=item.product.name,
                quantity=item.quantity,
                price=item.product.price
            )

        # Clear the cart
        cart.items.all().delete()

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    # POST /api/orders/buy_now/ - Direct purchase
    @action(detail=False, methods=['post'], url_path='buy_now')
    def buy_now(self, request):
        user = request.user
        product_id = request.data.get("product_id")
        quantity = int(request.data.get("quantity", 1))

        if not product_id:
            return Response(
                {"message": "product_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response(
                {"message": "Product not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        # ✅ Check stock
        if product.stock < quantity:
            return Response(
                {"message": f"Only {product.stock} items in stock"},
                status=status.HTTP_400_BAD_REQUEST
            )

        total = product.price * quantity
        discount_amount = 0
        applied_coupon = None

        coupon_code = request.data.get("coupon_code", "").strip()
        if coupon_code:
            try:
                coupon = Coupon.objects.get(code=coupon_code, is_active=True)
                now = timezone.now()
                if coupon.start_date <= now <= coupon.end_date:
                    if total >= coupon.minimum_cart_value:
                        applied_coupon = coupon
                        if coupon.discount_type == "percentage":
                            discount_amount = (total * coupon.discount_value) / 100
                        elif coupon.discount_type == "flat":
                            discount_amount = coupon.discount_value
                        
                        discount_amount = min(discount_amount, total)
                        coupon.times_used += 1
                        coupon.save()
            except Coupon.DoesNotExist:
                pass

        full_name = request.data.get("full_name") or request.data.get("name") or user.username
        email = request.data.get("email") or (user.email if user.email else "guest@example.com")
        phone = request.data.get("phone", "")
        address = request.data.get("address", "")

        order = Order.objects.create(
            user=user,
            full_name=full_name,
            email=email,
            phone=phone,
            address=address,
            total_amount=total - discount_amount,
            coupon=applied_coupon,
            discount_amount=discount_amount,
            status='Pending'
        )

        OrderItem.objects.create(
            order=order,
            product=product,
            product_name=product.name,
            quantity=quantity,
            price=product.price
        )

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


# ========== ADMIN ORDER MANAGEMENT ==========
class AdminOrderViewSet(viewsets.ViewSet):
    """
    Admin-only order management with automatic stock reduction
    """
    permission_classes = [IsAuthenticated, IsAdminUser]

    # GET /api/admin/orders/ - All orders
    def list(self, request):
        orders = Order.objects.all().order_by('-created_at')
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)

    # GET /api/admin/orders/new/count/ - Count of pending orders
    @action(detail=False, methods=['get'], url_path='new/count')
    def new_orders_count(self, request):
        count = Order.objects.filter(status='Pending').count()
        return Response({'count': count})

    # PATCH /api/admin/orders/{id}/ - Update order status
    @transaction.atomic
    def partial_update(self, request, pk=None):
        try:
            order = Order.objects.get(id=pk)
        except Order.DoesNotExist:
            return Response(
                {"message": "Order not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        new_status = request.data.get('status')
        old_status = order.status
        
        if new_status:
            order.status = new_status
            order.save()
            
            # ✅ AUTOMATIC STOCK REDUCTION when order is delivered
            if new_status == 'Delivered' and old_status != 'Delivered':
                print(f"🚚 Order #{order.id} delivered! Reducing stock...")
                
                for item in order.items.all():
                    if item.product:
                        old_stock = item.product.stock
                        item.product.reduce_stock(item.quantity)
                        new_stock = item.product.stock
                        
                        print(f"  📦 {item.product.name}: {old_stock} → {new_stock} (-{item.quantity})")

        serializer = OrderSerializer(order)
        return Response(serializer.data)