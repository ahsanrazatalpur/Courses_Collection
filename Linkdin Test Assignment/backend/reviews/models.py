# reviews/models.py - FIXED VERSION

from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
from products.models import Product
from orders.models import Order


class Review(models.Model):
    """
    Product review model with verified purchase support and edit tracking
    """
    
    # ================= RELATIONSHIPS =================
    product = models.ForeignKey(
        Product,
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    
    order = models.ForeignKey(
        Order,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviews',
        help_text="Link to the order for verified purchase badge"
    )
    
    # ================= RATING & CONTENT =================
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Star rating from 1-5"
    )
    
    title = models.CharField(
        max_length=200,
        blank=True,
        null=True,
        help_text="Optional review title"
    )
    
    comment = models.TextField(
        help_text="Review text content"
    )
    
    # ================= TIMESTAMPS & EDIT TRACKING =================
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_edited = models.BooleanField(default=False)
    
    # ================= META =================
    class Meta:
        ordering = ['-created_at']
        unique_together = ['product', 'user']  # One review per user per product
        indexes = [
            models.Index(fields=['product', '-created_at']),
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['rating']),
        ]
    
    # ================= METHODS =================
    def __str__(self):
        return f"{self.user.username} - {self.product.name} ({self.rating}★)"
    
    @property
    def is_verified_purchase(self):
        """Check if this review is from a verified purchase"""
        return (
            self.order is not None and 
            self.order.status == "Delivered"
        )
    
    @property
    def user_display_name(self):
        """Get display name for the reviewer"""
        user = self.user
        if user.first_name and user.last_name:
            return f"{user.first_name} {user.last_name}"
        elif user.first_name:
            return user.first_name
        return user.username
    
    @property
    def likes_count(self):
        """Get total number of likes"""
        return self.likes.count()
    
    def save(self, *args, **kwargs):
        """Override save to validate order eligibility and track edits"""
        
        # ✅ FIX: Track if this is an edit
        if self.pk:
            try:
                original = Review.objects.get(pk=self.pk)
                if (original.comment != self.comment or 
                    original.rating != self.rating or 
                    original.title != self.title):
                    self.is_edited = True
            except Review.DoesNotExist:
                pass
        
        # ✅ FIX: If no order provided, find a delivered order for this product
        if not self.order:
            self.order = Order.objects.filter(
                user=self.user,
                items__product=self.product,
                status="Delivered"
            ).first()
        
        # ✅ FIX: Only validate order if one is set
        if self.order and self.order.status != "Delivered":
            raise ValueError("Can only review products from delivered orders")
        
        super().save(*args, **kwargs)
        
        # Update product average rating after save
        self.product.update_average_rating()


class ReviewLike(models.Model):
    """
    Likes on reviews - users can like any review
    """
    review = models.ForeignKey(
        Review,
        on_delete=models.CASCADE,
        related_name='likes'
    )
    
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='review_likes'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ['review', 'user']  # One like per user per review
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['review', 'user']),
        ]
    
    def __str__(self):
        return f"{self.user.username} likes review #{self.review.id}"