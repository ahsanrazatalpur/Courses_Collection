# orders/urls.py - FIXED VERSION

from django.urls import path
from .views import OrderViewSet, AdminOrderViewSet

# ==================== USER ORDER ENDPOINTS ====================
order_list = OrderViewSet.as_view({
    'get': 'list',
    'post': 'create',
})

order_detail = OrderViewSet.as_view({
    'get': 'retrieve',
})

buy_now = OrderViewSet.as_view({
    'post': 'buy_now',
})

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

urlpatterns = [
    # ==================== USER ENDPOINTS ====================
    # /api/orders/
    path('', order_list, name='order-list'),
    
    # /api/orders/<id>/
    path('<int:pk>/', order_detail, name='order-detail'),
    
    # /api/orders/buy_now/
    path('buy_now/', buy_now, name='buy-now'),
]