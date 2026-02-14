// lib/pages/admin_orders_page.dart - ENHANCED WITH BETTER READABILITY

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../models/order.dart';

class AdminOrdersPage extends StatefulWidget {
  final String token;

  const AdminOrdersPage({super.key, required this.token});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<Order> orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Theme colors
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.fetchAllOrders(token: widget.token);
      
      if (!mounted) return;
      
      setState(() {
        orders = data;
        _isLoading = false;
        _errorMessage = null;
      });

      debugPrint("✅ Orders loaded successfully: ${orders.length} orders");
    } catch (e) {
      debugPrint("❌ Error loading orders: $e");
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load orders: $e";
      });
      
      if (mounted) {
        TopPopup.show(context, "Failed to load orders: $e", Colors.red);
      }
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Updating...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final ok = await ApiService.updateOrderStatusByAdmin(
        orderId: orderId,
        status: newStatus,
        token: widget.token,
      );

      if (!mounted) return;
      
      Navigator.of(context).pop();

      if (ok) {
        if (mounted) {
          TopPopup.show(context, "Order updated to $newStatus ✓", accentGreen);
        }
        await fetchOrders();
      } else {
        if (mounted) {
          TopPopup.show(context, "Failed to update order", Colors.red);
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating order: $e");
      
      if (!mounted) return;
      
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        TopPopup.show(context, "Error: $e", Colors.red);
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return accentGreen;
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.purple;
      case 'out for delivery':
        return Colors.teal;
      default:
        return mediumGrey;
    }
  }

  // Hover button with green hover
  Widget hoverButton({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    EdgeInsets? padding,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: StatefulBuilder(
        builder: (context, setStateHover) {
          bool isHovered = false;
          return GestureDetector(
            onTap: onTap,
            child: MouseRegion(
              onEnter: (_) => setStateHover(() => isHovered = true),
              onExit: (_) => setStateHover(() => isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: padding ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isHovered ? accentGreen : (color ?? primaryIndigo),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isHovered
                      ? [BoxShadow(color: accentGreen.withOpacity(0.3), blurRadius: 8, offset: Offset(0, 2))]
                      : [],
                ),
                child: Center(child: child),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ NEW: Info row widget for better organization
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
    bool isSmall = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 6 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isSmall ? 16 : 18,
            color: iconColor ?? primaryIndigo,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    color: mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    color: valueColor ?? darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderCard(Order order, bool isSmall) {
    final String status = order.status;
    final String username = order.customerName.isNotEmpty
        ? order.customerName
        : "Guest User";
    final String items = order.items.isNotEmpty
        ? order.items.map((item) => "${item.quantity}x ${item.name}").join(', ')
        : "No items";

    return Card(
      elevation: 3,
      shadowColor: primaryIndigo.withOpacity(0.2),
      color: white,
      margin: EdgeInsets.symmetric(
        vertical: isSmall ? 8 : 10,
        horizontal: isSmall ? 10 : 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryIndigo.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== HEADER SECTION ==========
          Container(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            decoration: BoxDecoration(
              color: primaryIndigo.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmall ? 8 : 10),
                  decoration: BoxDecoration(
                    color: primaryIndigo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: isSmall ? 18 : 22,
                  ),
                ),
                SizedBox(width: isSmall ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order.id}",
                        style: TextStyle(
                          color: primaryIndigo,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 16 : 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        username,
                        style: TextStyle(
                          color: darkGrey,
                          fontSize: isSmall ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 10 : 14,
                    vertical: isSmall ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: getStatusColor(status).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========== ORDER INFORMATION SECTION ==========
          Padding(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Items Section
                _buildInfoRow(
                  icon: Icons.shopping_bag,
                  label: "Items Ordered",
                  value: items,
                  iconColor: primaryIndigo,
                  isSmall: isSmall,
                ),

                Divider(height: isSmall ? 16 : 20, color: lightGrey),

                // Contact Information
                if (order.customerPhone.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.phone,
                    label: "Phone Number",
                    value: order.customerPhone,
                    iconColor: Colors.blue,
                    isSmall: isSmall,
                  ),

                if (order.customerAddress.isNotEmpty) ...[
                  if (order.customerPhone.isNotEmpty)
                    Divider(height: isSmall ? 16 : 20, color: lightGrey),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: "Delivery Address",
                    value: order.customerAddress,
                    iconColor: Colors.red,
                    isSmall: isSmall,
                  ),
                ],

                Divider(height: isSmall ? 16 : 20, color: lightGrey),

                // Financial Information
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.access_time,
                        label: "Order Date",
                        value: order.createdAt.toString().split('.')[0].split(' ')[0],
                        iconColor: mediumGrey,
                        isSmall: isSmall,
                      ),
                    ),
                    if (order.discountAmount > 0)
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.discount,
                          label: "Discount",
                          value: "Rs ${order.discountAmount.toStringAsFixed(2)}",
                          iconColor: Colors.orange,
                          valueColor: Colors.orange,
                          isSmall: isSmall,
                        ),
                      ),
                  ],
                ),

                Divider(height: isSmall ? 16 : 20, color: lightGrey),

                // Total Amount - Highlighted
                Container(
                  padding: EdgeInsets.all(isSmall ? 12 : 14),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments,
                            color: accentGreen,
                            size: isSmall ? 20 : 24,
                          ),
                          SizedBox(width: isSmall ? 8 : 10),
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              color: darkGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmall ? 14 : 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Rs ${order.total.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 18 : 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========== ACTION BUTTONS SECTION ==========
          if (status.toLowerCase() != 'delivered' && status.toLowerCase() != 'cancelled') ...[
            Divider(height: 1, color: lightGrey),
            Padding(
              padding: EdgeInsets.all(isSmall ? 12 : 16),
              child: _buildActionButtons(order, status, isSmall),
            ),
          ] else
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmall ? 12 : 16,
                0,
                isSmall ? 12 : 16,
                isSmall ? 12 : 16,
              ),
              child: _buildStatusIndicator(status, isSmall),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order, String status, bool isSmall) {
    if (status.toLowerCase() == 'pending') {
      return Row(
        children: [
          Flexible(
            child: hoverButton(
              onTap: () => updateOrderStatus(order.id!, 'Cancelled'),
              color: Colors.red,
              padding: EdgeInsets.symmetric(
                vertical: isSmall ? 10 : 12,
                horizontal: isSmall ? 8 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, size: isSmall ? 16 : 18, color: Colors.white),
                  SizedBox(width: isSmall ? 4 : 6),
                  Text(
                    "Cancel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 13 : 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: isSmall ? 8 : 10),
          Flexible(
            child: hoverButton(
              onTap: () => updateOrderStatus(order.id!, 'Shipped'),
              color: Colors.blue,
              padding: EdgeInsets.symmetric(
                vertical: isSmall ? 10 : 12,
                horizontal: isSmall ? 8 : 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, size: isSmall ? 16 : 18, color: Colors.white),
                  SizedBox(width: isSmall ? 4 : 6),
                  Text(
                    "Ship Order",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 13 : 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (status.toLowerCase() == 'shipped') {
      return SizedBox(
        width: double.infinity,
        child: hoverButton(
          onTap: () => updateOrderStatus(order.id!, 'Delivered'),
          color: accentGreen,
          padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: isSmall ? 18 : 20, color: Colors.white),
              SizedBox(width: isSmall ? 6 : 8),
              Text(
                "Mark as Delivered",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 14 : 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildStatusIndicator(String status, bool isSmall) {
    final bool isDelivered = status.toLowerCase() == 'delivered';
    final Color statusColor = isDelivered ? accentGreen : Colors.red;
    final IconData statusIcon = isDelivered ? Icons.check_circle : Icons.cancel;
    final String statusText = isDelivered ? "Order Completed" : "Order Cancelled";

    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: isSmall ? 22 : 24),
          SizedBox(width: isSmall ? 8 : 10),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final bool isSmartwatch = width < 250;
    final bool isVerySmall = width >= 250 && width < 350;
    final bool isSmall = width >= 350 && width < 600;
    
    final bool isCardSmall = isSmartwatch || isVerySmall;

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment, color: Colors.white, size: width < 350 ? 20 : 24),
            SizedBox(width: width < 350 ? 6 : 8),
            Text(
              width < 350 ? "Orders" : "Manage Orders",
              style: TextStyle(
                color: Colors.white,
                fontSize: width < 350 ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (!isCardSmall && orders.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
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
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: width < 350 ? 20 : 24,
            ),
            onPressed: fetchOrders,
            tooltip: 'Refresh',
          ),
          SizedBox(width: width < 350 ? 4 : 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryIndigo,
                strokeWidth: 3,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isCardSmall ? 60 : 80,
                          color: Colors.red,
                        ),
                        SizedBox(height: isCardSmall ? 12 : 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: darkGrey,
                            fontSize: isCardSmall ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isCardSmall ? 12 : 16),
                        hoverButton(
                          onTap: fetchOrders,
                          padding: EdgeInsets.symmetric(
                            horizontal: isCardSmall ? 16 : 24,
                            vertical: isCardSmall ? 10 : 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, color: Colors.white, size: isCardSmall ? 18 : 20),
                              SizedBox(width: 8),
                              Text(
                                "Retry",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isCardSmall ? 13 : 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: isCardSmall ? 60 : 80,
                              color: mediumGrey,
                            ),
                            SizedBox(height: isCardSmall ? 12 : 16),
                            Text(
                              "No orders found",
                              style: TextStyle(
                                color: darkGrey,
                                fontSize: isCardSmall ? 16 : 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Orders will appear here when users place them",
                              style: TextStyle(
                                color: mediumGrey,
                                fontSize: isCardSmall ? 12 : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isCardSmall ? 16 : 24),
                            hoverButton(
                              onTap: fetchOrders,
                              padding: EdgeInsets.symmetric(
                                horizontal: isCardSmall ? 16 : 24,
                                vertical: isCardSmall ? 10 : 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, color: Colors.white, size: isCardSmall ? 18 : 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Refresh",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isCardSmall ? 13 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchOrders,
                      color: primaryIndigo,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: isCardSmall ? 8 : 12,
                        ),
                        itemCount: orders.length,
                        itemBuilder: (_, i) => buildOrderCard(orders[i], isCardSmall),
                      ),
                    ),
    );
  }
}