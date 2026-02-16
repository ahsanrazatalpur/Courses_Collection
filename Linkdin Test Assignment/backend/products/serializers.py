# products/serializers.py - FIXED WITH DUAL IMAGE SUPPORT

from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    # ✅ Make image field optional and handle both file & URL
    image = serializers.ImageField(required=False, allow_null=True)
    image_url = serializers.URLField(required=False, allow_blank=True, allow_null=True)
    
    # Computed field for frontend - THIS IS WHAT FLUTTER WILL USE
    image_display = serializers.SerializerMethodField()
    
    # Stock status fields
    stock_status = serializers.SerializerMethodField()
    is_in_stock = serializers.SerializerMethodField()
    is_low_stock = serializers.SerializerMethodField()
    is_out_of_stock = serializers.SerializerMethodField()
    
    # Review fields
    average_rating = serializers.DecimalField(
        max_digits=3, 
        decimal_places=1, 
        read_only=True
    )
    review_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 
            'name', 
            'description', 
            'price', 
            'stock', 
            'image',           # File upload field
            'image_url',       # URL string field
            'image_display',   # ✅ Computed field for frontend
            'created_at', 
            'stock_status', 
            'is_in_stock', 
            'is_low_stock', 
            'is_out_of_stock',
            'average_rating',
            'review_count',
        ]
        read_only_fields = ['id', 'created_at', 'average_rating', 'review_count', 'image_display']

    def get_image_display(self, obj):
        """Returns the actual image URL to display"""
        request = self.context.get('request')
        
        # Priority: uploaded file > URL string
        if obj.image:
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        elif obj.image_url:
            return obj.image_url
        return ""
    
    def get_stock_status(self, obj):
        return obj.get_stock_status()
    
    def get_is_in_stock(self, obj):
        return obj.is_in_stock()
    
    def get_is_low_stock(self, obj):
        return obj.is_low_stock()
    
    def get_is_out_of_stock(self, obj):
        return obj.is_out_of_stock()

    def validate(self, data):
        """Ensure either image file or image_url is provided"""
        image = data.get('image')
        image_url = data.get('image_url')
        
        # At least one must be provided for new products
        if not self.instance and not image and not image_url:
            raise serializers.ValidationError(
                "Either 'image' file or 'image_url' must be provided."
            )
        
        return data