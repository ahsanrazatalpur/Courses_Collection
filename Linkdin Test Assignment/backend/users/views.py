from django.contrib.auth.models import User
from rest_framework import generics
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.permissions import AllowAny  # ✅ import AllowAny
from .serializers import RegisterSerializer, CustomTokenSerializer

# Public registration endpoint
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]  # ✅ allow anyone to register

# Public login endpoint
class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenSerializer
    permission_classes = [AllowAny]  # ✅ allow anyone to login
