// lib/dashboards/user_dashboard.dart (FIXED VERSION)

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

  List<Product> products = [];
  List<CartItem> cartItems = [];
  List<Order> userOrders = [];
  bool _isLoading = true;

  int _newOrderUpdates = 0;
  int _pendingReviewsCount = 0;
  Timer? _orderCheckTimer;
  Timer? _reviewCheckTimer;
  Map<int, String> _lastKnownOrderStatus = {};

  int _sliderIndex = 0;
  Timer? _sliderTimer;

  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color cardGrey = Color(0xFFFAFAFA);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color borderGrey = Color(0xFFE0E0E0);

  final List<String> sliderImages = [
    "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?q=80&w=1600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?q=80&w=1600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1607083206968-13611e3d76db?q=80&w=1600&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1523381294911-8d3cead13475?q=80&w=1600&auto=format&fit=crop",
  ];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
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
        _pageController.animateToPage(nextPage,
            duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        setState(() => _sliderIndex = nextPage);
      }
    });
  }

  Future<void> _checkPendingReviews() async {
    try {
      final pending = await ApiService.fetchPendingReviews(token: widget.token);
      if (!mounted) return;
      setState(() => _pendingReviewsCount = pending.length);
      final productIds = pending.map((p) => p.id).toList();
      final productNames = Map.fromEntries(pending.map((p) => MapEntry(p.id, p.name)));
      await NotificationService.checkReviewReminders(productIds, productNames);
    } catch (e) {
      debugPrint("Error checking pending reviews: $e");
    }
    _reviewCheckTimer =
        Timer(const Duration(minutes: 5), () => {if (mounted) _checkPendingReviews()});
  }

  Future<void> _initializeOrderTracking() async {
    await _loadLastKnownStatuses();
    await _checkForOrderUpdates();
    _orderCheckTimer = Timer.periodic(const Duration(seconds: 30),
        (_) => {if (mounted) _checkForOrderUpdates()});
  }

  Future<void> _loadLastKnownStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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
    } catch (e) {
      debugPrint("Error loading order statuses: $e");
    }
  }

  Future<void> _saveLastKnownStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusString =
          _lastKnownOrderStatus.entries.map((e) => '${e.key}:${e.value}').join('||');
      await prefs.setString('last_order_statuses', statusString);
    } catch (e) {
      debugPrint("Error saving order statuses: $e");
    }
  }

  Future<void> _checkForOrderUpdates() async {
    try {
      final orders = await ApiService.fetchOrders(token: widget.token);
      if (!mounted) return;
      int newUpdates = 0;
      for (final order in orders) {
        if (order.id == null) continue;
        final orderId = order.id!;
        final currentStatus = order.status;
        final lastStatus = _lastKnownOrderStatus[orderId];
        if (lastStatus != null && lastStatus != currentStatus) {
          newUpdates++;
          if (currentStatus == "Delivered") _checkPendingReviews();
        }
        _lastKnownOrderStatus[orderId] = currentStatus;
      }
      setState(() {
        userOrders = orders;
        _newOrderUpdates = newUpdates;
      });
      await _saveLastKnownStatuses();
    } catch (e) {
      debugPrint("Error checking order updates: $e");
    }
  }

  void _clearOrderNotifications() => setState(() => _newOrderUpdates = 0);

  Future<void> fetchProducts() async {
    try {
      final response = await ApiService.fetchProducts(token: widget.token);
      if (!mounted) return;
      setState(() {
        products = response;
        _isLoading = false;
      });
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
        TopPopup.show(context, "Only ${product.stock} items available in stock!", Colors.orange);
        return;
      }
      final updatedItem = CartItem(
          id: existing.id,
          productId: existing.productId,
          productName: existing.productName,
          price: existing.price,
          quantity: existing.quantity + 1,
          image: existing.image);
      cartItems[index] = updatedItem;
      await ApiService.addToCart(
          productId: existing.productId, quantity: updatedItem.quantity, token: widget.token);
      TopPopup.show(context, "${existing.productName} quantity updated!", accentGreen);
      setState(() {});
      return;
    }
    final success = await ApiService.addToCart(
        productId: product.id!, quantity: 1, token: widget.token);
    if (success) {
      cartItems.add(CartItem(
          id: 0,
          productId: product.id!,
          productName: product.name,
          price: product.price,
          quantity: 1,
          image: product.image ?? ''));
      TopPopup.show(context, "${product.name} added to cart!", accentGreen);
      setState(() {});
    }
  }

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
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    SizedBox(height: 16),
                    Text("Logging out...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ))),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Widget hoverButton(
      {required Widget child,
      required VoidCallback onTap,
      Color? color,
      EdgeInsets? padding}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(builder: (context, setStateHover) {
        bool isHovered = false;
        return GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            onEnter: (_) => setStateHover(() => isHovered = true),
            onExit: (_) => setStateHover(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isHovered ? accentGreen : (color ?? primaryIndigo),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                            color: accentGreen.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Center(child: child),
            ),
          ),
        );
      }),
    );
  }

  Widget buildProductImage(String? url, {double height = 100, bool isSmall = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        width: double.infinity,
        color: lightGrey,
        child: url == null || url.isEmpty
            ? Icon(Icons.shopping_bag_outlined,
                size: isSmall ? 40 : 60, color: mediumGrey)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag_outlined,
                    size: isSmall ? 40 : 60, color: mediumGrey),
              ),
      ),
    );
  }

  Widget navButton(IconData icon, String label, VoidCallback onTap,
      {int? badge, bool isSmall = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 2 : 4),
      child: hoverButton(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8, horizontal: isSmall ? 4 : 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: isSmall ? 16 : 20),
                if (!isSmall) ...[
                  const SizedBox(width: 4),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ],
            ),
            if (badge != null && badge > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 2 : 3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: BoxConstraints(
                      minWidth: isSmall ? 14 : 16, minHeight: isSmall ? 14 : 16),
                  child: Center(
                      child: Text('$badge',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmall ? 8 : 9,
                              fontWeight: FontWeight.bold))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(int stock, bool isSmall) {
    Color badgeColor;
    IconData icon;
    String text;
    if (stock == 0) {
      badgeColor = Colors.red;
      icon = Icons.remove_shopping_cart;
      text = isSmall ? "Out" : "Out of Stock";
    } else if (stock <= 5) {
      badgeColor = Colors.orange;
      icon = Icons.warning;
      text = isSmall ? "Low" : "Low Stock";
    } else {
      badgeColor = accentGreen;
      icon = Icons.check_circle;
      text = isSmall ? "In" : "In Stock";
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 6, vertical: isSmall ? 2 : 3),
      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isSmall ? 10 : 12),
          SizedBox(width: isSmall ? 2 : 3),
          Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 8 : 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void showProductModal(Product product, bool isSmall) {
    final stock = product.stock;
    final isOutOfStock = stock == 0;
    final reviewCount = product.reviewCount;
    final avgRating = product.averageRating;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: white,
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(builder: (context, setStateModal) {
          final cartIndex = cartItems.indexWhere((i) => i.productId == product.id);
          final cartQty = cartIndex >= 0 ? cartItems[cartIndex].quantity : 0;
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
                    Expanded(
                      child: Text(product.name,
                          style: TextStyle(
                              fontSize: isSmall ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: darkGrey),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints()),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    buildProductImage(product.image,
                        height: isSmall ? 120 : 160, isSmall: isSmall),
                    Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStockBadge(stock, isSmall)),
                  ],
                ),
                const SizedBox(height: 12),
                Text("Rs ${product.price}",
                    style: TextStyle(
                        fontSize: isSmall ? 18 : 22,
                        color: primaryIndigo,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(reviewCount > 0 ? Icons.star : Icons.star_outline,
                        size: isSmall ? 14 : 16,
                        color: reviewCount > 0 ? Colors.amber : mediumGrey),
                    const SizedBox(width: 4),
                    Text(
                      reviewCount > 0
                          ? "$avgRating ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})"
                          : "No reviews yet",
                      style: TextStyle(
                          fontSize: isSmall ? 11 : 13,
                          fontWeight: FontWeight.w500,
                          color: darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_cart, size: isSmall ? 13 : 15,
                        color: cartQty > 0 ? accentGreen : mediumGrey),
                    const SizedBox(width: 4),
                    Text("In Cart: $cartQty",
                        style: TextStyle(
                          color: cartQty > 0 ? accentGreen : mediumGrey,
                          fontWeight:
                              cartQty > 0 ? FontWeight.w600 : FontWeight.normal,
                          fontSize: isSmall ? 11 : 13,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                Text(product.description,
                    style: TextStyle(fontSize: isSmall ? 12 : 14, color: darkGrey),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: hoverButton(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductReviewsPage(
                                    productId: product.id!,
                                    productName: product.name,
                                    token: widget.token,
                                    isAdmin: false,
                                  )));
                    },
                    color: reviewCount > 0 ? Colors.purple : Colors.grey.shade600,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(reviewCount > 0 ? Icons.rate_review : Icons.rate_review_outlined,
                            size: isSmall ? 14 : 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text("Reviews ($reviewCount)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: isSmall ? 13 : 15)),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child: hoverButton(
                      onTap: isOutOfStock ? () {} : () {
                        addToCart(product);
                        Navigator.pop(context);
                      },
                      color: isOutOfStock ? mediumGrey : primaryIndigo,
                      child: Text(isOutOfStock ? "Out of Stock" : "Add to Cart",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: isSmall ? 13 : 15)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: hoverButton(
                      onTap: isOutOfStock ? () {} : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                      cart: [
                                        CartItem(
                                            id: 0,
                                            productId: product.id!,
                                            productName: product.name,
                                            price: product.price,
                                            quantity: 1,
                                            image: product.image ?? '')
                                      ],
                                      token: widget.token,
                                      isBuyNow: true,
                                    )));
                      },
                      color: isOutOfStock ? mediumGrey : accentGreen,
                      child: Text(isOutOfStock ? "Unavailable" : "Buy Now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: isSmall ? 13 : 15)),
                    )),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ✅ FIXED PRODUCT CARD - Fully responsive for all screen sizes
  Widget buildProductCard(Product product, bool isSmall) {
    final cartIndex = cartItems.indexWhere((i) => i.productId == product.id);
    final cartQty = cartIndex >= 0 ? cartItems[cartIndex].quantity : 0;
    final stock = product.stock;
    final isOutOfStock = stock == 0;
    final reviewCount = product.reviewCount;
    final avgRating = product.averageRating;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(builder: (context, setCardState) {
        bool isHovered = false;
        return InkWell(
          onTap: () => showProductModal(product, isSmall),
          borderRadius: BorderRadius.circular(12),
          child: MouseRegion(
            onEnter: (_) => setCardState(() => isHovered = true),
            onExit: (_) => setCardState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Opacity(
                opacity: isOutOfStock ? 0.5 : 1.0,
                child: Card(
                  elevation: isHovered ? 8 : 2,
                  shadowColor: primaryIndigo.withOpacity(isHovered ? 0.3 : 0.1),
                  color: isHovered ? white : cardGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: isHovered ? primaryIndigo.withOpacity(0.4) : borderGrey,
                        width: isHovered ? 2 : 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmall ? 6 : 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available width
                        final cardWidth = constraints.maxWidth;
                        
                        // Determine if we need ultra compact layout
                        final bool isUltraCompact = cardWidth < 140;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Image with stock badge
                            Stack(
                              children: [
                                buildProductImage(product.image,
                                    height: isUltraCompact ? 70 : (isSmall ? 80 : 100),
                                    isSmall: isSmall),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: _buildStockBadgeCompact(stock, isUltraCompact),
                                ),
                              ],
                            ),
                            SizedBox(height: isUltraCompact ? 4 : 6),

                            // Product name with proper overflow
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isUltraCompact ? 11 : (isSmall ? 12 : 14),
                                color: darkGrey,
                              ),
                            ),

                            // Price
                            Text(
                              "Rs ${product.price}",
                              style: TextStyle(
                                color: primaryIndigo,
                                fontWeight: FontWeight.bold,
                                fontSize: isUltraCompact ? 11 : (isSmall ? 12 : 14),
                              ),
                            ),

                            // Compact rating and cart info (combined for small screens)
                            if (isUltraCompact) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      size: 10,
                                      color: reviewCount > 0 ? Colors.amber : mediumGrey),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      reviewCount > 0 ? "$avgRating" : "0",
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: mediumGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.shopping_cart,
                                      size: 10, color: cartQty > 0 ? accentGreen : mediumGrey),
                                  const SizedBox(width: 2),
                                  Text(
                                    "$cartQty",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: cartQty > 0 ? accentGreen : mediumGrey,
                                      fontWeight: cartQty > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Rating row for normal screens
                              Row(
                                children: [
                                  Icon(reviewCount > 0 ? Icons.star : Icons.star_outline,
                                      size: isSmall ? 10 : 12,
                                      color: reviewCount > 0 ? Colors.amber : mediumGrey),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      reviewCount > 0 ? "$avgRating ($reviewCount)" : "No reviews",
                                      style: TextStyle(
                                        fontSize: isSmall ? 9 : 10,
                                        fontWeight: FontWeight.w500,
                                        color: mediumGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // Cart count row
                              Row(
                                children: [
                                  Icon(Icons.shopping_cart,
                                      size: isSmall ? 9 : 11,
                                      color: cartQty > 0 ? accentGreen : mediumGrey),
                                  const SizedBox(width: 2),
                                  Text(
                                    "In Cart: $cartQty",
                                    style: TextStyle(
                                      color: cartQty > 0 ? accentGreen : mediumGrey,
                                      fontSize: isSmall ? 9 : 10,
                                      fontWeight: cartQty > 0 ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const Spacer(),
                            
                            // Reviews button - simplified for ultra compact
                            if (isUltraCompact) ...[
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                child: hoverButton(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProductReviewsPage(
                                                productId: product.id!,
                                                productName: product.name,
                                                token: widget.token,
                                                isAdmin: false,
                                              ))),
                                  color: reviewCount > 0 ? Colors.purple : Colors.grey.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(reviewCount > 0 ? Icons.rate_review : Icons.rate_review_outlined,
                                          size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        "$reviewCount",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              SizedBox(
                                width: double.infinity,
                                child: hoverButton(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProductReviewsPage(
                                                productId: product.id!,
                                                productName: product.name,
                                                token: widget.token,
                                                isAdmin: false,
                                              ))),
                                  color: reviewCount > 0 ? Colors.purple : Colors.grey.shade600,
                                  padding: EdgeInsets.symmetric(vertical: isSmall ? 5 : 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(reviewCount > 0 ? Icons.rate_review : Icons.rate_review_outlined,
                                          size: isSmall ? 11 : 13, color: Colors.white),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          "Reviews ($reviewCount)",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: isSmall ? 9 : 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 4),

                            // Action buttons - stacked for ultra compact, row for others
                            if (isUltraCompact) ...[
                              // Stacked buttons for very small screens
                              SizedBox(
                                width: double.infinity,
                                child: hoverButton(
                                  onTap: isOutOfStock ? () {} : () => addToCart(product),
                                  color: isOutOfStock ? mediumGrey : primaryIndigo,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart,
                                          size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        cartQty > 0 ? "Cart $cartQty" : "Cart",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: double.infinity,
                                child: hoverButton(
                                  onTap: isOutOfStock ? () {} : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => CheckoutScreen(
                                                  cart: [
                                                    CartItem(
                                                        id: 0,
                                                        productId: product.id!,
                                                        productName: product.name,
                                                        price: product.price,
                                                        quantity: 1,
                                                        image: product.image ?? '')
                                                  ],
                                                  token: widget.token,
                                                  isBuyNow: true,
                                                )));
                                  },
                                  color: isOutOfStock ? mediumGrey : accentGreen,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_bag, size: 10, color: Colors.white),
                                      SizedBox(width: 2),
                                      Text(
                                        "Buy",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Row layout for normal screens
                              Row(
                                children: [
                                  Expanded(
                                    child: hoverButton(
                                      onTap: isOutOfStock ? () {} : () => addToCart(product),
                                      color: isOutOfStock ? mediumGrey : primaryIndigo,
                                      padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.shopping_cart,
                                              size: isSmall ? 12 : 14, color: Colors.white),
                                          const SizedBox(width: 3),
                                          Text(
                                            cartQty > 0 ? "Cart ($cartQty)" : "Cart",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: isSmall ? 10 : 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isSmall ? 4 : 6),
                                  Expanded(
                                    child: hoverButton(
                                      onTap: isOutOfStock ? () {} : () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => CheckoutScreen(
                                                      cart: [
                                                        CartItem(
                                                            id: 0,
                                                            productId: product.id!,
                                                            productName: product.name,
                                                            price: product.price,
                                                            quantity: 1,
                                                            image: product.image ?? '')
                                                      ],
                                                      token: widget.token,
                                                      isBuyNow: true,
                                                    )));
                                      },
                                      color: isOutOfStock ? mediumGrey : accentGreen,
                                      padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.shopping_bag,
                                              size: isSmall ? 12 : 14, color: Colors.white),
                                          const SizedBox(width: 3),
                                          Text(
                                            "Buy",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: isSmall ? 10 : 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Ultra compact stock badge for very small screens
  Widget _buildStockBadgeCompact(int stock, bool isUltraCompact) {
    if (!isUltraCompact) return _buildStockBadge(stock, true);
    
    Color badgeColor;
    String text;
    if (stock == 0) {
      badgeColor = Colors.red;
      text = "Out";
    } else if (stock <= 5) {
      badgeColor = Colors.orange;
      text = "Low";
    } else {
      badgeColor = accentGreen;
      text = "In";
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget heroSlider(bool isSmall) {
    return Container(
      height: isSmall ? 150 : 250,
      margin: EdgeInsets.only(bottom: isSmall ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _sliderIndex = index),
              itemCount: sliderImages.length,
              itemBuilder: (_, index) => Image.network(
                sliderImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (_, child, p) {
                  if (p == null) return child;
                  return Container(
                      color: lightGrey,
                      child: Center(
                          child: CircularProgressIndicator(
                        value: p.expectedTotalBytes != null
                            ? p.cumulativeBytesLoaded / p.expectedTotalBytes!
                            : null,
                        color: primaryIndigo,
                      )));
                },
                errorBuilder: (_, __, ___) => Container(
                    color: lightGrey,
                    child: const Icon(Icons.image_not_supported,
                        size: 60, color: mediumGrey)),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sliderImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _sliderIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _sliderIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: _sliderIndex == index
                          ? [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmartwatch = width < 250;
    final bool isVerySmall = width >= 250 && width < 350;
    final bool isSmall = width >= 350 && width < 600;
    final bool isTablet = width >= 600 && width < 900;
    final bool isCardSmall = isSmartwatch || isVerySmall;
    final bool isNavSmall = width < 350;

    // ✅ IMPROVED: Dynamic aspect ratio based on screen size
    final double aspectRatio = isSmartwatch ? 0.5 : (isVerySmall ? 0.55 : (isSmall ? 0.6 : 0.65));
    
    final int gridCount = isSmartwatch || isVerySmall ? 1 : isSmall ? 2 : isTablet ? 3 : 5;
    final int cartCount = cartItems.fold(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightGrey,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryIndigo,
        leading: width < 600
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer())
            : null,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.storefront,
                size: width < 350 ? 20 : 24, color: Colors.white),
            SizedBox(width: width < 350 ? 4 : 8),
            Flexible(
              child: Text(
                width < 350 ? "Shop" : "E-Commerce Store",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: width < 350 ? 14 : 18,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (width >= 600) ...[
            navButton(Icons.shopping_cart, "Cart", () async {
              if (cartItems.isEmpty) {
                TopPopup.show(context, "Your cart is empty!", mediumGrey);
                return;
              }
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CartPage(
                          cartProducts: cartItems, token: widget.token)));
              fetchCart();
              fetchProducts();
            },
                badge: cartCount,
                isSmall: isNavSmall),
            navButton(Icons.history, "Orders", () async {
              _clearOrderNotifications();
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          OrderHistoryScreen(token: widget.token)));
              _checkForOrderUpdates();
            },
                badge: _newOrderUpdates,
                isSmall: isNavSmall),
            navButton(Icons.rate_review, "Reviews", () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MyReviewsPage(token: widget.token)));
              _checkPendingReviews();
            },
                badge: _pendingReviewsCount,
                isSmall: isNavSmall),
          ],
          navButton(Icons.logout, width < 350 ? "" : "Logout", logout,
              isSmall: isNavSmall),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryIndigo, primaryIndigo.withOpacity(0.8)]),
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
                            child: const Icon(Icons.storefront,
                                color: Colors.white, size: 40)),
                        const SizedBox(height: 12),
                        const Text("E-Commerce Store",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.username,
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text('$cartCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)))
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      if (cartItems.isEmpty) {
                        TopPopup.show(context, "Your cart is empty!", mediumGrey);
                        return;
                      }
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CartPage(
                                  cartProducts: cartItems, token: widget.token)));
                      fetchCart();
                      fetchProducts();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: primaryIndigo),
                    title: const Text("Order History"),
                    trailing: _newOrderUpdates > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text('$_newOrderUpdates',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)))
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      _clearOrderNotifications();
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  OrderHistoryScreen(token: widget.token)));
                      _checkForOrderUpdates();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.rate_review, color: primaryIndigo),
                    title: const Text("My Reviews"),
                    trailing: _pendingReviewsCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text('$_pendingReviewsCount',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)))
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MyReviewsPage(token: widget.token)));
                      _checkPendingReviews();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout", style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      logout();
                    },
                  ),
                ],
              )),
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: primaryIndigo, strokeWidth: 3))
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
                            ? "Hi, ${widget.username}!"
                            : isVerySmall
                                ? "Hello, ${widget.username}!"
                                : "Hello, welcome back ${widget.username}! 👋",
                        style: TextStyle(
                            fontSize: isSmartwatch
                                ? 14
                                : isVerySmall
                                    ? 16
                                    : 18,
                            fontWeight: FontWeight.bold,
                            color: primaryIndigo),
                      ),
                    ),
                    if (_newOrderUpdates > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isCardSmall ? 8 : 12),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.orange.shade300, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.orange.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active,
                                color: Colors.orange.shade700,
                                size: isCardSmall ? 18 : 22),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                              "$_newOrderUpdates order update${_newOrderUpdates > 1 ? 's' : ''}!",
                              style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCardSmall ? 11 : 13),
                            )),
                            TextButton(
                              onPressed: () async {
                                _clearOrderNotifications();
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => OrderHistoryScreen(
                                            token: widget.token)));
                                _checkForOrderUpdates();
                              },
                              child: Text("View",
                                  style: TextStyle(
                                      fontSize: isCardSmall ? 11 : 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    if (_pendingReviewsCount > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isCardSmall ? 8 : 12),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.blue.shade300, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Row(
                          children: [
                            Icon(Icons.rate_review,
                                color: Colors.blue.shade700,
                                size: isCardSmall ? 18 : 22),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                              "$_pendingReviewsCount pending review${_pendingReviewsCount > 1 ? 's' : ''}!",
                              style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCardSmall ? 11 : 13),
                            )),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MyReviewsPage(
                                            token: widget.token)));
                                _checkPendingReviews();
                              },
                              child: Text("Review",
                                  style: TextStyle(
                                      fontSize: isCardSmall ? 11 : 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    // ✅ IMPROVED: Use LayoutBuilder to adapt grid to available width
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCount,
                            mainAxisSpacing: isSmartwatch ? 4 : 12,
                            crossAxisSpacing: isSmartwatch ? 4 : 12,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (_, index) =>
                              buildProductCard(products[index], isCardSmall),
                        );
                      },
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