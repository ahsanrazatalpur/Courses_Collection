// lib/pages/order_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import '../widgets/footer_widget.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String token;

  const OrderHistoryScreen({super.key, required this.token});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> orders = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset < 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // ================= FETCH ORDERS =================
  Future<void> fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.fetchOrders(token: widget.token);
      if (!mounted) return;
      setState(() {
        orders = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load orders: $e")),
      );
    }
  }

  // ================= STATUS COLOR =================
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // ================= STATUS ICON =================
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time;
      case 'shipped':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  // ================= STATUS MESSAGE =================
  String getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return "Your order is being processed";
      case 'shipped':
        return "Your order has been shipped 🚚";
      case 'cancelled':
        return "Your order has been cancelled";
      case 'delivered':
        return "Your order has been delivered ✓";
      default:
        return status;
    }
  }

  // ================= ORDER CARD =================
  Widget buildOrderCard(Order order, bool isMobile, bool isTablet) {
    final orderId = order.id ?? 0;

    // Format order date
    String createdAt = '';
    try {
      createdAt = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);
    } catch (_) {}

    final items = order.items;
    final double total = order.total;
    final String status = order.status;
    final Color statusColor = getStatusColor(status);

    // Responsive sizing
    final double cardPadding = isMobile ? 12.0 : (isTablet ? 16.0 : 20.0);
    final double iconSize = isMobile ? 24.0 : 28.0;
    final double titleFontSize = isMobile ? 16.0 : 18.0;
    final double statusIconSize = isMobile ? 28.0 : 32.0;
    final double statusFontSize = isMobile ? 14.0 : 16.0;
    
    // Responsive horizontal margins - full width on desktop
    final double horizontalMargin = isMobile ? 8.0 : (isTablet ? 16.0 : 24.0);

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 6 : 8,
        horizontal: horizontalMargin,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== ORDER HEADER ==========
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.indigo, size: iconSize),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #$orderId",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                          color: Colors.indigo,
                        ),
                      ),
                      if (createdAt.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            createdAt,
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Order count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${items.length} ${items.length == 1 ? 'item' : 'items'}",
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // ========== COLORFUL STATUS BANNER ==========
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.8),
                    statusColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    getStatusIcon(status),
                    color: Colors.white,
                    size: statusIconSize,
                  ),
                  SizedBox(width: isMobile ? 10 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: statusFontSize,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getStatusMessage(status),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 12 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // ========== ITEMS LIST ==========
            Text(
              "Items:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 13 : 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            
            // Responsive item layout
            if (isMobile)
              // Compact mobile layout
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${item.quantity}x",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text(
                          "Rs ${(item.price * item.quantity).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              // Regular tablet/desktop layout
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(6),
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
                          item.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        "Rs ${(item.price * item.quantity).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            SizedBox(height: isMobile ? 8 : 12),
            const Divider(),

            // ========== TOTAL & DISCOUNT ==========
            if (order.discountAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discount:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                    Text(
                      "- Rs ${order.discountAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: isMobile ? 4 : 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Rs ${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: isMobile ? 17 : 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              "Order History",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
          ],
        ),
        actions: [
          if (orders.isNotEmpty && !_isLoading)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  "${orders.length} ${orders.length == 1 ? 'Order' : 'Orders'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            )
          : orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: isMobile ? 80 : 100,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        Text(
                          "No orders yet",
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your order history will appear here",
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: fetchOrders,
                      color: Colors.indigo,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: isMobile ? 4 : (isTablet ? 12 : 20),
                          right: isMobile ? 4 : (isTablet ? 12 : 20),
                          top: isMobile ? 8 : 12,
                          bottom: isMobile ? 8 : 12,
                        ),
                        itemCount: orders.length + 1, // +1 for footer
                        itemBuilder: (_, index) {
                          // Show footer as last item (scrolls with content)
                          if (index == orders.length) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: isMobile ? 16 : 24,
                                bottom: isMobile ? 16 : 24,
                              ),
                              child: const FooterWidget(),
                            );
                          }
                          return buildOrderCard(orders[index], isMobile, isTablet);
                        },
                      ),
                    ),
                    // Scroll to top button
                    if (_showScrollToTop)
                      Positioned(
                        right: isMobile ? 16 : 24,
                        bottom: isMobile ? 16 : 24,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: _scrollToTop,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: isMobile ? 50 : 56,
                              height: isMobile ? 50 : 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.indigo, Colors.indigoAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: isMobile ? 24 : 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}