from django.db import models
from products.models import Product
from django.utils import timezone

class Coupon(models.Model):
    DISCOUNT_TYPE_CHOICES = [
        ('percentage', 'Percentage'),
        ('flat', 'Flat Amount'),
    ]

    code = models.CharField(max_length=50, unique=True)
    discount_type = models.CharField(max_length=20, choices=DISCOUNT_TYPE_CHOICES)
    discount_value = models.DecimalField(max_digits=10, decimal_places=2)
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    minimum_cart_value = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    usage_limit = models.PositiveIntegerField(null=True, blank=True)
    applicable_products = models.ManyToManyField(Product, blank=True)
    is_active = models.BooleanField(default=True)
    times_used = models.PositiveIntegerField(default=0)  # track usage count

    def __str__(self):
        return self.code

    def is_valid_for_cart(self, cart):
        """
        Checks if coupon is currently valid and can be applied to this cart.
        Returns True/False.
        """
        now = timezone.now()

        if not self.is_active or self.start_date > now or self.end_date < now:
            return False

        cart_total = sum(item.product.price * item.quantity for item in cart.items.all())
        if cart_total < self.minimum_cart_value:
            return False

        if self.usage_limit is not None and self.times_used >= self.usage_limit:
            return False

        if self.applicable_products.exists():
            applicable_product_ids = self.applicable_products.values_list('id', flat=True)
            cart_product_ids = [item.product.id for item in cart.items.all()]
            if not any(pid in applicable_product_ids for pid in cart_product_ids):
                return False

        return True

    def apply_discount(self, cart_total):
        if self.discount_type == 'percentage':
            return cart_total - (cart_total * self.discount_value / 100)
        elif self.discount_type == 'flat':
            return max(cart_total - self.discount_value, 0)
        return cart_total
