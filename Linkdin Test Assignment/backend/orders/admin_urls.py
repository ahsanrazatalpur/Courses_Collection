# Create a NEW file: orders/admin_urls.py

from django.urls import path
from .views import AdminOrderViewSet

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
    # /api/admin/orders/
    path('orders/', admin_order_list, name='admin-order-list'),
    
    # /api/admin/orders/<id>/
    path('orders/<int:pk>/', admin_order_update, name='admin-order-update'),
    
    # /api/admin/orders/new/count/
    path('orders/new/count/', admin_new_count, name='admin-new-orders-count'),
]