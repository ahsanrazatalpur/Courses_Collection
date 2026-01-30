from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse

# ---------------------------
# Root view for "/"
# ---------------------------
def home(request):
    return JsonResponse({"message": "Welcome to the backend API!"})

# ---------------------------
# URL Patterns
# ---------------------------
urlpatterns = [
    # Admin dashboard
    path('admin/', admin.site.urls),

    # Users / Auth (JWT)
    path('api/users/', include('users.urls')),

    # Products APIs
    path('api/products/', include('products.urls')),

    # Cart APIs
    path('api/cart/', include('cart.urls')),

    # Orders APIs
    path('api/orders/', include('orders.urls')),       # << Add this

    # Coupons APIs
    path('api/coupons/', include('coupons.urls')),     # << Add this

    # Root endpoint
    path('', home),  # GET "/" returns welcome message
]

# ---------------------------
# Media files (development only)
# ---------------------------
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
