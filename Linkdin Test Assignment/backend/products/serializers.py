# products/serializers.py - FIXED WITH REVIEW FIELDS

from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    # Derived field to always return a usable image URL
    image_url = serializers.SerializerMethodField()
    
    # Stock status fields
    stock_status = serializers.SerializerMethodField()
    is_in_stock = serializers.SerializerMethodField()
    is_low_stock = serializers.SerializerMethodField()
    is_out_of_stock = serializers.SerializerMethodField()
    
    # ✅ CRITICAL: Include review fields from model
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
            'image', 
            'image_url', 
            'created_at', 
            'stock_status', 
            'is_in_stock', 
            'is_low_stock', 
            'is_out_of_stock',
            'average_rating',  # ✅ ADDED
            'review_count',    # ✅ ADDED
        ]
        read_only_fields = ['id', 'created_at', 'average_rating', 'review_count']

    def get_image_url(self, obj):
        """Returns a usable URL for the image"""
        if obj.image:
            if obj.image.startswith("http://") or obj.image.startswith("https://"):
                return obj.image
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image)
        return ""
    
    def get_stock_status(self, obj):
        return obj.get_stock_status()
    
    def get_is_in_stock(self, obj):
        return obj.is_in_stock()
    
    def get_is_low_stock(self, obj):
        return obj.is_low_stock()
    
    def get_is_out_of_stock(self, obj):
        return obj.is_out_of_stock()

    def validate_image(self, value):
        if value and len(value) > 2000:
            raise serializers.ValidationError(
                "Image URL cannot exceed 2000 characters."
            )
        return value