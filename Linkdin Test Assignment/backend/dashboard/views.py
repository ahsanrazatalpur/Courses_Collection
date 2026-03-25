# dashboard/views.py - FULL CRUD: Coupons + Users + Reviews

from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib import messages

from products.models import Product
from orders.models import Order
from coupons.models import Coupon
from users.models import User
from reviews.models import Review


def is_admin(user):
    return user.is_authenticated and user.is_staff

def admin_required(view_func):
    decorated = user_passes_test(is_admin, login_url='/dashboard/login/')(view_func)
    return login_required(decorated, login_url='/dashboard/login/')


# ══════════════════════════════════════════════
# AUTH
# ══════════════════════════════════════════════

def admin_login(request):
    if request.user.is_authenticated and request.user.is_staff:
        return redirect('dashboard_home')
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user and user.is_staff:
            login(request, user)
            return redirect('dashboard_home')
        else:
            messages.error(request, 'Invalid credentials or not an admin.')
    return render(request, 'dashboard/login.html')


def admin_logout(request):
    logout(request)
    return redirect('admin_login')


# ══════════════════════════════════════════════
# HOME
# ══════════════════════════════════════════════

@admin_required
def dashboard_home(request):
    all_products = Product.objects.all()
    context = {
        'total_products': all_products.count(),
        'in_stock':       all_products.filter(stock__gte=10).count(),
        'low_stock':      all_products.filter(stock__gt=0, stock__lt=10).count(),
        'out_of_stock':   all_products.filter(stock=0).count(),
        'total_orders':   Order.objects.count(),
        'total_coupons':  Coupon.objects.count(),
        'total_users':    User.objects.count(),
        'total_reviews':  Review.objects.count(),
        'pending_orders': Order.objects.filter(status='pending').count(),
        'recent_orders':  Order.objects.select_related('user', 'coupon').order_by('-created_at')[:5],
    }
    return render(request, 'dashboard/home.html', context)


# ══════════════════════════════════════════════
# PRODUCTS
# ══════════════════════════════════════════════

@admin_required
def product_list(request):
    products = Product.objects.all().order_by('-id')
    return render(request, 'dashboard/products/list.html', {'products': products})


@admin_required
def product_add(request):
    if request.method == 'POST':
        try:
            Product.objects.create(
                name=request.POST.get('name'),
                description=request.POST.get('description'),
                price=request.POST.get('price'),
                stock=request.POST.get('stock'),
                image=request.FILES.get('image'),
            )
            messages.success(request, 'Product added successfully!')
            return redirect('product_list')
        except Exception as e:
            messages.error(request, f'Error adding product: {str(e)}')
    return render(request, 'dashboard/products/form.html', {'action': 'Add'})


@admin_required
def product_edit(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        try:
            product.name        = request.POST.get('name')
            product.description = request.POST.get('description')
            product.price       = request.POST.get('price')
            product.stock       = request.POST.get('stock')
            if request.FILES.get('image'):
                product.image = request.FILES.get('image')
            product.save()
            messages.success(request, 'Product updated successfully!')
            return redirect('product_list')
        except Exception as e:
            messages.error(request, f'Error updating product: {str(e)}')
    return render(request, 'dashboard/products/form.html', {'action': 'Edit', 'product': product})


@admin_required
def product_delete(request, pk):
    product = get_object_or_404(Product, pk=pk)
    if request.method == 'POST':
        product.delete()
        messages.success(request, 'Product deleted successfully!')
    return redirect('product_list')


# ══════════════════════════════════════════════
# ORDERS
# ══════════════════════════════════════════════

@admin_required
def order_list(request):
    status_filter = request.GET.get('status', '')
    orders = Order.objects.select_related('user', 'coupon').order_by('-created_at')
    if status_filter:
        orders = orders.filter(status=status_filter)
    return render(request, 'dashboard/orders/list.html', {
        'orders': orders,
        'status_filter': status_filter,
    })


@admin_required
def order_detail(request, pk):
    order = get_object_or_404(
        Order.objects.select_related('user', 'coupon').prefetch_related('items__product'),
        pk=pk
    )
    return render(request, 'dashboard/orders/detail.html', {'order': order})


@admin_required
def order_update_status(request, pk):
    order = get_object_or_404(Order, pk=pk)
    if request.method == 'POST':
        new_status = request.POST.get('status')
        if new_status in ['pending', 'shipped', 'cancelled', 'Delivered']:
            order.status = new_status
            order.save()
            messages.success(request, f'Order #{order.id} updated to "{new_status}".')
        else:
            messages.error(request, 'Invalid status.')
    return redirect('order_detail', pk=pk)


# ══════════════════════════════════════════════
# COUPONS - FULL CRUD
# ══════════════════════════════════════════════

@admin_required
def coupon_list(request):
    coupons = Coupon.objects.all().order_by('-id')
    return render(request, 'dashboard/coupons/list.html', {'coupons': coupons})


@admin_required
def coupon_add(request):
    if request.method == 'POST':
        try:
            code = request.POST.get('code', '').strip().upper()
            if Coupon.objects.filter(code=code).exists():
                messages.error(request, f'Coupon code "{code}" already exists.')
                return render(request, 'dashboard/coupons/form.html', {'action': 'Add'})

            usage_limit = request.POST.get('usage_limit', '').strip()
            Coupon.objects.create(
                code=code,
                discount_type=request.POST.get('discount_type'),
                discount_value=request.POST.get('discount_value'),
                minimum_cart_value=request.POST.get('minimum_cart_value') or 0,
                start_date=request.POST.get('start_date'),
                end_date=request.POST.get('end_date'),
                usage_limit=int(usage_limit) if usage_limit else None,
                is_active=request.POST.get('is_active') == 'on',
            )
            messages.success(request, f'Coupon "{code}" created successfully!')
            return redirect('coupon_list')
        except Exception as e:
            messages.error(request, f'Error creating coupon: {str(e)}')
    return render(request, 'dashboard/coupons/form.html', {'action': 'Add'})


@admin_required
def coupon_edit(request, pk):
    coupon = get_object_or_404(Coupon, pk=pk)
    if request.method == 'POST':
        try:
            code = request.POST.get('code', '').strip().upper()
            if Coupon.objects.filter(code=code).exclude(pk=pk).exists():
                messages.error(request, f'Coupon code "{code}" already exists.')
                return render(request, 'dashboard/coupons/form.html', {'action': 'Edit', 'coupon': coupon})

            usage_limit = request.POST.get('usage_limit', '').strip()
            coupon.code               = code
            coupon.discount_type      = request.POST.get('discount_type')
            coupon.discount_value     = request.POST.get('discount_value')
            coupon.minimum_cart_value = request.POST.get('minimum_cart_value') or 0
            coupon.start_date         = request.POST.get('start_date')
            coupon.end_date           = request.POST.get('end_date')
            coupon.usage_limit        = int(usage_limit) if usage_limit else None
            coupon.is_active          = request.POST.get('is_active') == 'on'
            coupon.save()
            messages.success(request, f'Coupon "{code}" updated successfully!')
            return redirect('coupon_list')
        except Exception as e:
            messages.error(request, f'Error updating coupon: {str(e)}')
    return render(request, 'dashboard/coupons/form.html', {'action': 'Edit', 'coupon': coupon})


@admin_required
def coupon_delete(request, pk):
    coupon = get_object_or_404(Coupon, pk=pk)
    if request.method == 'POST':
        code = coupon.code
        coupon.delete()
        messages.success(request, f'Coupon "{code}" deleted successfully!')
    return redirect('coupon_list')


# ══════════════════════════════════════════════
# USERS - FULL MANAGEMENT
# ══════════════════════════════════════════════

@admin_required
def user_list(request):
    users = User.objects.all().order_by('-id')
    return render(request, 'dashboard/users/list.html', {'users': users})


@admin_required
def user_toggle_block(request, pk):
    user = get_object_or_404(User, pk=pk)
    if request.method == 'POST':
        if user.id == request.user.id:
            messages.error(request, 'You cannot block your own account.')
            return redirect('user_list')
        user.is_blocked = not user.is_blocked
        user.save()
        action = 'blocked' if user.is_blocked else 'unblocked'
        messages.success(request, f'User "{user.username}" has been {action}.')
    return redirect('user_list')


@admin_required
def user_change_role(request, pk):
    user = get_object_or_404(User, pk=pk)
    if request.method == 'POST':
        if user.id == request.user.id:
            messages.error(request, 'You cannot change your own role.')
            return redirect('user_list')
        new_role = request.POST.get('role')
        if new_role in ['admin', 'user']:
            user.role = new_role
            user.is_staff = new_role == 'admin'
            user.save()
            messages.success(request, f'User "{user.username}" role changed to {new_role}.')
        else:
            messages.error(request, 'Invalid role.')
    return redirect('user_list')


@admin_required
def user_delete(request, pk):
    user = get_object_or_404(User, pk=pk)
    if request.method == 'POST':
        if user.id == request.user.id:
            messages.error(request, 'You cannot delete your own account.')
            return redirect('user_list')
        username = user.username
        user.delete()
        messages.success(request, f'User "{username}" deleted permanently.')
    return redirect('user_list')


# ══════════════════════════════════════════════
# REVIEWS - VIEW + DELETE
# ══════════════════════════════════════════════

@admin_required
def review_list(request):
    filter_type = request.GET.get('filter', 'all')
    reviews = Review.objects.select_related('user', 'product').order_by('-created_at')
    if filter_type == 'flagged':
        reviews = reviews.filter(rating__lte=2)
    return render(request, 'dashboard/reviews/list.html', {
        'reviews': reviews,
        'filter_type': filter_type,
        'total_reviews': Review.objects.count(),
        'flagged_count': Review.objects.filter(rating__lte=2).count(),
    })


@admin_required
def review_delete(request, pk):
    review = get_object_or_404(Review, pk=pk)
    if request.method == 'POST':
        review.delete()
        messages.success(request, 'Review deleted successfully.')
    return redirect('review_list')