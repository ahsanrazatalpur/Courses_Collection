# dashboard/urls.py

from django.urls import path
from . import views

urlpatterns = [
    # ── Auth ──────────────────────────────────────
    path('login/',  views.admin_login,  name='admin_login'),
    path('logout/', views.admin_logout, name='admin_logout'),

    # ── Home ──────────────────────────────────────
    path('', views.dashboard_home, name='dashboard_home'),

    # ── Products ──────────────────────────────────
    path('products/',                   views.product_list,   name='product_list'),
    path('products/add/',               views.product_add,    name='product_add'),
    path('products/<int:pk>/edit/',     views.product_edit,   name='product_edit'),
    path('products/<int:pk>/delete/',   views.product_delete, name='product_delete'),

    # ── Orders ────────────────────────────────────
    path('orders/',                     views.order_list,          name='order_list'),
    path('orders/<int:pk>/',            views.order_detail,        name='order_detail'),
    path('orders/<int:pk>/status/',     views.order_update_status, name='order_update_status'),

    # ── Coupons FULL CRUD ─────────────────────────
    path('coupons/',                    views.coupon_list,   name='coupon_list'),
    path('coupons/add/',                views.coupon_add,    name='coupon_add'),
    path('coupons/<int:pk>/edit/',      views.coupon_edit,   name='coupon_edit'),
    path('coupons/<int:pk>/delete/',    views.coupon_delete, name='coupon_delete'),

    # ── Users Management ──────────────────────────
    path('users/',                          views.user_list,          name='user_list'),
    path('users/<int:pk>/block/',           views.user_toggle_block,  name='user_toggle_block'),
    path('users/<int:pk>/role/',            views.user_change_role,   name='user_change_role'),
    path('users/<int:pk>/delete/',          views.user_delete,        name='user_delete'),

    # ── Reviews Management ────────────────────────
    path('reviews/',                    views.review_list,   name='review_list'),
    path('reviews/<int:pk>/delete/',    views.review_delete, name='review_delete'),
]