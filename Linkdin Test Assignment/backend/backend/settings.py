# backend/settings.py - UPDATED WITH POSTGRESQL + DJANGO JINJA ADMIN DASHBOARD

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
DEBUG = True

ALLOWED_HOSTS = ['127.0.0.1', 'localhost', '192.168.1.106', 'ahsanrazatalpur.pythonanywhere.com', '*']

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
    'corsheaders',

    # Project apps
    'products',
    'cart',
    'orders',
    'coupons',
    'dashboard',   # ✅ Django + Jinja admin dashboard
    'users',
    'reviews',
]

# =============================
# Middleware
# =============================
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Must be first
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
# Templates — Django + Jinja2 support
# =============================
TEMPLATES = [
    # ✅ Django template engine (used by admin and dashboard)
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
    # ✅ Jinja2 template engine (for custom admin dashboard views)
    {
        'BACKEND': 'django.template.backends.jinja2.Jinja2',
        'DIRS': [os.path.join(BASE_DIR, 'jinja2')],  # Put Jinja2 templates in /jinja2/ folder
        'APP_DIRS': False,
        'OPTIONS': {
            'environment': 'backend.jinja2.environment',  # custom jinja2 env (see note below)
            'extensions': [],
        },
    },
]

# =============================
# WSGI Application
# =============================
WSGI_APPLICATION = 'backend.wsgi.application'

# =============================
# ✅ FIX 1: Database — PostgreSQL (replaces SQLite)
# =============================
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'ecommerce_db',
        'USER': 'postgres',
        'PASSWORD': '@11770099',
        'HOST': 'localhost',
        'PORT': '5432',
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
# Static & Media
# =============================
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# ✅ Media files configuration
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# =============================
# Default PK
# =============================
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# =============================
# Django REST Framework
# =============================
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
}

# =============================
# JWT Configuration
# =============================
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# =============================
# CORS Settings
# =============================
CORS_ALLOW_ALL_ORIGINS = True  # Allows Flutter/web frontend
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_HEADERS = [
    'authorization',
    'content-type',
    'accept',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'content-disposition',  # ✅ For file uploads
]
CORS_ALLOW_METHODS = ['DELETE', 'GET', 'OPTIONS', 'PATCH', 'POST', 'PUT']

# ✅ File upload settings
FILE_UPLOAD_MAX_MEMORY_SIZE = 10485760  # 10MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 10485760  # 10MB

# =============================
# Custom User Model
# =============================
AUTH_USER_MODEL = 'users.User'

# =============================
# ✅ FIX 2: Login redirect for Django dashboard
# =============================
LOGIN_URL = '/admin/login/'  # Redirect to Django admin login if not authenticated