# backend/urls.py - UPDATED WITH MEDIA FILE SERVING

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse

# Root view for testing
def home(request):
    return JsonResponse({"message": "Welcome to the backend API!"})

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # User-related endpoints
    path('api/users/', include('users.urls')),
    
    # Product endpoints
    path('api/products/', include('products.urls')),
    
    # Cart endpoints
    path('api/cart/', include('cart.urls')),
    
    # User order endpoints
    path('api/orders/', include('orders.urls')),
    
    # Admin order endpoints
    path('api/admin/', include('orders.admin_urls')),
    
    # Coupon endpoints
    path('api/coupons/', include('coupons.urls')),
    
    # Review endpoints (includes both user and admin routes)
    path('api/reviews/', include('reviews.urls')),
    
    # Root
    path('', home),
]

# ✅ CRITICAL: Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)