// lib/models/order.dart

class Order {
  final int? id;

  // Customer info
  final String customerName;
  final String customerPhone;
  final String customerAddress;

  // Order info
  final double total;
  final String status;
  final DateTime createdAt;

  // Items
  final List<OrderItem> items;

  // Coupon / Discount info
  final bool couponApplied;
  final double discountAmount;

  Order({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
    this.couponApplied = false,
    this.discountAmount = 0.0,
  });

  // ====================== FROM JSON ========================
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['full_name'] ?? json['customerName'] ?? '',
      customerPhone: json['phone'] ?? '',
      customerAddress: json['address'] ?? '',
      total: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      couponApplied: json['coupon_applied'] ?? (json['coupon'] != null),
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  // ======================== TO JSON ========================
  Map<String, dynamic> toJson() {
    return {
      'full_name': customerName,
      'phone': customerPhone,
      'address': customerAddress,
      'total_amount': total,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'coupon_applied': couponApplied,
      'discount_amount': discountAmount,
    };
  }
}

// ===========================================================
// ======================= ORDER ITEM ========================
// ===========================================================

class OrderItem {
  final int productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  // ====================== FROM JSON ========================
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product']?['id'] ?? json['product_id'] ?? 0,
      name: json['name'] ?? json['product']?['name'] ?? json['product_name'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? 
             json['product']?['price']?.toString() ?? '0') ?? 0.0,
    );
  }

  // ======================== TO JSON ========================
  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}