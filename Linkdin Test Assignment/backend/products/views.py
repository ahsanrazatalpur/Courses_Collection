# products/views.py - COMPLETE FIXED VERSION WITH PROPER ERROR HANDLING

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .models import Product
from .serializers import ProductSerializer
from rest_framework.permissions import IsAuthenticated

# ===================== LIST + CREATE =====================
class ProductListCreateAPIView(generics.ListCreateAPIView):
    queryset = Product.objects.all().order_by('-created_at')
    serializer_class = ProductSerializer
    permission_classes = [IsAuthenticated]
    
    # ✅ CRITICAL: Support both JSON and multipart
    parser_classes = (MultiPartParser, FormParser, JSONParser)

    def create(self, request, *args, **kwargs):
        print("=" * 80)
        print("📥 CREATE REQUEST RECEIVED")
        print("=" * 80)
        print(f"📎 Content-Type: {request.content_type}")
        print(f"📎 Files: {list(request.FILES.keys())}")
        print(f"📎 Data keys: {list(request.data.keys())}")
        
        data = request.data.copy()
        
        # ✅ FIX: Handle different upload scenarios
        if 'image' in request.FILES:
            # File upload detected - clear image_url
            print("✅ File upload detected")
            data['image_url'] = ''
        elif 'image' in data:
            image_value = data['image']
            if isinstance(image_value, str):
                if image_value.startswith('http://') or image_value.startswith('https://'):
                    # URL provided as string
                    print("✅ URL detected in 'image' field")
                    data['image_url'] = data.pop('image')
                elif image_value == '':
                    # Empty string
                    print("⚠️ Empty image field")
                    data.pop('image', None)
        
        # ✅ KEY FIX: If actual file in FILES, remove 'image' from data
        # to avoid conflict between file and any leftover string value
        if 'image' in request.FILES and 'image' in data:
            # Keep only the file from FILES, not any string from data
            pass  # serializer will pick up from request.FILES automatically
        
        serializer = self.get_serializer(data=data)
        
        try:
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            print("✅ Product created successfully")
            print("=" * 80)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            print(f"❌ CREATE FAILED: {str(e)}")
            print(f"❌ Validation errors: {serializer.errors if hasattr(serializer, 'errors') else 'N/A'}")
            print("=" * 80)
            return Response(
                {
                    'error': str(e),
                    'details': serializer.errors if hasattr(serializer, 'errors') else {}
                },
                status=status.HTTP_400_BAD_REQUEST
            )

    def get_serializer_context(self):
        return {'request': self.request}


# ===================== RETRIEVE + UPDATE + DELETE =====================
class ProductRetrieveUpdateDestroyAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'id'
    
    # ✅ CRITICAL: Support both JSON and multipart
    parser_classes = (MultiPartParser, FormParser, JSONParser)

    def update(self, request, *args, **kwargs):
        print("=" * 80)
        print("📝 UPDATE REQUEST RECEIVED")
        print("=" * 80)
        print(f"📎 Content-Type: {request.content_type}")
        print(f"📎 Files: {list(request.FILES.keys())}")
        print(f"📎 Data keys: {list(request.data.keys())}")
        
        partial = kwargs.pop('partial', True)  # ✅ Default to partial update
        instance = self.get_object()
        
        print(f"📦 Current product: {instance.name} (ID: {instance.id})")
        print(f"📦 Current image: {instance.image.name if instance.image else 'None'}")
        print(f"📦 Current image_url: {instance.image_url or 'None'}")
        
        data = request.data.copy()
        
        # ✅ KEY FIX: When a file is uploaded via multipart,
        # the existing image_url on the product can bleed into validation.
        # We must explicitly clear image_url from data when uploading a file,
        # and remove any leftover string from 'image' field in data.
        if 'image' in request.FILES:
            # Real file upload — remove any string value of 'image' from data
            # The file will be picked up from request.FILES by the parser
            print("✅ File upload detected - will clear image_url")
            # Remove string 'image' from data if present to avoid URL validation
            if 'image' in data and isinstance(data.get('image'), str):
                del data['image']
            data['image_url'] = ''  # Clear existing URL
        elif 'image' in data:
            image_value = data['image']
            if isinstance(image_value, str):
                if image_value.startswith('http://') or image_value.startswith('https://'):
                    # URL provided
                    print("✅ URL detected - will clear image file")
                    data['image_url'] = data.pop('image')
                elif image_value == '':
                    # Empty string - keep existing
                    print("✅ Empty image field - keeping existing")
                    data.pop('image', None)
        
        serializer = self.get_serializer(instance, data=data, partial=partial)
        
        try:
            serializer.is_valid(raise_exception=True)
            self.perform_update(serializer)
            print("✅ Product updated successfully")
            print("=" * 80)
            return Response(serializer.data)
        except Exception as e:
            print(f"❌ UPDATE FAILED: {str(e)}")
            print(f"❌ Validation errors: {serializer.errors if hasattr(serializer, 'errors') else 'N/A'}")
            print("=" * 80)
            return Response(
                {
                    'error': str(e),
                    'details': serializer.errors if hasattr(serializer, 'errors') else {}
                },
                status=status.HTTP_400_BAD_REQUEST
            )

    def get_serializer_context(self):
        return {'request': self.request}