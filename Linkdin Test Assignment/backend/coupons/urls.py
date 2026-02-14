from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CouponViewSet

router = DefaultRouter()
# Register ViewSet directly at root of this app
router.register('', CouponViewSet, basename='coupons')  # <-- remove 'coupons'

urlpatterns = [
    path('', include(router.urls)),
]
