# reviews/serializers.py - FIXED VERSION

from rest_framework import serializers
from .models import Review, ReviewLike
from products.models import Product
from orders.models import Order


class ReviewSerializer(serializers.ModelSerializer):
    """
    Serializer for Review model with user, product details, and like info
    """
    
    # Read-only fields for display
    user_name = serializers.CharField(source='user_display_name', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    is_verified = serializers.BooleanField(source='is_verified_purchase', read_only=True)
    product_name = serializers.CharField(source='product.name', read_only=True)
    
    # Like information
    likes_count = serializers.IntegerField(read_only=True)
    user_has_liked = serializers.SerializerMethodField()
    
    # Edit tracking
    is_edited = serializers.BooleanField(read_only=True)
    
    # Allow write but make optional
    order_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)
    
    class Meta:
        model = Review
        fields = [
            'id',
            'product',
            'product_name',
            'user',
            'user_name',
            'username',
            'order_id',
            'rating',
            'title',
            'comment',
            'is_verified',
            'is_edited',
            'likes_count',
            'user_has_liked',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at', 'is_edited']
    
    def get_user_has_liked(self, obj):
        """Check if current user has liked this review"""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return ReviewLike.objects.filter(
                review=obj,
                user=request.user
            ).exists()
        return False
    
    def validate_rating(self, value):
        """Validate rating is between 1 and 5"""
        if value < 1 or value > 5:
            raise serializers.ValidationError("Rating must be between 1 and 5")
        return value
    
    def validate(self, data):
        """✅ FIXED: Validate review eligibility"""
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            raise serializers.ValidationError("Must be logged in to review")
        
        # For new reviews (not updates)
        if not self.instance:
            product = data.get('product')
            user = request.user
            
            # ✅ FIX: Check if user already reviewed this product
            if Review.objects.filter(product=product, user=user).exists():
                raise serializers.ValidationError(
                    "You have already reviewed this product. You can edit your existing review."
                )
            
            # ✅ FIX: Verify user has a delivered order for this product
            has_delivered_order = Order.objects.filter(
                user=user,
                items__product=product,
                status="Delivered"
            ).exists()
            
            if not has_delivered_order:
                raise serializers.ValidationError(
                    "You can only review products you have purchased and received (order status must be 'Delivered')."
                )
        
        return data
    
    def create(self, validated_data):
        """Create review with user from request"""
        request = self.context.get('request')
        validated_data['user'] = request.user
        
        # Get order if order_id provided
        order_id = validated_data.pop('order_id', None)
        if order_id:
            try:
                order = Order.objects.get(
                    id=order_id,
                    user=request.user,
                    status="Delivered"
                )
                validated_data['order'] = order
            except Order.DoesNotExist:
                pass  # Will auto-find order in model save()
        
        return super().create(validated_data)


class ProductReviewSummarySerializer(serializers.ModelSerializer):
    """
    Lightweight serializer for product rating summary
    """
    average_rating = serializers.DecimalField(max_digits=3, decimal_places=1, read_only=True)
    review_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Product
        fields = ['id', 'name', 'average_rating', 'review_count']


class ReviewEligibilitySerializer(serializers.Serializer):
    """
    Check if user can review a product
    """
    product_id = serializers.IntegerField()
    can_review = serializers.BooleanField(read_only=True)
    reason = serializers.CharField(read_only=True)
    existing_review = ReviewSerializer(read_only=True, allow_null=True)


class ReviewLikeSerializer(serializers.ModelSerializer):
    """
    Serializer for review likes
    """
    username = serializers.CharField(source='user.username', read_only=True)
    
    class Meta:
        model = ReviewLike
        fields = ['id', 'review', 'user', 'username', 'created_at']
        read_only_fields = ['id', 'user', 'created_at']