from pathlib import Path
import os
from datetime import timedelta

# =============================
# Base directories
# =============================
BASE_DIR = Path(__file__).resolve().parent.parent

# =============================
# Security
# =============================
SECRET_KEY = 'django-insecure-7!#h1@+%*!dp5m$$(yi7gg472*q25vme%ke$1hqg4^p^5b#m%_'
DEBUG = True  # Keep True for local dev
ALLOWED_HOSTS = ['127.0.0.1', 'localhost']  # Add your domain for production

# =============================
# Installed apps
# =============================
INSTALLED_APPS = [
    # Django default apps
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party apps
    'rest_framework',
    'rest_framework.authtoken',
    'rest_framework_simplejwt',

    # Your project apps
    'products',
    'cart',
    'orders',
    'coupons',
    'dashboard',
    'users',
]

# =============================
# Middleware
# =============================
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# =============================
# URL Configuration
# =============================
ROOT_URLCONF = 'backend.urls'

# =============================
# Templates
# =============================
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# =============================
# WSGI Application
# =============================
WSGI_APPLICATION = 'backend.wsgi.application'

# =============================
# Database (SQLite for development)
# =============================
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# =============================
# Password validation
# =============================
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# =============================
# Internationalization
# =============================
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# =============================
# Static & media files
# =============================
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# =============================
# Default primary key field
# =============================
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# =============================
# Django REST Framework + JWT
# =============================
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',  # Require auth by default
    ),
}

# JWT Settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
    'AUTH_HEADER_TYPES': ('Bearer',),  # Important for "Authorization: Bearer <token>"
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# =============================
# Optional: Custom user model (if you create one)
# =============================
# AUTH_USER_MODEL = 'users.CustomUser'
