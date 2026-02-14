// lib/pages/cart_page.dart
// ✅ FIXED: Notification removed, fully responsive Android, spam protection, cleaner UX

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../models/cart_item.dart';
import '../screens/checkout_screen.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartProducts;
  final String token;

  const CartPage({
    super.key,
    required this.cartProducts,
    required this.token,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> cartItems;

  // ── Spam protection: track which productIds are currently being updated ──
  final Set<int> _loadingItems = {};

  // ── Color palette (matches rest of app) ──────────────────────────────────
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen   = Color(0xFF4CAF50);
  static const Color lightGrey     = Color(0xFFF5F5F5);
  static const Color borderGrey    = Color(0xFFE0E0E0);
  static const Color darkGrey      = Color(0xFF424242);
  static const Color mediumGrey    = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    cartItems = widget.cartProducts
        .map((item) => CartItem(
              id:          item.id,
              productId:   item.productId,
              productName: item.productName,
              price:       item.price,
              quantity:    item.quantity,
              image:       item.image,
            ))
        .toList();
  }

  // ── Remove item ───────────────────────────────────────────────────────────
  Future<void> removeItem(CartItem item) async {
    if (_loadingItems.contains(item.productId)) return; // spam guard
    setState(() => _loadingItems.add(item.productId));

    final success = await ApiService.removeFromCart(
      productId: item.productId,
      token: widget.token,
    );

    if (!mounted) return;
    setState(() => _loadingItems.remove(item.productId));

    if (success) {
      setState(() =>
          cartItems.removeWhere((i) => i.productId == item.productId));
      TopPopup.show(context, "${item.productName} removed from cart", Colors.redAccent);
    } else {
      TopPopup.show(context, "Failed to remove item", Colors.red);
    }
  }

  // ── Confirm remove (swipe or button) ─────────────────────────────────────
  Future<void> _confirmRemove(CartItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Remove item?",
            style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
        content: Text("Remove \"${item.productName}\" from your cart?",
            style: TextStyle(color: darkGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
    if (confirm == true) await removeItem(item);
  }

  // ── Update quantity ───────────────────────────────────────────────────────
  // Silent on success (no snackbar spam), only shows error on failure
  Future<void> updateQuantity(CartItem item, int newQty) async {
    if (newQty <= 0) return;
    if (_loadingItems.contains(item.productId)) return; // spam guard
    setState(() => _loadingItems.add(item.productId));

    final success = await ApiService.updateCartItemQuantity(
      productId: item.productId,
      quantity:  newQty,
      token:     widget.token,
    );

    if (!mounted) return;
    setState(() => _loadingItems.remove(item.productId));

    if (success) {
      setState(() {
        final idx = cartItems.indexWhere((i) => i.productId == item.productId);
        if (idx >= 0) cartItems[idx].quantity = newQty;
      });
    } else {
      TopPopup.show(context, "Failed to update quantity", Colors.red);
    }
  }

  // ── Totals ────────────────────────────────────────────────────────────────
  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);

  int get totalItems =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  // ── Checkout ──────────────────────────────────────────────────────────────
  void handleCheckout() {
    if (cartItems.isEmpty) {
      TopPopup.show(context, "Cart is empty", Colors.red);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(token: widget.token, cart: cartItems),
      ),
    );
  }

  // ── Product image ─────────────────────────────────────────────────────────
  Widget _buildImage(String? url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size, height: size, color: lightGrey,
        child: (url == null || url.isEmpty)
            ? Icon(Icons.shopping_bag_outlined, size: size * 0.5, color: mediumGrey)
            : Image.network(url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.shopping_bag_outlined, size: size * 0.5, color: mediumGrey)),
      ),
    );
  }

  // ── Quantity control row ──────────────────────────────────────────────────
  Widget _buildQtyControl(CartItem item, {required bool isVerySmall}) {
    final bool loading = _loadingItems.contains(item.productId);
    final btnSize  = isVerySmall ? 28.0 : 32.0;
    final iconSize = isVerySmall ? 14.0 : 16.0;
    final numSize  = isVerySmall ? 13.0 : 15.0;

    return Container(
      decoration: BoxDecoration(
        color: primaryIndigo.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryIndigo.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          SizedBox(
            width: btnSize, height: btnSize,
            child: loading
                ? const Center(child: SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryIndigo)))
                : IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.remove, size: iconSize,
                        color: item.quantity > 1 ? primaryIndigo : mediumGrey),
                    onPressed: item.quantity > 1 && !loading
                        ? () => updateQuantity(item, item.quantity - 1)
                        : null,
                  ),
          ),
          // Quantity display
          Container(
            constraints: BoxConstraints(minWidth: isVerySmall ? 28 : 32),
            alignment: Alignment.center,
            child: Text(item.quantity.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: numSize,
                    color: darkGrey)),
          ),
          // Increase button
          SizedBox(
            width: btnSize, height: btnSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.add, size: iconSize, color: primaryIndigo),
              onPressed: !loading
                  ? () => updateQuantity(item, item.quantity + 1)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cart item card ────────────────────────────────────────────────────────
  Widget _buildCartCard(CartItem item, {
    required bool isVerySmall,
    required bool isSmall,
  }) {
    final imgSize    = isVerySmall ? 52.0 : isSmall ? 64.0 : 80.0;
    final nameSz     = isVerySmall ? 13.0 : isSmall ? 14.0 : 16.0;
    final priceSz    = isVerySmall ? 12.0 : isSmall ? 13.0 : 15.0;
    final subtotalSz = isVerySmall ? 11.0 : isSmall ? 12.0 : 14.0;
    final cardPad    = isVerySmall ? 8.0  : isSmall ? 10.0 : 12.0;
    final bool loading = _loadingItems.contains(item.productId);

    return Dismissible(
      key: Key('cart_${item.productId}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        // Ask before actually removing
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text("Remove item?",
                style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
            content: Text("Remove \"${item.productName}\"?",
                style: TextStyle(color: darkGrey)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel", style: TextStyle(color: mediumGrey))),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Remove"),
              ),
            ],
          ),
        );
        return confirm == true;
      },
      onDismissed: (_) => removeItem(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.red, size: isVerySmall ? 22 : 26),
            const SizedBox(height: 2),
            Text("Remove", style: TextStyle(color: Colors.red,
                fontSize: isVerySmall ? 9 : 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: Card(
        elevation: loading ? 1 : 3,
        color: loading ? Colors.white.withOpacity(0.8) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Padding(
          padding: EdgeInsets.all(cardPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top row: image + info + delete ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(item.image, imgSize),
                  SizedBox(width: isVerySmall ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: nameSz,
                                color: darkGrey)),
                        SizedBox(height: isVerySmall ? 3 : 4),
                        Text("Rs ${item.price.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: primaryIndigo,
                                fontWeight: FontWeight.w600,
                                fontSize: priceSz)),
                        SizedBox(height: isVerySmall ? 2 : 3),
                        // Subtotal
                        Row(
                          children: [
                            Icon(Icons.receipt_outlined,
                                size: subtotalSz, color: mediumGrey),
                            const SizedBox(width: 3),
                            Text(
                              "Subtotal: Rs ${(item.price * item.quantity).toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: accentGreen,
                                  fontSize: subtotalSz,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  SizedBox(
                    width: isVerySmall ? 28 : 34,
                    height: isVerySmall ? 28 : 34,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.delete_rounded,
                          color: loading ? mediumGrey : Colors.red,
                          size: isVerySmall ? 18 : 20),
                      onPressed: loading ? null : () => _confirmRemove(item),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isVerySmall ? 6 : 8),

              // ── Bottom row: qty label + qty control ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: isVerySmall ? 12 : 14, color: mediumGrey),
                    const SizedBox(width: 4),
                    Text("${item.quantity} item${item.quantity > 1 ? 's' : ''}",
                        style: TextStyle(
                            fontSize: isVerySmall ? 11 : 13,
                            color: mediumGrey,
                            fontWeight: FontWeight.w500)),
                  ]),
                  _buildQtyControl(item, isVerySmall: isVerySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isVerySmall) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isVerySmall ? 20 : 28),
            decoration: BoxDecoration(
              color: primaryIndigo.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart_outlined,
                size: isVerySmall ? 52 : 72,
                color: primaryIndigo.withOpacity(0.4)),
          ),
          SizedBox(height: isVerySmall ? 16 : 20),
          Text("Your cart is empty",
              style: TextStyle(
                  fontSize: isVerySmall ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: darkGrey)),
          const SizedBox(height: 6),
          Text("Add products to get started!",
              style: TextStyle(
                  fontSize: isVerySmall ? 12 : 14,
                  color: mediumGrey)),
          SizedBox(height: isVerySmall ? 20 : 28),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text("Continue Shopping"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryIndigo,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: isVerySmall ? 16 : 24,
                  vertical: isVerySmall ? 10 : 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool isVerySmall, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isVerySmall ? 10 : isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: primaryIndigo,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: isSmall || isVerySmall
            // ── Mobile: stacked layout ──────────────────────────────────
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Summary row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Total ($totalItems item${totalItems > 1 ? 's' : ''})",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isVerySmall ? 11 : 13)),
                          Text("Rs ${totalPrice.toStringAsFixed(2)}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isVerySmall ? 18 : 20,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      // Item count pill
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isVerySmall ? 10 : 12,
                            vertical: isVerySmall ? 4 : 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text("${cartItems.length} product${cartItems.length > 1 ? 's' : ''}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: isVerySmall ? 10 : 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: isVerySmall ? 8 : 12),
                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.shopping_bag_rounded,
                          size: isVerySmall ? 16 : 18),
                      label: Text("Proceed to Checkout",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isVerySmall ? 13 : 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryIndigo,
                        padding: EdgeInsets.symmetric(
                            vertical: isVerySmall ? 10 : 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: cartItems.isEmpty ? null : handleCheckout,
                    ),
                  ),
                ],
              )
            // ── Desktop/Tablet: side by side ────────────────────────────
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Amount ($totalItems items)",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      Text("Rs ${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_bag_rounded, size: 20),
                    label: const Text("Proceed to Checkout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryIndigo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: cartItems.isEmpty ? null : handleCheckout,
                  ),
                ],
              ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w           = MediaQuery.of(context).size.width;
    final isVerySmall = w < 360;   // small Android phones (360px and below)
    final isSmall     = w < 600;   // normal phones

    final hPad = isVerySmall ? 10.0 : isSmall ? 14.0 : 24.0;

    return Scaffold(
      backgroundColor: lightGrey,

      // ── AppBar — notification completely removed ──────────────────────
      appBar: AppBar(
        backgroundColor: primaryIndigo,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_rounded,
                color: Colors.white, size: isVerySmall ? 20 : 24),
            SizedBox(width: isVerySmall ? 6 : 8),
            Text(
              cartItems.isEmpty
                  ? "My Cart"
                  : "My Cart (${cartItems.length})",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: isVerySmall ? 16 : isSmall ? 18 : 20),
            ),
          ],
        ),
        // ✅ NO notification icon — removed entirely as requested
        // Cart total shown in the bottom bar instead
      ),

      body: cartItems.isEmpty
          ? _buildEmptyState(isVerySmall)
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
              itemCount: cartItems.length,
              itemBuilder: (_, i) => _buildCartCard(
                cartItems[i],
                isVerySmall: isVerySmall,
                isSmall: isSmall,
              ),
            ),

      bottomNavigationBar: _buildBottomBar(isVerySmall, isSmall),
    );
  }
}