# backend/jinja2.py
# ✅ Required Jinja2 environment setup referenced in settings.py TEMPLATES config

from django.templatetags.static import static
from django.urls import reverse
from jinja2 import Environment


def environment(**options):
    """
    Custom Jinja2 environment that adds Django helpers like
    static() and url() so they work inside .jinja2 templates.
    """
    env = Environment(**options)
    env.globals.update({
        'static': static,
        'url': reverse,
    })
    return env