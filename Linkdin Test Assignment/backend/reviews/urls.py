# reviews/urls.py - COMPLETE WITH ADMIN ENDPOINTS

from django.urls import path
from .views import ReviewViewSet, AdminReviewViewSet

# ==================== USER REVIEW ENDPOINTS ====================

review_list = ReviewViewSet.as_view({
    'get': 'list',
    'post': 'create',
})

review_detail = ReviewViewSet.as_view({
    'get': 'retrieve',
    'patch': 'partial_update',
    'delete': 'destroy',
})

review_like = ReviewViewSet.as_view({
    'post': 'like',
})

review_likes_list = ReviewViewSet.as_view({
    'get': 'likes',
})

product_reviews = ReviewViewSet.as_view({
    'get': 'product_reviews',
})

my_reviews = ReviewViewSet.as_view({
    'get': 'my_reviews',
})

check_eligibility = ReviewViewSet.as_view({
    'post': 'check_eligibility',
})

pending_reviews = ReviewViewSet.as_view({
    'get': 'pending',
})

# ==================== ADMIN REVIEW ENDPOINTS ====================

admin_review_list = AdminReviewViewSet.as_view({
    'get': 'list',
})

admin_review_delete = AdminReviewViewSet.as_view({
    'delete': 'destroy',
})

admin_flagged_reviews = AdminReviewViewSet.as_view({
    'get': 'flagged',
})

urlpatterns = [
    # ==================== USER ENDPOINTS ====================
    
    # /api/reviews/
    path('', review_list, name='review-list'),
    
    # /api/reviews/<id>/
    path('<int:pk>/', review_detail, name='review-detail'),
    
    # /api/reviews/<id>/like/
    path('<int:pk>/like/', review_like, name='review-like'),
    
    # /api/reviews/<id>/likes/
    path('<int:pk>/likes/', review_likes_list, name='review-likes'),
    
    # /api/reviews/product/<product_id>/
    path('product/<int:product_id>/', product_reviews, name='product-reviews'),
    
    # /api/reviews/my-reviews/
    path('my-reviews/', my_reviews, name='my-reviews'),
    
    # /api/reviews/check-eligibility/
    path('check-eligibility/', check_eligibility, name='check-eligibility'),
    
    # /api/reviews/pending/
    path('pending/', pending_reviews, name='pending-reviews'),
    
    # ==================== ADMIN ENDPOINTS (INCLUDED HERE) ====================
    
    # /api/reviews/admin/all/
    path('admin/all/', admin_review_list, name='admin-review-list'),
    
    # /api/reviews/admin/<id>/
    path('admin/<int:pk>/', admin_review_delete, name='admin-review-delete'),
    
    # /api/reviews/admin/flagged/
    path('admin/flagged/', admin_flagged_reviews, name='admin-flagged-reviews'),
]