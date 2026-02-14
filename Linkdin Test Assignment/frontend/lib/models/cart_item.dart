// lib/models/cart_item.dart

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product']['id'] ?? 0,
      productName: json['product']['name'] ?? '',

      // ✅ FIX BUG 1: Django returns price as String e.g. "2000.00"
      // double.tryParse handles both String and num safely
      price: double.tryParse(
              json['product']['price']?.toString() ?? '0') ??
          0.0,

      quantity: json['quantity'] ?? 1,
      image: json['product']['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
        'image': image,
      };
}