# users/urls.py

from django.urls import path
from .views import (
    RegisterView,
    LoginView,
    CurrentUserView,      # ✅ ADDED
    AdminUserListView,
    AdminUserDetailView,
)

urlpatterns = [
    # =============================
    # AUTH (PUBLIC)
    # =============================
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", LoginView.as_view(), name="login"),

    # =============================
    # CURRENT LOGGED-IN USER
    # =============================
    path("me/", CurrentUserView.as_view(), name="current_user"),  # ✅ FIXED 404

    # =============================
    # ADMIN – USER MANAGEMENT
    # =============================
    path(
        "admin/users/",
        AdminUserListView.as_view(),
        name="admin_user_list",
    ),
    path(
        "admin/users/<int:id>/",
        AdminUserDetailView.as_view(),
        name="admin_user_detail",
    ),
]
