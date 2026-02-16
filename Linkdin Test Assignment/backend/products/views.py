# products/views.py - UPDATED WITH MULTIPART SUPPORT

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
        print("📥 Received data:", request.data)
        print("📎 Files:", request.FILES)
        
        # Handle file upload
        data = request.data.copy()
        
        # If image file is uploaded, clear image_url
        if 'image' in request.FILES:
            data['image_url'] = None
        # If image_url is provided as string, clear image file
        elif 'image' in data and isinstance(data['image'], str):
            data['image_url'] = data.pop('image')
        
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)

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
        print("📝 Update data:", request.data)
        print("📎 Update files:", request.FILES)
        
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        
        data = request.data.copy()
        
        # Handle file upload
        if 'image' in request.FILES:
            data['image_url'] = None  # Clear URL when file is uploaded
        elif 'image' in data and isinstance(data['image'], str):
            # URL provided
            data['image_url'] = data.pop('image')
        
        serializer = self.get_serializer(instance, data=data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        return Response(serializer.data)

    def get_serializer_context(self):
        return {'request': self.request}