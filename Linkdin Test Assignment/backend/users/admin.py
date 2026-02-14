from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User

# Optional: create a custom admin class to show extra fields
class UserAdmin(BaseUserAdmin):
    model = User
    list_display = ('username', 'email', 'role', 'is_staff', 'is_blocked', 'is_active')
    list_filter = ('role', 'is_staff', 'is_blocked', 'is_superuser', 'is_active')
    fieldsets = (
        (None, {'fields': ('username', 'email', 'password')}),
        ('Permissions', {'fields': ('role', 'is_staff', 'is_superuser', 'is_blocked', 'is_active', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2', 'role', 'is_staff', 'is_blocked', 'is_active')}
        ),
    )
    search_fields = ('username', 'email')
    ordering = ('username',)

# Register your custom User model
admin.site.register(User, UserAdmin)
