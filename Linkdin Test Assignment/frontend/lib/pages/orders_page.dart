// lib/pages/orders_page.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../models/order.dart';

class OrdersPage extends StatefulWidget {
  final String token;

  const OrdersPage({super.key, required this.token});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Order> orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  // ================= FETCH ALL ORDERS =================
  Future<void> fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.fetchAllOrders(token: widget.token);
      if (!mounted) return;
      setState(() {
        orders = data;
        _isLoading = false;
      });
    } catch (e) {
      TopPopup.show(context, "Failed to load orders", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // ================= UPDATE ORDER STATUS =================
  Future<void> updateOrderStatus(int orderId, String status) async {
    final success =
        await ApiService.updateOrderStatus(orderId, status, token: widget.token);
    if (success) {
      TopPopup.show(context, "Status updated", Colors.green);
      fetchOrders();
    } else {
      TopPopup.show(context, "Failed to update", Colors.red);
    }
  }

  // ================= SHOW ORDER DETAILS MODAL =================
  void showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 360,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order #${order.id}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Customer: ${order.customerName}"),
                Text("Phone: ${order.customerPhone}"),
                Text("Address: ${order.customerAddress}"),
                Text("Created: ${order.createdAt.toLocal()}"),
                const SizedBox(height: 8),
                Text(
                  "Total: Rs ${order.total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (order.couponApplied)
                  Text(
                    "Discount: Rs ${order.discountAmount.toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.green),
                  ),
                const Divider(height: 20),
                const Text("Items", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    itemCount: order.items.length,
                    itemBuilder: (_, i) {
                      final item = order.items[i];
                      return ListTile(
                        dense: true,
                        title: Text(item.name),
                        subtitle: Text("Quantity: ${item.quantity}"),
                        trailing: Text("Rs ${item.price.toStringAsFixed(2)}"),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Update Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: order.status.toLowerCase(),
                  items: const [
                    DropdownMenuItem(value: "pending", child: Text("Pending")),
                    DropdownMenuItem(value: "processing", child: Text("Processing")),
                    DropdownMenuItem(value: "completed", child: Text("Completed")),
                    DropdownMenuItem(value: "cancelled", child: Text("Cancelled")),
                  ],
                  onChanged: (v) {
                    if (v != null) updateOrderStatus(order.id!, v);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders"), backgroundColor: Colors.indigo),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            )
          : orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text("Order #${order.id} - ${order.customerName}"),
                        subtitle: Text(
                            "Status: ${order.status}\nTotal: Rs ${order.total.toStringAsFixed(2)}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.indigo),
                          onPressed: () => showOrderDetails(order),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
