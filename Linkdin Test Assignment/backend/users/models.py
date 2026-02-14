# users/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    ROLE_CHOICES = (
        ('user', 'User'),
        ('admin', 'Admin'),
    )

    role = models.CharField(
        max_length=10,
        choices=ROLE_CHOICES,
        default='user'
    )
    is_blocked = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        """
        Automatically set is_staff based on role.
        """
        self.is_staff = True if self.role == 'admin' else False
        super().save(*args, **kwargs)

    def toggle_role(self):
        """
        Switch between 'user' and 'admin' role.
        """
        self.role = 'admin' if self.role == 'user' else 'user'
        self.save()

    def __str__(self):
        status = "Blocked" if self.is_blocked else "Active"
        return f"{self.username} ({self.role}, {status})"
