// lib/screens/checkout_screen.dart - FIXED VERSION

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cart;
  final String token;
  final bool isBuyNow; // ✅ NEW: Flag to indicate if this is a direct purchase

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.token,
    this.isBuyNow = false, // ✅ Default to false for backward compatibility
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();

  double _discountAmount = 0.0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  // ================= CALCULATE SUBTOTAL =================
  double get subtotal {
    return widget.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  // ================= CALCULATE TOTAL =================
  double get total {
    return subtotal - _discountAmount;
  }

  // ================= APPLY COUPON =================
  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      TopPopup.show(context, "Please enter a coupon code", Colors.orange);
      return;
    }

    try {
      final discount = await ApiService.applyCoupon(
        code: code,
        cartTotal: subtotal,
        token: widget.token,
      );

      if (discount != null && discount > 0) {
        setState(() => _discountAmount = discount);
        TopPopup.show(
          context,
          "Coupon applied! You saved Rs ${discount.toStringAsFixed(2)}",
          Colors.green,
        );
      } else {
        TopPopup.show(context, "Invalid or expired coupon", Colors.red);
      }
    } catch (e) {
      TopPopup.show(context, "Failed to apply coupon", Colors.red);
    }
  }

  // ================= PLACE ORDER =================
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      int? orderId;

      // ✅ FIX: Use different endpoints based on order type
      if (widget.isBuyNow && widget.cart.length == 1) {
        // For Buy Now: Use the buy_now endpoint
        final item = widget.cart.first;
        final response = await _placeBuyNowOrder(item);
        
        if (response != null && response['id'] != null) {
          orderId = response['id'] as int;
        }
      } else {
        // For Cart: Use the regular order endpoint
        final response = await ApiService.placeOrderFromCart(
          token: widget.token,
          orderData: {
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'email': _emailController.text.trim(),
            'coupon_code': _couponController.text.trim(),
          },
        );

        if (response != null && response['id'] != null) {
          orderId = response['id'] as int;
        }
      }

      if (!mounted) return;

      if (orderId != null) {
        // Success - navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: orderId!,
              token: widget.token,
              discountFromCheckout: _discountAmount,
            ),
          ),
        );
      } else {
        setState(() => _isProcessing = false);
        TopPopup.show(context, "Order failed. Please try again.", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      TopPopup.show(context, "Error: ${e.toString()}", Colors.red);
    }
  }

  // ✅ NEW METHOD: Place Buy Now order using the dedicated endpoint
  Future<Map<String, dynamic>?> _placeBuyNowOrder(CartItem item) async {
    try {
      debugPrint("🛒 Placing Buy Now order for product: ${item.productId}");
      
      final orderData = {
        'product_id': item.productId,
        'quantity': item.quantity,
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'coupon_code': _couponController.text.trim(),
      };

      debugPrint("📝 Buy Now order data: $orderData");

      final response = await ApiService.placeBuyNowOrder(
        token: widget.token,
        orderData: orderData,
      );

      debugPrint("📡 Buy Now response: $response");
      return response;
    } catch (e) {
      debugPrint("❌ Buy Now order error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.indigo),
                  SizedBox(height: 16),
                  Text("Processing your order...", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== ORDER SUMMARY ==========
                    _buildOrderSummary(),
                    const SizedBox(height: 24),

                    // ========== CUSTOMER DETAILS ==========
                    _buildCustomerDetailsSection(),
                    const SizedBox(height: 24),

                    // ========== COUPON SECTION ==========
                    _buildCouponSection(),
                    const SizedBox(height: 24),

                    // ========== PRICE BREAKDOWN ==========
                    _buildPriceBreakdown(),
                    const SizedBox(height: 32),

                    // ========== PLACE ORDER BUTTON ==========
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Place Order",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ========== ORDER SUMMARY CARD ==========
  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ...widget.cart.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item.quantity}x",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      "Rs ${(item.quantity * item.price).toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ========== CUSTOMER DETAILS SECTION ==========
  Widget _buildCustomerDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? "Name required" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty ? "Phone required" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email (optional)",
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Delivery Address",
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (v) => v == null || v.trim().isEmpty ? "Address required" : null,
            ),
          ],
        ),
      ),
    );
  }

  // ========== COUPON SECTION ==========
  Widget _buildCouponSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Have a Coupon?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      hintText: "Enter coupon code",
                      prefixIcon: Icon(Icons.local_offer),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== PRICE BREAKDOWN ==========
  Widget _buildPriceBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPriceRow("Subtotal", subtotal),
            if (_discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow("Discount", -_discountAmount, color: Colors.green),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rs ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          amount < 0
              ? "- Rs ${amount.abs().toStringAsFixed(2)}"
              : "Rs ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}