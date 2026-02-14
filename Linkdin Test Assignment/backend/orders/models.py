from django.db import models
from django.conf import settings
from products.models import Product
from coupons.models import Coupon
from django.utils import timezone


class Order(models.Model):

    # ================= ORDER STATUS =================
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Processing', 'Processing'),
        ('Shipped', 'Shipped'),
        ('Out for Delivery', 'Out for Delivery'),
        ('Delivered', 'Delivered'),
        ('Cancelled', 'Cancelled'),
    ]

    # ================= PAYMENT STATUS =================
    PAYMENT_STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Paid', 'Paid'),
        ('Failed', 'Failed'),
        ('Refunded', 'Refunded'),
    ]

    # ================= BASIC INFO =================
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='orders'
    )

    full_name = models.CharField(max_length=255)
    email = models.EmailField()

    # ================= SHIPPING ADDRESS =================
    phone = models.CharField(max_length=20, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    city = models.CharField(max_length=150, blank=True, null=True)
    state = models.CharField(max_length=150, blank=True, null=True)
    postal_code = models.CharField(max_length=20, blank=True, null=True)
    country = models.CharField(max_length=150, blank=True, null=True)

    # ================= ORDER DETAILS =================
    status = models.CharField(
        max_length=30,
        choices=STATUS_CHOICES,
        default='Pending'
    )

    payment_status = models.CharField(
        max_length=20,
        choices=PAYMENT_STATUS_CHOICES,
        default='Pending'
    )

    total_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0
    )

    # ================= COUPON SUPPORT =================
    coupon = models.ForeignKey(
        Coupon,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    discount_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0
    )

    # ================= SHIPPING INFO =================
    tracking_number = models.CharField(
        max_length=100,
        blank=True,
        null=True
    )

    estimated_delivery = models.DateField(
        blank=True,
        null=True
    )

    # ================= TIMESTAMPS =================
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # ================= STRING REPRESENTATION =================
    def __str__(self):
        return f"Order #{self.id} - {self.full_name} - {self.status}"

    # ================= HELPER: IS DELIVERED =================
    def is_delivered(self):
        return self.status == "Delivered"

    # ================= HELPER: IS CANCELLED =================
    def is_cancelled(self):
        return self.status == "Cancelled"


class OrderItem(models.Model):

    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name='items'
    )

    product = models.ForeignKey(
        Product,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    product_name = models.CharField(
        max_length=255,
        blank=True,
        null=True
    )

    quantity = models.PositiveIntegerField(default=1)

    price = models.DecimalField(
        max_digits=10,
        decimal_places=2
    )  # price at order time

    def save(self, *args, **kwargs):
        if self.product and not self.product_name:
            self.product_name = self.product.name
        super().save(*args, **kwargs)

    def __str__(self):
        name = self.product_name if self.product_name else "Deleted Product"
        return f"{self.quantity} x {name} (Order #{self.order.id})"
