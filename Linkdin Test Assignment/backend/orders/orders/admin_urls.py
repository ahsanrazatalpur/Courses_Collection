# orders/admin_urls.py - UPDATED WITH REVIEW ENDPOINTS

from django.urls import path
from .views import AdminOrderViewSet
from reviews.views import AdminReviewViewSet

# ==================== ADMIN ORDER ENDPOINTS ====================
admin_order_list = AdminOrderViewSet.as_view({
    'get': 'list',
})

admin_order_update = AdminOrderViewSet.as_view({
    'patch': 'partial_update',
})

admin_new_count = AdminOrderViewSet.as_view({
    'get': 'new_orders_count',
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
    # ==================== ORDERS ====================
    # /api/admin/orders/
    path('orders/', admin_order_list, name='admin-order-list'),
    
    # /api/admin/orders/<id>/
    path('orders/<int:pk>/', admin_order_update, name='admin-order-update'),
    
    # /api/admin/orders/new/count/
    path('orders/new/count/', admin_new_count, name='admin-new-orders-count'),
    
    # ==================== REVIEWS ====================
    # /api/admin/reviews/
    path('reviews/', admin_review_list, name='admin-review-list'),
    
    # /api/admin/reviews/<id>/
    path('reviews/<int:pk>/', admin_review_delete, name='admin-review-delete'),
    
    # /api/admin/reviews/flagged/
    path('reviews/flagged/', admin_flagged_reviews, name='admin-flagged-reviews'),
]