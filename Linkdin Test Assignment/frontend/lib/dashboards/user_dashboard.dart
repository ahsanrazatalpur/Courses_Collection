// lib/dashboards/user_dashboard.dart
// ✅ FINAL: Cart + Buy always visible | Cart badge (x / 0) | Reviews always shown | No overflow

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../screens/checkout_screen.dart';
import '../pages/order_history_screen.dart';
import '../pages/my_reviews_page.dart';
import '../pages/product_reviews_page.dart';
import '../helpers/top_popup.dart';
import '../pages/login.dart';
import '../pages/cart_page.dart';
import '../widgets/footer_widget.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class UserDashboard extends StatefulWidget {
  final String token;
  final String username;

  const UserDashboard({
    super.key,
    required this.token,
    required this.username,
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Product> products  = [];
  List<CartItem> cartItems = [];
  List<Order> userOrders  = [];
  bool _isLoading = true;

  late String _loginUsername;

  int _newOrderUpdates    = 0;
  int _pendingReviewsCount = 0;
  Timer? _orderCheckTimer;
  Timer? _reviewCheckTimer;
  Map<int, String> _lastKnownOrderStatus = {};

  int _sliderIndex = 0;
  Timer? _sliderTimer;

  // ─── Color Palette ────────────────────────────────────────────────────────────
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen   = Color(0xFF4CAF50);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color lightGrey     = Color(0xFFF5F5F5);
  static const Color cardGrey      = Color(0xFFFAFAFA);
  static const Color mediumGrey    = Color(0xFF9E9E9E);
  static const Color darkGrey      = Color(0xFF424242);
  static const Color borderGrey    = Color(0xFFE0E0E0);

  final List<String> sliderImages = [
    "https://images.unsplash.com/photo-1607082350899-7e105aa886ae?q=80&w=1600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1441986300917-64674bd600d8?q=80&w=1600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=1600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1607083206325-caf1edba7a0f?q=80&w=1600&auto=format&fit=crop",
  ];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loginUsername = widget.username;
    fetchProducts();
    fetchCart();
    _initializeOrderTracking();
    _checkPendingReviews();
    _startAutoSlider();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _orderCheckTimer?.cancel();
    _reviewCheckTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlider() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_sliderIndex + 1) % sliderImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        setState(() => _sliderIndex = nextPage);
      }
    });
  }

  Future<void> _checkPendingReviews() async {
    try {
      final pending = await ApiService.fetchPendingReviews(token: widget.token);
      if (!mounted) return;
      setState(() => _pendingReviewsCount = pending.length);
      final productIds  = pending.map((p) => p.id).toList();
      final productNames = Map.fromEntries(pending.map((p) => MapEntry(p.id, p.name)));
      await NotificationService.checkReviewReminders(productIds, productNames);
    } catch (e) { debugPrint("Error checking pending reviews: $e"); }
    _reviewCheckTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) _checkPendingReviews();
    });
  }

  Future<void> _initializeOrderTracking() async {
    await _loadLastKnownStatuses();
    await _checkForOrderUpdates();
    _orderCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) { if (mounted) _checkForOrderUpdates(); },
    );
  }

  Future<void> _loadLastKnownStatuses() async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final statusJson = prefs.getString('last_order_statuses');
      if (statusJson != null && statusJson.isNotEmpty) {
        final decoded = Map.fromEntries(
          statusJson.split('||').where((e) => e.isNotEmpty).map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], parts[1]);
          }),
        );
        _lastKnownOrderStatus = decoded.map((k, v) => MapEntry(int.parse(k), v.toString()));
      }
    } catch (e) { debugPrint("Error loading order statuses: $e"); }
  }

  Future<void> _saveLastKnownStatuses() async {
    try {
      final prefs        = await SharedPreferences.getInstance();
      final statusString = _lastKnownOrderStatus.entries.map((e) => '${e.key}:${e.value}').join('||');
      await prefs.setString('last_order_statuses', statusString);
    } catch (e) { debugPrint("Error saving order statuses: $e"); }
  }

  Future<void> _checkForOrderUpdates() async {
    try {
      final orders = await ApiService.fetchOrders(token: widget.token);
      if (!mounted) return;
      int newUpdates = 0;
      for (final order in orders) {
        if (order.id == null) continue;
        final orderId      = order.id!;
        final currentStatus = order.status;
        final lastStatus   = _lastKnownOrderStatus[orderId];
        if (lastStatus != null && lastStatus != currentStatus) {
          newUpdates++;
          if (currentStatus == "Delivered") _checkPendingReviews();
        }
        _lastKnownOrderStatus[orderId] = currentStatus;
      }
      setState(() { userOrders = orders; _newOrderUpdates = newUpdates; });
      await _saveLastKnownStatuses();
    } catch (e) { debugPrint("Error checking order updates: $e"); }
  }

  void _clearOrderNotifications() => setState(() => _newOrderUpdates = 0);

  Future<void> fetchProducts() async {
    try {
      final response = await ApiService.fetchProducts(token: widget.token);
      if (!mounted) return;
      setState(() { products = response; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      TopPopup.show(context, 'Failed to load products', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchCart() async {
    try {
      final response = await ApiService.fetchCart(token: widget.token);
      if (!mounted) return;
      setState(() => cartItems = response);
    } catch (_) {}
  }

  Future<void> addToCart(Product product) async {
    if (product.stock == 0) {
      TopPopup.show(context, "This product is out of stock!", Colors.red);
      return;
    }
    final index = cartItems.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      final existing = cartItems[index];
      if (existing.quantity + 1 > product.stock) {
        TopPopup.show(context, "Only ${product.stock} items available!", Colors.orange);
        return;
      }
      final updated = CartItem(
        id: existing.id,
        productId: existing.productId,
        productName: existing.productName,
        price: existing.price,
        quantity: existing.quantity + 1,
        image: existing.image,
      );
      cartItems[index] = updated;
      await ApiService.addToCart(productId: existing.productId, quantity: updated.quantity, token: widget.token);
      TopPopup.show(context, "${existing.productName} quantity updated!", accentGreen);
      setState(() {});
      return;
    }
    final success = await ApiService.addToCart(
      productId: product.id!, quantity: 1, token: widget.token);
    if (success) {
      cartItems.add(CartItem(
        id: 0, productId: product.id!, productName: product.name,
        price: product.price, quantity: 1, image: product.image ?? '',
      ));
      TopPopup.show(context, "${product.name} added to cart!", accentGreen);
      setState(() {});
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryIndigo,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                SizedBox(height: 16),
                Text("Logging out...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  // ─── Hover Button ─────────────────────────────────────────────────────────────
  Widget hoverButton({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    EdgeInsets? padding,
    bool disabled = false,
  }) {
    return StatefulBuilder(builder: (ctx, setHover) {
      bool hovered = false;
      return MouseRegion(
        cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) { if (!disabled) setHover(() => hovered = true); },
        onExit:  (_) => setHover(() => hovered = false),
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: disabled ? mediumGrey : hovered ? accentGreen : (color ?? primaryIndigo),
              borderRadius: BorderRadius.circular(8),
              boxShadow: hovered && !disabled
                  ? [BoxShadow(color: accentGreen.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Center(child: child),
          ),
        ),
      );
    });
  }

  Widget buildProductImage(String? url, {double height = 100, bool isSmall = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        width: double.infinity,
        color: lightGrey,
        child: url == null || url.isEmpty
            ? Icon(Icons.shopping_bag_outlined, size: isSmall ? 50 : 70, color: mediumGrey)
            : Image.network(url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.shopping_bag_outlined, size: isSmall ? 50 : 70, color: mediumGrey)),
      ),
    );
  }

  Widget navButton(IconData icon, String label, VoidCallback onTap, {int? badge, bool isSmall = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 2 : 4),
      child: hoverButton(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8, horizontal: isSmall ? 4 : 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: isSmall ? 16 : 20),
              if (!isSmall) ...[
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ]),
            if (badge != null && badge > 0)
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 2 : 3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: BoxConstraints(minWidth: isSmall ? 14 : 16, minHeight: isSmall ? 14 : 16),
                  child: Center(child: Text('$badge',
                      style: TextStyle(color: Colors.white, fontSize: isSmall ? 8 : 9, fontWeight: FontWeight.bold))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Top-of-card badges: Stock + Cart count ────────────────────────────────────
  // Shows stock status badge + cart pill with qty (0 if not in cart)
  Widget _buildTopBadges(int stock, int cartQty, bool isSmall) {
    // Stock badge
    final Color stockColor;
    final IconData stockIcon;
    if (stock == 0) {
      stockColor = Colors.red;
      stockIcon  = Icons.remove_shopping_cart;
    } else if (stock <= 5) {
      stockColor = Colors.orange;
      stockIcon  = Icons.warning;
    } else {
      stockColor = accentGreen;
      stockIcon  = Icons.check_circle;
    }

    // Cart badge: always visible, indigo with qty
    final cartColor = cartQty > 0 ? primaryIndigo : Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stock
        Container(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 5 : 6, vertical: isSmall ? 2 : 3),
          decoration: BoxDecoration(color: stockColor, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(stockIcon, color: Colors.white, size: isSmall ? 9 : 10),
            const SizedBox(width: 2),
            Text("$stock",
                style: TextStyle(color: Colors.white, fontSize: isSmall ? 8 : 9, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(width: 4),
        // Cart
        Container(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 5 : 6, vertical: isSmall ? 2 : 3),
          decoration: BoxDecoration(color: cartColor, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_cart, color: Colors.white, size: isSmall ? 9 : 10),
            const SizedBox(width: 2),
            Text("$cartQty",
                style: TextStyle(color: Colors.white, fontSize: isSmall ? 8 : 9, fontWeight: FontWeight.bold)),
          ]),
        ),
      ],
    );
  }

  // ─── Product Detail Modal ─────────────────────────────────────────────────────
  void showProductModal(Product product, bool isSmall) {
    final stock        = product.stock;
    final isOutOfStock = stock == 0;
    final reviewCount  = product.reviewCount;
    final avgRating    = product.averageRating;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: white,
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(builder: (context, setStateModal) {
          final cartIndex = cartItems.indexWhere((i) => i.productId == product.id);
          final cartQty   = cartIndex >= 0 ? cartItems[cartIndex].quantity : 0;
          return Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(isSmall ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(product.name,
                        style: TextStyle(fontSize: isSmall ? 16 : 20, fontWeight: FontWeight.bold, color: primaryIndigo),
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: darkGrey),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(children: [
                  buildProductImage(product.image, height: isSmall ? 140 : 180, isSmall: isSmall),
                  Positioned(top: 8, right: 8, child: _buildTopBadges(stock, cartQty, isSmall)),
                ]),
                const SizedBox(height: 12),
                Text("Rs ${product.price}",
                    style: TextStyle(fontSize: isSmall ? 18 : 22, color: primaryIndigo, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Rating - always show
                Row(children: [
                  Icon(reviewCount > 0 ? Icons.star : Icons.star_outline,
                      size: isSmall ? 14 : 16,
                      color: reviewCount > 0 ? Colors.amber : mediumGrey),
                  const SizedBox(width: 4),
                  Text(
                    reviewCount > 0
                        ? "$avgRating ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})"
                        : "No reviews yet",
                    style: TextStyle(fontSize: isSmall ? 11 : 13, color: darkGrey, fontWeight: FontWeight.w500),
                  ),
                ]),

                const SizedBox(height: 12),
                Text(product.description,
                    style: TextStyle(fontSize: isSmall ? 12 : 14, color: darkGrey),
                    maxLines: 4, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),

                // Reviews button (always visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: hoverButton(
                    color: Colors.deepPurple.shade400,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductReviewsPage(
                        productId: product.id!,
                        productName: product.name,
                        token: widget.token,
                        isAdmin: false,
                      )));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(reviewCount > 0 ? Icons.rate_review : Icons.rate_review_outlined,
                            size: isSmall ? 14 : 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          reviewCount > 0 ? "View Reviews ($reviewCount)" : "Reviews (0)",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: isSmall ? 13 : 15),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(children: [
                  Expanded(child: hoverButton(
                    onTap: isOutOfStock ? () {} : () { addToCart(product); Navigator.pop(context); },
                    color: isOutOfStock ? mediumGrey : primaryIndigo,
                    disabled: isOutOfStock,
                    child: Text(
                      isOutOfStock ? "Out of Stock" : "Add to Cart",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: isSmall ? 13 : 15),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: hoverButton(
                    onTap: isOutOfStock ? () {} : () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(
                        cart: [CartItem(id: 0, productId: product.id!, productName: product.name,
                            price: product.price, quantity: 1, image: product.image ?? '')],
                        token: widget.token,
                        isBuyNow: true,
                      )));
                    },
                    color: isOutOfStock ? mediumGrey : accentGreen,
                    disabled: isOutOfStock,
                    child: Text(
                      isOutOfStock ? "Unavailable" : "Buy Now",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: isSmall ? 13 : 15),
                    ),
                  )),
                ]),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Product Card (User) ──────────────────────────────────────────────────────
  // Fixed layout: image → name/price/reviews-row → Reviews btn → Cart | Buy
  // Cart badge always visible (0 or N); no overflow ever
  Widget buildProductCard(Product product, bool isSmall) {
    final cartIndex = cartItems.indexWhere((i) => i.productId == product.id);
    final cartQty   = cartIndex >= 0 ? cartItems[cartIndex].quantity : 0;
    final stock        = product.stock;
    final isOutOfStock = stock == 0;
    final reviewCount  = product.reviewCount;
    final avgRating    = product.averageRating;

    final imgH   = isSmall ? 110.0 : 140.0;
    final pad    = isSmall ? 10.0  : 12.0;
    final nameSz = isSmall ? 13.0  : 14.0;
    final prSz   = isSmall ? 13.0  : 14.0;
    final ratSz  = isSmall ? 10.0  : 11.0;
    final btnH   = isSmall ? 32.0  : 35.0;
    final btnSz  = isSmall ? 11.0  : 12.0;
    final iconSz = isSmall ? 12.0  : 13.0;

    return StatefulBuilder(builder: (context, setCardState) {
      bool hovered = false;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setCardState(() => hovered = true),
        onExit:  (_) => setCardState(() => hovered = false),
        child: GestureDetector(
          onTap: () => showProductModal(product, isSmall),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: Opacity(
              opacity: isOutOfStock ? 0.65 : 1.0,
              child: Card(
                elevation: hovered ? 7 : 2,
                shadowColor: primaryIndigo.withOpacity(hovered ? 0.25 : 0.08),
                color: hovered ? white : cardGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: hovered ? primaryIndigo.withOpacity(0.4) : borderGrey,
                    width: hovered ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Image ────────────────────────────────────────────────
                    Stack(children: [
                      SizedBox(
                        height: imgH,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: product.image != null && product.image!.isNotEmpty
                              ? Image.network(product.image!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: lightGrey,
                                    child: Icon(Icons.shopping_bag_outlined,
                                        size: isSmall ? 44 : 54, color: mediumGrey),
                                  ))
                              : Container(color: lightGrey,
                                  child: Icon(Icons.shopping_bag_outlined,
                                      size: isSmall ? 44 : 54, color: mediumGrey)),
                        ),
                      ),
                      // ✅ Both stock + cart badge always visible on top-right
                      Positioned(top: 7, right: 7, child: _buildTopBadges(stock, cartQty, isSmall)),
                    ]),

                    // ── Info + Buttons ────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: nameSz, color: darkGrey),
                            ),
                            const SizedBox(height: 3),

                            // Price
                            Text(
                              "Rs ${product.price}",
                              style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold, fontSize: prSz),
                            ),
                            const SizedBox(height: 3),

                            // ✅ Reviews row - always visible (0 if none)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(
                                reviewCount > 0 ? Icons.star : Icons.star_outline,
                                size: ratSz + 1,
                                color: reviewCount > 0 ? Colors.amber : mediumGrey,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  reviewCount > 0 ? "$avgRating ($reviewCount)" : "Reviews (0)",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: ratSz,
                                      color: reviewCount > 0 ? darkGrey : mediumGrey),
                                ),
                              ),
                            ]),

                            const Spacer(),

                            // ── Reviews Button (always visible, shows 0 if none) ────
                            SizedBox(
                              width: double.infinity,
                              height: btnH,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ProductReviewsPage(
                                      productId: product.id!,
                                      productName: product.name,
                                      token: widget.token,
                                      isAdmin: false,
                                    )),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: reviewCount > 0 ? Colors.deepPurple.shade400 : Colors.grey.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(reviewCount > 0 ? Icons.rate_review : Icons.rate_review_outlined,
                                        size: iconSz),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "Reviews (${product.reviewCount})",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: btnSz),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // ── Cart | Buy ─────────────────────────────────────────
                            Row(children: [
                              Expanded(
                                child: SizedBox(
                                  height: btnH,
                                  child: ElevatedButton(
                                    onPressed: isOutOfStock ? null : () => addToCart(product),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isOutOfStock ? mediumGrey : primaryIndigo,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_cart_outlined, size: iconSz),
                                        const SizedBox(width: 3),
                                        // ✅ Show cart qty inline on button
                                        Text(
                                          cartQty > 0 ? "Cart (${cartQty})" : "Cart",
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: btnSz),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: SizedBox(
                                  height: btnH,
                                  child: ElevatedButton(
                                    onPressed: isOutOfStock
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => CheckoutScreen(
                                                cart: [CartItem(
                                                  id: 0,
                                                  productId: product.id!,
                                                  productName: product.name,
                                                  price: product.price,
                                                  quantity: 1,
                                                  image: product.image ?? '',
                                                )],
                                                token: widget.token,
                                                isBuyNow: true,
                                              )),
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isOutOfStock ? mediumGrey : accentGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_bag_outlined, size: iconSz),
                                        const SizedBox(width: 3),
                                        Text("Buy", style: TextStyle(fontWeight: FontWeight.w600, fontSize: btnSz)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Hero Slider ──────────────────────────────────────────────────────────────
  Widget heroSlider(bool isSmall) {
    return Container(
      height: isSmall ? 140 : 240,
      margin: EdgeInsets.only(bottom: isSmall ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _sliderIndex = i),
            itemCount: sliderImages.length,
            itemBuilder: (_, index) => Image.network(
              sliderImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (_, child, p) {
                if (p == null) return child;
                return Container(color: lightGrey,
                    child: Center(child: CircularProgressIndicator(
                      value: p.expectedTotalBytes != null
                          ? p.cumulativeBytesLoaded / p.expectedTotalBytes! : null,
                      color: primaryIndigo,
                    )));
              },
              errorBuilder: (_, __, ___) => Container(color: lightGrey,
                  child: const Icon(Icons.image_not_supported, size: 60, color: mediumGrey)),
            ),
          ),
          Positioned(
            bottom: 10, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(sliderImages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _sliderIndex == i ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _sliderIndex == i ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width          = MediaQuery.of(context).size.width;
    final bool isSmartwatch = width < 250;
    final bool isVerySmall  = width >= 250 && width < 350;
    final bool isSmall      = width >= 350 && width < 600;
    final bool isTablet     = width >= 600 && width < 900;
    final bool isCardSmall  = isSmartwatch || isVerySmall;
    final bool isNavSmall   = width < 350;

    final int gridCount = isSmartwatch || isVerySmall ? 1 : isSmall ? 2 : isTablet ? 3 : 4;

    // ✅ Aspect ratio same as admin – tuned so 3-button stack fits
    final double prodAspect =
        isSmartwatch ? 0.60 : isVerySmall ? 0.62 : isSmall ? 0.65 : 0.68;

    final int cartCount = cartItems.fold(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightGrey,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryIndigo,
        automaticallyImplyLeading: false,
        leading: width < 600
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: Row(children: [
          Icon(Icons.storefront, size: width < 350 ? 20 : 24, color: Colors.white),
          SizedBox(width: width < 350 ? 4 : 8),
          Flexible(child: Text(
            width < 350 ? "Shop" : "E-Commerce Store",
            style: TextStyle(color: Colors.white, fontSize: width < 350 ? 14 : 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          )),
        ]),
        actions: [
          if (width >= 600) ...[
            navButton(Icons.shopping_cart, "Cart", () async {
              if (cartItems.isEmpty) { TopPopup.show(context, "Your cart is empty!", mediumGrey); return; }
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CartPage(cartProducts: cartItems, token: widget.token)));
              fetchCart(); fetchProducts();
            }, badge: cartCount, isSmall: isNavSmall),
            navButton(Icons.history, "Orders", () async {
              _clearOrderNotifications();
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderHistoryScreen(token: widget.token)));
              _checkForOrderUpdates();
            }, badge: _newOrderUpdates, isSmall: isNavSmall),
            navButton(Icons.rate_review, "Reviews", () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MyReviewsPage(token: widget.token)));
              _checkPendingReviews();
            }, badge: _pendingReviewsCount, isSmall: isNavSmall),
          ],
          navButton(Icons.logout, width < 350 ? "" : "Logout", logout, isSmall: isNavSmall),
          SizedBox(width: width < 350 ? 4 : 8),
        ],
      ),

      drawer: width < 600
          ? Drawer(
              backgroundColor: white,
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [primaryIndigo, Color(0xFF5C6BC0)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.storefront, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 12),
                          const Text("E-Commerce Store",
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_loginUsername, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home, color: primaryIndigo),
                      title: const Text("Home"),
                      onTap: () => Navigator.pop(context),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart, color: primaryIndigo),
                      title: const Text("Shopping Cart"),
                      trailing: cartCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text('$cartCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(context);
                        if (cartItems.isEmpty) { TopPopup.show(context, "Your cart is empty!", mediumGrey); return; }
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CartPage(cartProducts: cartItems, token: widget.token)));
                        fetchCart(); fetchProducts();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history, color: primaryIndigo),
                      title: const Text("Order History"),
                      trailing: _newOrderUpdates > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text('$_newOrderUpdates',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(context);
                        _clearOrderNotifications();
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => OrderHistoryScreen(token: widget.token)));
                        _checkForOrderUpdates();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.rate_review, color: primaryIndigo),
                      title: const Text("My Reviews"),
                      trailing: _pendingReviewsCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text('$_pendingReviewsCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          : null,
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => MyReviewsPage(token: widget.token)));
                        _checkPendingReviews();
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Logout", style: TextStyle(color: Colors.red)),
                      onTap: () { Navigator.pop(context); logout(); },
                    ),
                  ],
                ),
              ),
            )
          : null,

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryIndigo, strokeWidth: 3))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmartwatch ? 4 : isVerySmall ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heroSlider(isCardSmall),

                    Padding(
                      padding: EdgeInsets.only(bottom: isSmartwatch ? 8 : 12),
                      child: Text(
                        isSmartwatch
                            ? "Hi, $_loginUsername!"
                            : isVerySmall
                                ? "Hello, $_loginUsername!"
                                : "Hello, welcome back $_loginUsername! 👋",
                        style: TextStyle(
                          fontSize: isSmartwatch ? 14 : isVerySmall ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: primaryIndigo,
                        ),
                      ),
                    ),

                    // Order update banner
                    if (_newOrderUpdates > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isCardSmall ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300, width: 1.5),
                        ),
                        child: Row(children: [
                          Icon(Icons.notifications_active, color: Colors.orange.shade700, size: isCardSmall ? 18 : 22),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            "$_newOrderUpdates order update${_newOrderUpdates > 1 ? 's' : ''}!",
                            style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: isCardSmall ? 11 : 13),
                          )),
                          TextButton(
                            onPressed: () async {
                              _clearOrderNotifications();
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => OrderHistoryScreen(token: widget.token)));
                              _checkForOrderUpdates();
                            },
                            child: Text("View", style: TextStyle(fontSize: isCardSmall ? 11 : 13, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ),

                    // Pending reviews banner
                    if (_pendingReviewsCount > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isCardSmall ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade300, width: 1.5),
                        ),
                        child: Row(children: [
                          Icon(Icons.rate_review, color: Colors.blue.shade700, size: isCardSmall ? 18 : 22),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            "$_pendingReviewsCount pending review${_pendingReviewsCount > 1 ? 's' : ''}!",
                            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: isCardSmall ? 11 : 13),
                          )),
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => MyReviewsPage(token: widget.token)));
                              _checkPendingReviews();
                            },
                            child: Text("Review", style: TextStyle(fontSize: isCardSmall ? 11 : 13, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ),

                    // Product Grid
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        mainAxisSpacing: isSmartwatch ? 4 : 12,
                        crossAxisSpacing: isSmartwatch ? 4 : 12,
                        childAspectRatio: prodAspect,
                      ),
                      itemBuilder: (_, i) => buildProductCard(products[i], isCardSmall),
                    ),

                    const SizedBox(height: 20),
                    const FooterWidget(),
                  ],
                ),
              ),
            ),
    );
  }
}