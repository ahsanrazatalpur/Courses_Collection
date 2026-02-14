# reviews/views.py - FIXED VERSION (removes annotate conflict)

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly, IsAdminUser
from django.db.models import Avg, Count
from django.db import models
from .models import Review, ReviewLike
from .serializers import ReviewSerializer, ReviewEligibilitySerializer, ReviewLikeSerializer
from products.models import Product
from orders.models import Order


class ReviewViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing product reviews with like functionality
    """
    
    # ✅ FIX: Remove .annotate() that conflicts with @property
    queryset = Review.objects.select_related('user', 'product', 'order').all()
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get_queryset(self):
        """Filter reviews based on query parameters"""
        queryset = super().get_queryset()
        
        # Filter by product
        product_id = self.request.query_params.get('product')
        if product_id:
            queryset = queryset.filter(product_id=product_id)
        
        # Filter by rating
        rating = self.request.query_params.get('rating')
        if rating:
            queryset = queryset.filter(rating=rating)
        
        # Filter by verified purchases only
        verified = self.request.query_params.get('verified')
        if verified and verified.lower() == 'true':
            queryset = queryset.filter(order__isnull=False, order__status="Delivered")
        
        return queryset
    
    def perform_create(self, serializer):
        """Set user to current user when creating"""
        serializer.save(user=self.request.user)
    
    def perform_update(self, serializer):
        """Only allow users to update their own reviews"""
        if serializer.instance.user != self.request.user and not self.request.user.is_staff:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You can only edit your own reviews")
        serializer.save()
    
    def perform_destroy(self, instance):
        """Only allow users to delete their own reviews (or admin)"""
        if instance.user != self.request.user and not self.request.user.is_staff:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You can only delete your own reviews")
        instance.delete()
    
    # ================= LIKE/UNLIKE REVIEW =================
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def like(self, request, pk=None):
        """
        POST /api/reviews/{id}/like/
        Like or unlike a review (toggle)
        """
        try:
            review = self.get_object()
        except Review.DoesNotExist:
            return Response(
                {"error": "Review not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Check if user already liked this review
        like = ReviewLike.objects.filter(review=review, user=request.user).first()
        
        if like:
            # Unlike - remove the like
            like.delete()
            return Response({
                "message": "Review unliked",
                "liked": False,
                "likes_count": review.likes_count
            })
        else:
            # Like - create new like
            ReviewLike.objects.create(review=review, user=request.user)
            return Response({
                "message": "Review liked",
                "liked": True,
                "likes_count": review.likes_count
            })
    
    # ================= GET REVIEW LIKES =================
    
    @action(detail=True, methods=['get'])
    def likes(self, request, pk=None):
        """
        GET /api/reviews/{id}/likes/
        Get list of users who liked this review
        """
        try:
            review = self.get_object()
        except Review.DoesNotExist:
            return Response(
                {"error": "Review not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        likes = ReviewLike.objects.filter(review=review).select_related('user')
        serializer = ReviewLikeSerializer(likes, many=True)
        
        return Response({
            'review_id': review.id,
            'total_likes': likes.count(),
            'likes': serializer.data
        })
    
    # ================= PRODUCT REVIEWS =================
    
    @action(detail=False, methods=['get'], url_path='product/(?P<product_id>[^/.]+)')
    def product_reviews(self, request, product_id=None):
        """
        GET /api/reviews/product/{product_id}/
        Get all reviews for a specific product with pagination
        """
        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response(
                {"error": "Product not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        reviews = self.get_queryset().filter(product=product)
        
        # Pagination parameters
        page_size = int(request.query_params.get('page_size', 10))
        page = int(request.query_params.get('page', 1))
        
        # Calculate stats
        stats = reviews.aggregate(
            average_rating=Avg('rating'),
            total_reviews=models.Count('id')
        )
        
        # Get rating distribution
        rating_distribution = {}
        for i in range(1, 6):
            rating_distribution[f'{i}_star'] = reviews.filter(rating=i).count()
        
        # Paginate reviews
        start = (page - 1) * page_size
        end = start + page_size
        paginated_reviews = reviews[start:end]
        
        serializer = self.get_serializer(paginated_reviews, many=True)
        
        return Response({
            'product_id': product.id,
            'product_name': product.name,
            'average_rating': round(stats['average_rating'], 1) if stats['average_rating'] else 0,
            'total_reviews': stats['total_reviews'],
            'rating_distribution': rating_distribution,
            'page': page,
            'page_size': page_size,
            'has_more': end < stats['total_reviews'],
            'reviews': serializer.data
        })
    
    # ================= MY REVIEWS =================
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def my_reviews(self, request):
        """
        GET /api/reviews/my-reviews/
        Get all reviews by the current user
        """
        reviews = self.get_queryset().filter(user=request.user)
        serializer = self.get_serializer(reviews, many=True)
        return Response(serializer.data)
    
    # ================= CHECK ELIGIBILITY =================
    
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated])
    def check_eligibility(self, request):
        """
        POST /api/reviews/check-eligibility/
        Check if user can review a product
        """
        product_id = request.data.get('product_id')
        
        if not product_id:
            return Response(
                {"error": "product_id is required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response(
                {"error": "Product not found"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Check if already reviewed
        existing_review = Review.objects.filter(
            product=product,
            user=request.user
        ).first()
        
        if existing_review:
            return Response({
                'can_review': False,
                'reason': 'You have already reviewed this product',
                'existing_review': ReviewSerializer(existing_review, context={'request': request}).data
            })
        
        # Check if user has delivered order
        has_delivered_order = Order.objects.filter(
            user=request.user,
            items__product=product,
            status="Delivered"
        ).exists()
        
        if not has_delivered_order:
            return Response({
                'can_review': False,
                'reason': 'You can only review products you have purchased and received',
                'existing_review': None
            })
        
        return Response({
            'can_review': True,
            'reason': 'You can review this product',
            'existing_review': None
        })
    
    # ================= PENDING REVIEWS =================
    
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def pending(self, request):
        """
        GET /api/reviews/pending/
        Get list of products user can review (delivered but not reviewed yet)
        """
        from django.db.models import Q
        
        # Get all delivered orders for this user
        delivered_orders = Order.objects.filter(
            user=request.user,
            status="Delivered"
        ).prefetch_related('items__product')
        
        # Get product IDs from delivered orders
        delivered_product_ids = set()
        for order in delivered_orders:
            for item in order.items.all():
                if item.product:
                    delivered_product_ids.add(item.product.id)
        
        # Get product IDs user has already reviewed
        reviewed_product_ids = set(
            Review.objects.filter(user=request.user)
            .values_list('product_id', flat=True)
        )
        
        # Products that can be reviewed = delivered - already reviewed
        pending_product_ids = delivered_product_ids - reviewed_product_ids
        
        # Get product details
        pending_products = Product.objects.filter(id__in=pending_product_ids)
        
        products_data = []
        for product in pending_products:
            products_data.append({
                'id': product.id,
                'name': product.name,
                'image': product.image,
                'price': product.price,
            })
        
        return Response({
            'count': len(products_data),
            'products': products_data
        })


# ================= ADMIN VIEW FOR MODERATION =================

class AdminReviewViewSet(viewsets.ModelViewSet):
    """
    Admin-only viewset for review moderation
    """
    
    # ✅ FIX: Remove .annotate() that conflicts with @property
    queryset = Review.objects.select_related('user', 'product', 'order').all()
    serializer_class = ReviewSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]
    
    def get_queryset(self):
        """Filter by rating or product for admin"""
        queryset = super().get_queryset()
        
        # Filter by minimum rating
        min_rating = self.request.query_params.get('min_rating')
        if min_rating:
            queryset = queryset.filter(rating__gte=min_rating)
        
        max_rating = self.request.query_params.get('max_rating')
        if max_rating:
            queryset = queryset.filter(rating__lte=max_rating)
        
        # Filter by product
        product_id = self.request.query_params.get('product')
        if product_id:
            queryset = queryset.filter(product_id=product_id)
        
        return queryset.order_by('-created_at')
    
    @action(detail=False, methods=['get'])
    def flagged(self, request):
        """
        GET /api/admin/reviews/flagged/
        Get reviews that might need moderation (low ratings, edited, etc.)
        """
        # Reviews with rating <= 2
        low_rated = self.get_queryset().filter(rating__lte=2)
        
        serializer = self.get_serializer(low_rated, many=True)
        
        return Response({
            'count': low_rated.count(),
            'reviews': serializer.data
        })