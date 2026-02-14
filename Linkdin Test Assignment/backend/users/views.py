# users/views.py - FIXED VERSION
from django.contrib.auth import authenticate
from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAdminUser, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import RegisterSerializer, CustomTokenSerializer
from .models import User


# =============================
# PUBLIC REGISTER
# =============================
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"message": "Registration successful! Please login."},
            status=status.HTTP_201_CREATED
        )


# =============================
# PUBLIC LOGIN (JWT)
# =============================
class LoginView(TokenObtainPairView):
    serializer_class = CustomTokenSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        username = request.data.get("username")
        password = request.data.get("password")

        user = authenticate(username=username, password=password)
        
        # ✅ FIX: Check if user exists first
        if not user:
            return Response(
                {"error": "Invalid username or password"},
                status=status.HTTP_401_UNAUTHORIZED
            )

        # ✅ FIX: Check if user is blocked BEFORE generating tokens
        if user.is_blocked:
            return Response(
                {"error": "Your account has been blocked by admin. Please contact support."},
                status=status.HTTP_403_FORBIDDEN
            )

        # Generate tokens only for active users
        refresh = RefreshToken.for_user(user)

        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh),
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "role": user.role,
            "is_admin": user.is_staff,
            "is_active": not user.is_blocked,
        }, status=status.HTTP_200_OK)


# =============================
# CURRENT LOGGED-IN USER
# =============================
class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        
        # ✅ FIX: Check if user was blocked after login
        if user.is_blocked:
            return Response(
                {"error": "Your account has been blocked. Please contact admin."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        return Response({
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "role": user.role,
            "is_admin": user.is_staff,
            "is_blocked": user.is_blocked,
        }, status=status.HTTP_200_OK)


# =============================
# ADMIN: LIST USERS
# =============================
class AdminUserListView(generics.ListAPIView):
    queryset = User.objects.all().order_by("-id")
    serializer_class = RegisterSerializer
    permission_classes = [IsAdminUser]

    def list(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_queryset(), many=True)
        return Response({
            "status": "success",
            "total_users": len(serializer.data),
            "users": serializer.data
        }, status=status.HTTP_200_OK)


# =============================
# ADMIN: USER DETAIL (PATCH / DELETE)
# =============================
class AdminUserDetailView(APIView):
    permission_classes = [IsAdminUser]

    def get_object(self, id):
        try:
            return User.objects.get(id=id)
        except User.DoesNotExist:
            return None

    # ---------- UPDATE USER ----------
    def patch(self, request, id):
        user = self.get_object(id)
        if not user:
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        # ✅ FIX: Prevent admin from blocking/deleting themselves
        if user.id == request.user.id:
            return Response(
                {"error": "You cannot modify your own account"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Role update
        if "role" in request.data:
            role = request.data["role"]
            if role not in ["user", "admin"]:
                return Response(
                    {"error": "Role must be 'user' or 'admin'"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            user.role = role
            user.is_staff = role == "admin"

        # ✅ FIX: Block / Unblock (properly handle is_blocked)
        if "isActive" in request.data:
            # Flutter sends isActive (true = not blocked, false = blocked)
            user.is_blocked = not bool(request.data["isActive"])
        elif "is_blocked" in request.data:
            # Direct is_blocked value
            user.is_blocked = bool(request.data["is_blocked"])

        user.save()

        return Response({
            "status": "success",
            "id": user.id,
            "username": user.username,
            "role": user.role,
            "is_blocked": user.is_blocked,
            "isActive": not user.is_blocked
        }, status=status.HTTP_200_OK)

    # ---------- DELETE USER ----------
    def delete(self, request, id):
        user = self.get_object(id)
        if not user:
            return Response(
                {"error": "User not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        # ✅ FIX: Prevent admin from deleting themselves
        if user.id == request.user.id:
            return Response(
                {"error": "You cannot delete your own account"},
                status=status.HTTP_400_BAD_REQUEST
            )

        username = user.username  # Store for response message
        user.delete()
        
        return Response(
            {
                "status": "deleted",
                "message": f"User '{username}' has been permanently deleted"
            },
            status=status.HTTP_200_OK
        )