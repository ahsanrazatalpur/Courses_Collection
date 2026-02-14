# reviews/admin_urls.py - NEW FILE FOR ADMIN REVIEW ROUTES

from django.urls import path
from .views import AdminReviewViewSet

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
    # /api/admin/reviews/
    path('', admin_review_list, name='admin-review-list'),
    
    # /api/admin/reviews/<id>/
    path('<int:pk>/', admin_review_delete, name='admin-review-delete'),
    
    # /api/admin/reviews/flagged/
    path('flagged/', admin_flagged_reviews, name='admin-flagged-reviews'),
]