# users/serializers.py
from rest_framework import serializers
from .models import User
from django.contrib.auth.password_validation import validate_password

# =========================
# Register / User Serializer
# =========================
class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True, required=True, validators=[validate_password]
    )

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'role', 'is_blocked', 'is_staff']
        read_only_fields = ['id', 'is_staff', 'is_blocked']  # these fields not editable on registration

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)  # Hash password
        user.save()
        return user

# =========================
# Admin User Update Serializer (for PATCH)
# =========================
class AdminUserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['role', 'is_blocked']
        extra_kwargs = {
            'role': {'required': False},
            'is_blocked': {'required': False},
        }

# =========================
# Custom Token Serializer for Login
# =========================
class CustomTokenSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
