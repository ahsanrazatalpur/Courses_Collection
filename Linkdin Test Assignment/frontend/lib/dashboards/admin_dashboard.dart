// lib/dashboards/admin_dashboard.dart
// ✅ FINAL: Edit + Delete + Reviews always visible | Professional cards | No overflow

// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../helpers/top_popup.dart';
import '../pages/login.dart';
import '../pages/users_page.dart';
import '../pages/admin_orders_page.dart';
import '../pages/admin_coupons_page.dart';
import '../pages/notifications_page.dart';
import '../pages/admin_reviews_page.dart';
import '../pages/product_reviews_page.dart';
import '../widgets/footer_widget.dart';
import 'package:csv/csv.dart';

const int kLowStockThreshold = 10;

class AdminDashboardPage extends StatefulWidget {
  final String token;
  final String username;
  final int userId;

  const AdminDashboardPage({
    super.key,
    required this.token,
    required this.username,
    required this.userId,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool _isLoading = true;

  String searchQuery = '';
  String stockFilter = 'all';

  int currentPage = 1;
  final int itemsPerPage = 9;

  int newOrdersCount = 0;
  int notificationCount = 0;
  Timer? _orderCountTimer;
  Timer? _notificationTimer;

  // ─── Color Palette ───────────────────────────────────────────────────────────
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen   = Color(0xFF4CAF50);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color lightGrey     = Color(0xFFF5F5F5);
  static const Color mediumGrey    = Color(0xFF9E9E9E);
  static const Color darkGrey      = Color(0xFF424242);
  static const Color borderGrey    = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchNewOrdersCount();
    _loadNotificationCount();
    _orderCountTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) { if (mounted) fetchNewOrdersCount(); },
    );
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) { if (mounted) _loadNotificationCount(); },
    );
  }

  @override
  void dispose() {
    _orderCountTimer?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }

  // ─── Computed Stats ───────────────────────────────────────────────────────────
  int    get _totalProducts => products.length;
  int    get _inStock       => products.where((p) => p.stock >= kLowStockThreshold).length;
  int    get _lowStock      => products.where((p) => p.stock > 0 && p.stock < kLowStockThreshold).length;
  int    get _outOfStock    => products.where((p) => p.stock == 0).length;
  double get _revenue       => products.fold(0.0, (sum, p) => sum + (p.price * p.stock));

  Future<void> _loadNotificationCount() async {
    final count = await NotificationService.getUnreadCount();
    if (!mounted) return;
    setState(() => notificationCount = count);
  }

  Future<void> fetchNewOrdersCount() async {
    try {
      final count = await ApiService.fetchNewOrdersCount(token: widget.token);
      if (!mounted) return;
      setState(() => newOrdersCount = count);
    } catch (e) { debugPrint("fetchNewOrdersCount error: $e"); }
  }

  Future<void> fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.fetchProducts(token: widget.token);
      if (!mounted) return;
      await NotificationService.checkStockAlerts(data);
      await _loadNotificationCount();
      setState(() {
        products = data;
        applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      TopPopup.show(context, "Failed to load products: $e", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  void applyFilters() {
    filteredProducts = products.where((p) {
      final matchSearch = p.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchStock  = switch (stockFilter) {
        'in'  => p.stock >= kLowStockThreshold,
        'low' => p.stock > 0 && p.stock < kLowStockThreshold,
        'out' => p.stock == 0,
        _     => true,
      };
      return matchSearch && matchStock;
    }).toList();
    currentPage = 1;
    setState(() {});
  }

  List<Product> get paginatedProducts {
    final start = (currentPage - 1) * itemsPerPage;
    final end   = (start + itemsPerPage).clamp(0, filteredProducts.length);
    if (start >= filteredProducts.length) return [];
    return filteredProducts.sublist(start, end);
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
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
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

  Future<void> exportCSV() async {
    if (!kIsWeb) { TopPopup.show(context, "CSV export is only available on web", Colors.orange); return; }
    if (products.isEmpty) { TopPopup.show(context, "No products to export", Colors.orange); return; }
    final rows = <List<dynamic>>[["ID", "Name", "Price", "Stock", "Status", "Reviews", "Rating"]];
    for (final p in products) {
      final status = p.stock == 0 ? 'Out of Stock' : p.stock < kLowStockThreshold ? 'Low Stock' : 'In Stock';
      rows.add([p.id, p.name, p.price, p.stock, status, p.reviewCount, p.averageRating]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    TopPopup.show(context, "CSV ready — integrate with universal_html for download", accentGreen);
  }

  Future<String?> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        TopPopup.show(context, "Image selected! Upload to server needed.", Colors.orange);
        return image.path;
      }
    } catch (e) {
      TopPopup.show(context, "Failed to pick image: $e", Colors.red);
    }
    return null;
  }

  // ─── Hover Button ─────────────────────────────────────────────────────────────
  Widget hoverButton({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    double? width,
    EdgeInsets? padding,
    bool disabled = false,
  }) {
    return StatefulBuilder(builder: (context, setHover) {
      bool hovered = false;
      return MouseRegion(
        cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        onEnter: (_) { if (!disabled) setHover(() => hovered = true); },
        onExit:  (_) => setHover(() => hovered = false),
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: width,
            padding: padding ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: disabled
                  ? mediumGrey
                  : hovered ? accentGreen : (color ?? primaryIndigo),
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

  // ─── Product Modal ─────────────────────────────────────────────────────────────
  void showProductModal(Product? product, {bool readOnly = false}) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 600;
    final nameCtrl  = TextEditingController(text: product?.name ?? '');
    final descCtrl  = TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final imageCtrl = TextEditingController(text: product?.image ?? '');
    final originalStock = product?.stock ?? 0;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: white,
        insetPadding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(builder: (ctx, setModal) => SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(isSmall ? 16 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(
                      product == null ? "Add Product" : readOnly ? "View Product" : "Edit Product",
                      style: TextStyle(fontSize: isSmall ? 18 : 20, fontWeight: FontWeight.bold, color: primaryIndigo),
                    )),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: darkGrey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 12 : 16),

                // Image preview
                Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: isSmall ? 140 : 160,
                      width: double.infinity,
                      color: lightGrey,
                      child: imageCtrl.text.isNotEmpty
                          ? Image.network(
                              imageCtrl.text,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.shopping_bag_outlined, size: 60, color: mediumGrey),
                              loadingBuilder: (_, child, p) {
                                if (p == null) return child;
                                return Center(child: CircularProgressIndicator(
                                  value: p.expectedTotalBytes != null
                                      ? p.cumulativeBytesLoaded / p.expectedTotalBytes! : null,
                                ));
                              },
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 80, color: mediumGrey),
                    ),
                  ),
                  if (!readOnly)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () async {
                            final path = await _pickImage();
                            if (path != null) setModal(() => imageCtrl.text = path);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: primaryIndigo, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                ]),

                SizedBox(height: isSmall ? 16 : 20),
                _buildTextField(nameCtrl,  "Product Name",                  readOnly, isSmall),
                SizedBox(height: isSmall ? 10 : 12),
                _buildTextField(descCtrl,  "Description",                   readOnly, isSmall, maxLines: 3),
                SizedBox(height: isSmall ? 10 : 12),
                _buildTextField(priceCtrl, "Price (Rs)",                    readOnly, isSmall, keyboard: TextInputType.number),
                SizedBox(height: isSmall ? 10 : 12),
                _buildTextField(stockCtrl, "Stock Quantity",                readOnly, isSmall, keyboard: TextInputType.number),
                SizedBox(height: isSmall ? 10 : 12),
                _buildTextField(imageCtrl, "Image URL (or use camera btn)", readOnly, isSmall),
                SizedBox(height: isSmall ? 20 : 24),

                if (!readOnly)
                  Row(children: [
                    Expanded(child: hoverButton(
                      color: primaryIndigo,
                      padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 14),
                      onTap: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          TopPopup.show(ctx, "Name is required", Colors.red);
                          return;
                        }
                        final newStock = int.tryParse(stockCtrl.text) ?? 0;
                        final np = Product(
                          id: product?.id,
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          price: double.tryParse(priceCtrl.text) ?? 0,
                          stock: newStock,
                          image: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
                        );
                        final ok = product == null
                            ? await ApiService.addProduct(np, token: widget.token)
                            : await ApiService.updateProduct(np, token: widget.token);
                        if (!mounted) return;
                        if (ok) {
                          Navigator.pop(ctx);
                          if (product != null) {
                            if (newStock == 0 && originalStock > 0) {
                              await NotificationService.saveNotification(
                                'Stock Alert: ${np.name} is now OUT OF STOCK', 'urgent');
                            } else if (newStock < kLowStockThreshold && newStock > 0 && originalStock >= kLowStockThreshold) {
                              await NotificationService.saveNotification(
                                'Stock Alert: ${np.name} is running LOW ($newStock left)', 'warning');
                            }
                          }
                          await fetchProducts();
                          await _loadNotificationCount();
                          TopPopup.show(context, product == null ? "Product added!" : "Product updated!", accentGreen);
                        } else {
                          TopPopup.show(ctx, "Operation failed", Colors.red);
                        }
                      },
                      child: Text(
                        product == null ? "Add Product" : "Update Product",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isSmall ? 14 : 16),
                      ),
                    )),
                    SizedBox(width: isSmall ? 10 : 12),
                    Expanded(child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: mediumGrey),
                        padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Cancel", style: TextStyle(color: darkGrey, fontSize: isSmall ? 14 : 16)),
                    )),
                  ]),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController c,
    String label,
    bool readOnly,
    bool isSmall, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      readOnly: readOnly,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: TextStyle(color: darkGrey, fontSize: isSmall ? 13 : 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: mediumGrey, fontSize: isSmall ? 12 : 14),
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: accentGreen, width: 2)),
        contentPadding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12, horizontal: isSmall ? 12 : 16),
      ),
    );
  }

  // ─── Stock Badge ──────────────────────────────────────────────────────────────
  Widget _buildStockBadge(Product product) {
    final Color color;
    final IconData icon;
    if (product.stock == 0) {
      color = Colors.red; icon = Icons.remove_shopping_cart;
    } else if (product.stock < kLowStockThreshold) {
      color = Colors.orange; icon = Icons.warning_amber_rounded;
    } else {
      color = accentGreen; icon = Icons.check_circle;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 11),
        const SizedBox(width: 3),
        Text("${product.stock}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  // ─── Product Card (Admin) ─────────────────────────────────────────────────────
  // Fixed layout: image → name/price/rating → Reviews btn → Edit | Delete
  // All content stays within card bounds, no overflow
  Widget buildProductCard(Product product, bool isSmall) {
    final imgH   = isSmall ? 110.0 : 140.0;
    final pad    = isSmall ? 10.0  : 12.0;
    final nameSz = isSmall ? 13.0  : 14.0;
    final prSz   = isSmall ? 13.0  : 14.0;
    final ratSz  = isSmall ? 10.0  : 11.0;
    final btnH   = isSmall ? 32.0  : 35.0;
    final btnSz  = isSmall ? 11.0  : 12.0;
    final iconSz = isSmall ? 12.0  : 13.0;

    return Card(
      elevation: 2,
      color: white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image ──────────────────────────────────────────────────────────
          Stack(children: [
            SizedBox(
              height: imgH,
              width: double.infinity,
              child: product.image != null && product.image!.isNotEmpty
                  ? Image.network(
                      product.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(isSmall),
                      loadingBuilder: (_, child, p) {
                        if (p == null) return child;
                        return _loadingPlaceholder();
                      },
                    )
                  : _placeholder(isSmall),
            ),
            Positioned(top: 7, right: 7, child: _buildStockBadge(product)),
          ]),

          // ── Info + Buttons ─────────────────────────────────────────────────
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold, fontSize: prSz),
                  ),
                  const SizedBox(height: 3),

                  // Rating row
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      product.reviewCount > 0 ? Icons.star : Icons.star_outline,
                      size: ratSz + 1,
                      color: product.reviewCount > 0 ? Colors.amber : mediumGrey,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        product.reviewCount > 0
                            ? "${product.averageRating} (${product.reviewCount})"
                            : "No reviews",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: ratSz,
                          color: product.reviewCount > 0 ? darkGrey : mediumGrey,
                        ),
                      ),
                    ),
                  ]),

                  const Spacer(),

                  // ── Reviews Button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: btnH,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProductReviewsPage(
                          productId: product.id!,
                          productName: product.name,
                          token: widget.token,
                          isAdmin: true,
                        )),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rate_review, size: iconSz),
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

                  // ── Edit | Delete ──────────────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: SizedBox(
                        height: btnH,
                        child: ElevatedButton(
                          onPressed: () => showProductModal(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryIndigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, size: iconSz),
                              const SizedBox(width: 3),
                              Text("Edit", style: TextStyle(fontWeight: FontWeight.w600, fontSize: btnSz)),
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
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text("Confirm Delete",
                                    style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
                                content: Text('Delete "${product.name}"?',
                                    style: const TextStyle(color: darkGrey)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel", style: TextStyle(color: mediumGrey)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) return;
                            final ok = await ApiService.deleteProduct(product.id!, token: widget.token);
                            if (!mounted) return;
                            if (ok) {
                              fetchProducts();
                              TopPopup.show(context, "Product deleted!", Colors.red);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, size: iconSz),
                              const SizedBox(width: 3),
                              Text("Delete", style: TextStyle(fontWeight: FontWeight.w600, fontSize: btnSz)),
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
    );
  }

  Widget _placeholder(bool isSmall) => Container(
    color: lightGrey,
    child: Icon(Icons.shopping_bag_outlined, size: isSmall ? 44 : 54, color: mediumGrey),
  );

  Widget _loadingPlaceholder() => Container(
    color: lightGrey,
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  // ─── Analytics Card ───────────────────────────────────────────────────────────
  Widget analyticsCard(String title, String value, IconData icon, Color color) {
    return LayoutBuilder(builder: (ctx, box) {
      final h        = box.maxHeight;
      final w        = box.maxWidth;
      final iconBox  = (h * 0.30).clamp(22.0, 58.0);
      final iconSz   = iconBox * 0.55;
      final valueSz  = (h * 0.17).clamp(10.0, 22.0);
      final titleSz  = (h * 0.10).clamp(8.0, 13.0);
      final innerPad = (w * 0.05).clamp(4.0, 12.0);

      return Card(
        elevation: 3,
        color: color.withOpacity(0.95),
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
        child: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.all(innerPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconBox, height: iconBox,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: iconSz),
                ),
                SizedBox(height: h * 0.05),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: valueSz, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                SizedBox(height: h * 0.03),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: titleSz, fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.95))),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── Nav Button ───────────────────────────────────────────────────────────────
  Widget navButton(IconData icon, String label, VoidCallback onTap, {int? badge}) {
    final w = MediaQuery.of(context).size.width;
    final showLabel = w > 350;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w < 350 ? 2 : 4),
      child: hoverButton(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: w < 350 ? 6 : 8, horizontal: w < 350 ? 4 : 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: w < 350 ? 16 : 18),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: w < 350 ? 10 : 12)),
              ],
            ]),
            if (badge != null && badge > 0)
              Positioned(
                right: showLabel ? -4 : -6,
                top: -4,
                child: Container(
                  padding: EdgeInsets.all(w < 350 ? 2 : 3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: BoxConstraints(minWidth: w < 350 ? 14 : 16, minHeight: w < 350 ? 14 : 16),
                  child: Center(
                    child: Text('$badge',
                        style: TextStyle(color: Colors.white, fontSize: w < 350 ? 8 : 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Drawer ───────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 10),
                  const Text("Admin Dashboard",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(widget.username, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            _drawerItem(Icons.dashboard, "Dashboard", () => Navigator.pop(context)),
            const Divider(),
            _drawerItem(Icons.notifications, "Alerts & Notifications", () async {
              Navigator.pop(context);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationsPage(token: widget.token, isAdmin: true)));
              _loadNotificationCount();
            }, badge: notificationCount),
            _drawerItem(Icons.people, "User Management", () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => UsersPage(token: widget.token, currentUserId: widget.userId)));
            }),
            _drawerItem(Icons.shopping_cart, "Manage Orders", () async {
              Navigator.pop(context);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AdminOrdersPage(token: widget.token)));
              fetchNewOrdersCount();
              fetchProducts();
            }, badge: newOrdersCount),
            _drawerItem(Icons.local_offer, "Manage Coupons", () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AdminCouponsPage(token: widget.token)));
            }),
            _drawerItem(Icons.rate_review, "Manage Reviews", () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AdminReviewsPage(token: widget.token)));
            }),
            const Divider(),
            _drawerItem(Icons.add_circle, "Add New Product", () {
              Navigator.pop(context);
              showProductModal(null);
            }, iconColor: accentGreen),
            if (kIsWeb)
              _drawerItem(Icons.file_download, "Export Products CSV", () {
                Navigator.pop(context);
                exportCSV();
              }, iconColor: Colors.blueGrey),
            const Divider(),
            _drawerItem(Icons.logout, "Logout", () {
              Navigator.pop(context);
              logout();
            }, iconColor: Colors.red, textColor: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    int? badge,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? primaryIndigo),
      title: Text(title, style: TextStyle(color: textColor ?? darkGrey, fontSize: 14)),
      trailing: badge != null && badge > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text('$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          : null,
      onTap: onTap,
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w             = MediaQuery.of(context).size.width;
    final bool isSmartwatch = w < 250;
    final bool isVerySmall  = w >= 250 && w < 350;
    final bool isSmall      = w >= 350 && w < 600;
    final bool isTablet     = w >= 600 && w < 900;
    final bool isCardSmall  = isSmartwatch || isVerySmall;

    final int prodCols = isSmartwatch || isVerySmall ? 1 : isSmall ? 2 : isTablet ? 3 : 4;

    // ✅ Aspect ratio tuned so 3-button stack always fits
    final double prodAspect =
        isSmartwatch ? 0.60 : isVerySmall ? 0.62 : isSmall ? 0.65 : 0.68;

    final double outerPad = isSmartwatch ? 4 : isVerySmall ? 8 : 12;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightGrey,
      drawer: w < 600 ? _buildDrawer() : null,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryIndigo,
        automaticallyImplyLeading: false,
        leading: w < 600
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.admin_panel_settings, color: Colors.white, size: w < 350 ? 18 : 22),
          SizedBox(width: w < 350 ? 4 : 8),
          Flexible(
            child: Text(
              w < 350 ? "Admin" : "Admin Dashboard",
              style: TextStyle(color: Colors.white, fontSize: w < 350 ? 14 : 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        actions: [
          if (w >= 600) ...[
            navButton(Icons.notifications, "Alerts", () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationsPage(token: widget.token, isAdmin: true)));
              _loadNotificationCount();
            }, badge: notificationCount),
            navButton(Icons.people, "Users", () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => UsersPage(token: widget.token, currentUserId: widget.userId)))),
            navButton(Icons.shopping_cart, "Orders", () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AdminOrdersPage(token: widget.token)));
              fetchNewOrdersCount();
              fetchProducts();
            }, badge: newOrdersCount),
            navButton(Icons.local_offer, "Coupons", () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminCouponsPage(token: widget.token)))),
            navButton(Icons.rate_review, "Reviews", () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AdminReviewsPage(token: widget.token)))),
          ],
          navButton(Icons.add, w < 350 ? "Add" : "Add Product", () => showProductModal(null)),
          if (kIsWeb) navButton(Icons.file_download, w < 350 ? "CSV" : "Export", exportCSV),
          navButton(Icons.logout, w < 350 ? "" : "Logout", logout),
          SizedBox(width: w < 350 ? 4 : 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryIndigo))
          : SingleChildScrollView(
              padding: EdgeInsets.all(outerPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome
                  Padding(
                    padding: EdgeInsets.only(bottom: isSmartwatch ? 8 : 12),
                    child: Text(
                      isSmartwatch
                          ? "Hi, ${widget.username}!"
                          : isVerySmall
                              ? "Welcome, ${widget.username}!"
                              : "Welcome, ${widget.username}! 👋",
                      style: TextStyle(
                        fontSize: isSmartwatch ? 14 : isVerySmall ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                  ),

                  // Analytics Row
                  LayoutBuilder(builder: (lbCtx, bc) {
                    final isTiny   = isSmartwatch || isVerySmall;
                    final spacing  = isTiny ? 4.0 : 8.0;
                    final cols     = isTiny ? 2 : isSmall ? 3 : 5;
                    final cardW    = (bc.maxWidth - spacing * (cols - 1)) / cols;
                    final cardH    = w >= 900 ? cardW * 0.62
                                   : w >= 600 ? cardW * 0.72
                                   : isSmall  ? cardW * 0.90
                                   : isVerySmall ? cardW * 1.05
                                   : cardW * 1.10;
                    final revStr   = isTiny
                        ? "Rs ${(_revenue / 1000).toStringAsFixed(1)}K"
                        : "Rs ${_revenue.toStringAsFixed(0)}";
                    final cards = [
                      analyticsCard("Total Products", "$_totalProducts",  Icons.inventory_2,           accentGreen),
                      analyticsCard("In Stock",       "$_inStock",         Icons.check_circle,          Colors.blue),
                      analyticsCard("Low Stock",      "$_lowStock",        Icons.warning_amber_rounded,  Colors.orange),
                      analyticsCard("Out of Stock",   "$_outOfStock",      Icons.remove_shopping_cart,  Colors.red.shade600),
                      analyticsCard("Revenue",        revStr,              Icons.attach_money,          Colors.amber.shade700),
                    ];
                    if (!isTiny && !isSmall) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 5,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: cardW / cardH,
                        children: cards,
                      );
                    }
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: cards.map((c) => SizedBox(width: cardW, height: cardH, child: c)).toList(),
                    );
                  }),

                  SizedBox(height: isSmartwatch ? 8 : 16),

                  // Search + Filter
                  Row(children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: darkGrey, fontSize: isSmartwatch ? 11 : 14),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: mediumGrey, size: isSmartwatch ? 16 : 20),
                          hintText: isSmartwatch ? "Search" : "Search products",
                          hintStyle: TextStyle(color: mediumGrey, fontSize: isSmartwatch ? 11 : 14),
                          filled: true,
                          fillColor: white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGrey)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderGrey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: primaryIndigo, width: 2)),
                          contentPadding: EdgeInsets.symmetric(vertical: isSmartwatch ? 8 : 12, horizontal: isSmartwatch ? 8 : 12),
                        ),
                        onChanged: (v) { searchQuery = v; applyFilters(); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: isSmartwatch ? 4 : 8),
                      decoration: BoxDecoration(
                          color: white, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderGrey)),
                      child: DropdownButton<String>(
                        value: stockFilter,
                        underline: const SizedBox(),
                        dropdownColor: white,
                        style: TextStyle(color: darkGrey, fontSize: isSmartwatch ? 10 : 13),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text("All")),
                          DropdownMenuItem(value: 'in',  child: Text("In Stock")),
                          DropdownMenuItem(value: 'low', child: Text("Low Stock")),
                          DropdownMenuItem(value: 'out', child: Text("Out of Stock")),
                        ],
                        onChanged: (v) { stockFilter = v!; applyFilters(); },
                      ),
                    ),
                  ]),

                  SizedBox(height: isSmartwatch ? 8 : 16),

                  // Product Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginatedProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: prodCols,
                      mainAxisSpacing: isSmartwatch ? 4 : 12,
                      crossAxisSpacing: isSmartwatch ? 4 : 12,
                      childAspectRatio: prodAspect,
                    ),
                    itemBuilder: (_, i) => buildProductCard(paginatedProducts[i], isCardSmall),
                  ),

                  const SizedBox(height: 20),
                  const FooterWidget(),
                ],
              ),
            ),
    );
  }
}