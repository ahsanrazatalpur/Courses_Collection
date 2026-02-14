# products/models.py - UPDATED WITH REVIEW FIELDS

from django.db import models

class Product(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.PositiveIntegerField(default=0)
    image = models.URLField(max_length=2000, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    # ✅ REVIEW FIELDS ADDED
    average_rating = models.DecimalField(
        max_digits=3,
        decimal_places=1,
        default=0,
        help_text="Average star rating"
    )
    
    review_count = models.PositiveIntegerField(
        default=0,
        help_text="Total number of reviews"
    )

    def __str__(self):
        return self.name

    # ==================== STOCK STATUS METHODS ====================
    
    def get_stock_status(self):
        """Returns: 'out_of_stock', 'low_stock', or 'in_stock'"""
        if self.stock == 0:
            return 'out_of_stock'
        elif self.stock <= 5:
            return 'low_stock'
        else:
            return 'in_stock'
    
    def is_in_stock(self):
        """Check if product has any stock"""
        return self.stock > 0
    
    def is_low_stock(self):
        """Check if stock is low (1-5 items)"""
        return 0 < self.stock <= 5
    
    def is_out_of_stock(self):
        """Check if product is out of stock"""
        return self.stock == 0
    
    def reduce_stock(self, quantity):
        """Reduce stock by given quantity"""
        if self.stock >= quantity:
            self.stock -= quantity
            self.save()
            return True
        return False
    
    # ✅ REVIEW METHOD ADDED
    def update_average_rating(self):
        """
        Calculate and store average rating for this product
        """
        from django.db.models import Avg
        avg_rating = self.reviews.aggregate(Avg('rating'))['rating__avg']
        self.average_rating = round(avg_rating, 1) if avg_rating else 0
        self.review_count = self.reviews.count()
        self.save(update_fields=['average_rating', 'review_count'])