# coupons/views.py - UPDATED VERSION WITH FULL CRUD

from decimal import Decimal, InvalidOperation
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django.utils import timezone
from .models import Coupon
from .serializers import CouponSerializer


class CouponViewSet(viewsets.ModelViewSet):
    """
    ViewSet to manage coupons with full CRUD operations.
    Admin users can create, read, update, and delete coupons.
    Regular users can only validate coupons.
    """
    
    queryset = Coupon.objects.all()
    serializer_class = CouponSerializer
    
    def get_permissions(self):
        """
        Admin permission required for create, update, delete.
        Authentication required for validation.
        """
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            permission_classes = [IsAuthenticated, IsAdminUser]
        elif self.action == 'validate':
            permission_classes = [IsAuthenticated]
        else:
            # list and retrieve can be admin-only or authenticated
            permission_classes = [IsAuthenticated, IsAdminUser]
        
        return [permission() for permission in permission_classes]
    
    # ==================== LIST COUPONS ====================
    def list(self, request):
        """
        GET /api/coupons/
        List all coupons (Admin only)
        """
        coupons = Coupon.objects.all().order_by('-created_at') if hasattr(Coupon, 'created_at') else Coupon.objects.all().order_by('-id')
        serializer = CouponSerializer(coupons, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    # ==================== RETRIEVE COUPON ====================
    def retrieve(self, request, pk=None):
        """
        GET /api/coupons/{id}/
        Get single coupon details (Admin only)
        """
        try:
            coupon = Coupon.objects.get(pk=pk)
            serializer = CouponSerializer(coupon)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Coupon.DoesNotExist:
            return Response(
                {"error": "Coupon not found"},
                status=status.HTTP_404_NOT_FOUND
            )
    
    # ==================== CREATE COUPON ====================
    def create(self, request):
        """
        POST /api/coupons/
        Create a new coupon (Admin only)
        """
        serializer = CouponSerializer(data=request.data)
        
        if serializer.is_valid():
            # Check if coupon code already exists
            code = serializer.validated_data.get('code')
            if Coupon.objects.filter(code=code).exists():
                return Response(
                    {"error": f"Coupon with code '{code}' already exists"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            return Response(
                serializer.data,
                status=status.HTTP_201_CREATED
            )
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # ==================== UPDATE COUPON ====================
    def update(self, request, pk=None):
        """
        PUT /api/coupons/{id}/
        Update an entire coupon (Admin only)
        """
        try:
            coupon = Coupon.objects.get(pk=pk)
        except Coupon.DoesNotExist:
            return Response(
                {"error": "Coupon not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = CouponSerializer(coupon, data=request.data)
        
        if serializer.is_valid():
            # Check if code is being changed to an existing code
            code = serializer.validated_data.get('code')
            if code != coupon.code and Coupon.objects.filter(code=code).exists():
                return Response(
                    {"error": f"Coupon with code '{code}' already exists"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # ==================== PARTIAL UPDATE COUPON ====================
    def partial_update(self, request, pk=None):
        """
        PATCH /api/coupons/{id}/
        Partially update a coupon (Admin only)
        """
        try:
            coupon = Coupon.objects.get(pk=pk)
        except Coupon.DoesNotExist:
            return Response(
                {"error": "Coupon not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = CouponSerializer(coupon, data=request.data, partial=True)
        
        if serializer.is_valid():
            # Check if code is being changed to an existing code
            code = serializer.validated_data.get('code')
            if code and code != coupon.code and Coupon.objects.filter(code=code).exists():
                return Response(
                    {"error": f"Coupon with code '{code}' already exists"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # ==================== DELETE COUPON ====================
    def destroy(self, request, pk=None):
        """
        DELETE /api/coupons/{id}/
        Delete a coupon (Admin only)
        """
        try:
            coupon = Coupon.objects.get(pk=pk)
            coupon.delete()
            return Response(
                {"message": "Coupon deleted successfully"},
                status=status.HTTP_204_NO_CONTENT
            )
        except Coupon.DoesNotExist:
            return Response(
                {"error": "Coupon not found"},
                status=status.HTTP_404_NOT_FOUND
            )
    
    # ==================== VALIDATE COUPON (USER ACTION) ====================
    @action(detail=False, methods=['post'], url_path='validate', permission_classes=[IsAuthenticated])
    def validate(self, request):
        """
        POST /api/coupons/validate/
        Validate and calculate discount for a coupon (Any authenticated user)
        """
        code = request.data.get('code', '').strip()
        cart_total = request.data.get('cart_total', 0)

        # Validate cart_total
        try:
            cart_total = Decimal(str(cart_total))
        except (InvalidOperation, TypeError):
            return Response(
                {"error": "Invalid cart_total, must be a number"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if coupon exists and is active
        try:
            coupon = Coupon.objects.get(code=code, is_active=True)
        except Coupon.DoesNotExist:
            return Response(
                {"error": "Coupon invalid or inactive"},
                status=status.HTTP_404_NOT_FOUND
            )

        # Check coupon validity period
        now = timezone.now()
        if coupon.start_date > now or coupon.end_date < now:
            return Response(
                {"error": "Coupon expired"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check minimum cart value
        if cart_total < coupon.minimum_cart_value:
            return Response(
                {"error": f"Minimum cart value of {coupon.minimum_cart_value} not met"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check usage limit
        if coupon.usage_limit is not None and coupon.times_used >= coupon.usage_limit:
            return Response(
                {"error": "Coupon usage limit reached"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Calculate discount
        if coupon.discount_type == 'percentage':
            discount = cart_total * (coupon.discount_value / Decimal('100'))
        else:
            discount = coupon.discount_value

        new_total = max(cart_total - discount, Decimal('0.00'))

        return Response(
            {
                "success": True,
                "code": coupon.code,
                "discount": float(discount),
                "new_total": float(new_total)
            },
            status=status.HTTP_200_OK
        )