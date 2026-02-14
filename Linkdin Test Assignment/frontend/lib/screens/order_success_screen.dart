// lib/screens/order_success_screen.dart - ENHANCED RESPONSIVE VERSION

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import '../dashboards/user_dashboard.dart';

class OrderSuccessScreen extends StatefulWidget {
  final int orderId;
  final String token;
  final double discountFromCheckout;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.token,
    this.discountFromCheckout = 0.0,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  Order? order;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final fetchedOrder = await ApiService.fetchOrder(
        widget.orderId,
        token: widget.token,
      );

      if (!mounted) return;

      setState(() {
        order = fetchedOrder;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => isLoading = false);
      debugPrint("Error fetching order: $e");
    }
  }

  void goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => UserDashboard(
          token: widget.token,
          username: order?.customerName ?? "User",
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Responsive sizing
    final iconSize = isMobile ? 56.0 : 72.0;
    final titleFontSize = isMobile ? 22.0 : 26.0;
    final orderIdFontSize = isMobile ? 16.0 : 18.0;
    final sectionTitleSize = isMobile ? 16.0 : 18.0;
    final cardPadding = isMobile ? 14.0 : 16.0;
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);

    return WillPopScope(
      onWillPop: () async {
        goToDashboard();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          backgroundColor: Colors.indigo, // ✅ Changed to indigo
          iconTheme: const IconThemeData(color: Colors.white), // ✅ White back button
          // ✅ Left-aligned title with confirmation icon
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Order Confirmation",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 20,
                ),
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
            : order == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: isMobile ? 80 : 100,
                            color: Colors.red,
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          Text(
                            "Failed to load order details",
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: goToDashboard,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 24 : 32,
                                vertical: isMobile ? 12 : 16,
                              ),
                            ),
                            icon: const Icon(Icons.home),
                            label: const Text("Go to Dashboard"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 700 : (isMobile ? double.infinity : 900),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          children: [
                            SizedBox(height: isMobile ? 16 : 24),
                            
                            // ========== SUCCESS ICON ==========
                            Container(
                              padding: EdgeInsets.all(isMobile ? 20 : 24),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                size: iconSize,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: isMobile ? 20 : 24),

                            // ========== SUCCESS MESSAGE ==========
                            Text(
                              "Order Placed Successfully!",
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Order #${order!.id}",
                              style: TextStyle(
                                fontSize: orderIdFontSize,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // ========== ORDER DETAILS CARD ==========
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Details",
                                      style: TextStyle(
                                        fontSize: sectionTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(height: isMobile ? 20 : 24),

                                    // ========== CUSTOMER INFO ==========
                                    _buildDetailRow(
                                      "Customer",
                                      order!.customerName,
                                      Icons.person,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 10 : 12),
                                    _buildDetailRow(
                                      "Phone",
                                      order!.customerPhone,
                                      Icons.phone,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 10 : 12),
                                    _buildDetailRow(
                                      "Address",
                                      order!.customerAddress,
                                      Icons.location_on,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 10 : 12),
                                    _buildDetailRow(
                                      "Status",
                                      order!.status,
                                      Icons.info,
                                      isMobile,
                                      valueColor: Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 12 : 16),

                            // ========== ORDER ITEMS ==========
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order Items",
                                      style: TextStyle(
                                        fontSize: sectionTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(height: isMobile ? 20 : 24),
                                    
                                    // Items list - responsive layout
                                    ...order!.items.map((item) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: isMobile ? 10 : 12,
                                        ),
                                        child: isMobile
                                            ? _buildMobileItemRow(item)
                                            : _buildDesktopItemRow(item),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 12 : 16),

                            // ========== PRICE SUMMARY ==========
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Summary",
                                      style: TextStyle(
                                        fontSize: sectionTitleSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(height: isMobile ? 20 : 24),

                                    // Calculate subtotal from items
                                    _buildPriceRow(
                                      "Subtotal",
                                      order!.items.fold<double>(
                                        0,
                                        (sum, item) => sum + (item.quantity * item.price),
                                      ),
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 10 : 12),

                                    // Show discount if applicable
                                    if (order!.discountAmount > 0) ...[
                                      _buildPriceRow(
                                        "Discount",
                                        -order!.discountAmount,
                                        isMobile,
                                        valueColor: Colors.green,
                                        isDiscount: true,
                                      ),
                                      SizedBox(height: isMobile ? 10 : 12),
                                    ],

                                    const Divider(),
                                    SizedBox(height: isMobile ? 10 : 12),

                                    // Total
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total",
                                          style: TextStyle(
                                            fontSize: isMobile ? 18 : 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Rs ${order!.total.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: isMobile ? 20 : 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // ========== ACTION BUTTONS ==========
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: isMobile ? 14 : 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: goToDashboard,
                                icon: const Icon(Icons.home),
                                label: Text(
                                  "Back to Home",
                                  style: TextStyle(
                                    fontSize: isMobile ? 15 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 20 : 24),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  // Responsive item row for mobile
  Widget _buildMobileItemRow(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${item.quantity}x",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 42),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rs ${item.price.toStringAsFixed(2)} each",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                "Rs ${(item.quantity * item.price).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Regular item row for desktop/tablet
  Widget _buildDesktopItemRow(item) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${item.quantity}x",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Rs ${item.price.toStringAsFixed(2)} each",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          "Rs ${(item.quantity * item.price).toStringAsFixed(2)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    bool isMobile, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isMobile ? 18 : 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    bool isMobile, {
    Color? valueColor,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          isDiscount
              ? "- Rs ${amount.abs().toStringAsFixed(2)}"
              : "Rs ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}