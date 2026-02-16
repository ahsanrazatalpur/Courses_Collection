// lib/models/product.dart - WITH REVIEW FIELDS AND IMAGE_DISPLAY SUPPORT

import 'dart:io';

class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int stock;
  final File? imageFile;
  
  // Stock status fields
  final String stockStatus;
  final bool isInStock;
  final bool isLowStock;
  final bool isOutOfStock;
  
  // Review fields
  final double averageRating;
  final int reviewCount;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.stock,
    this.imageFile,
    this.stockStatus = 'in_stock',
    this.isInStock = true,
    this.isLowStock = false,
    this.isOutOfStock = false,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0;
    if (json['price'] != null) {
      if (json['price'] is String) {
        parsedPrice = double.tryParse(json['price']) ?? 0;
      } else if (json['price'] is num) {
        parsedPrice = (json['price'] as num).toDouble();
      }
    }

    // ✅ FIXED: Use image_display from backend (priority over image and image_url)
    String? imageUrl;
    if (json['image_display'] != null && (json['image_display'] as String).isNotEmpty) {
      imageUrl = json['image_display'];
    } else if (json['image_url'] != null && (json['image_url'] as String).isNotEmpty) {
      imageUrl = json['image_url'];
    } else if (json['image'] != null && (json['image'] as String).isNotEmpty) {
      imageUrl = json['image'];
    }

    return Product(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsedPrice,
      image: imageUrl,
      stock: json['stock'] != null
          ? int.tryParse(json['stock'].toString()) ?? 0
          : 0,
      imageFile: null,
      stockStatus: json['stock_status'] ?? 'in_stock',
      isInStock: json['is_in_stock'] ?? true,
      isLowStock: json['is_low_stock'] ?? false,
      isOutOfStock: json['is_out_of_stock'] ?? false,
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString()) ?? 0.0
          : 0.0,
      reviewCount: json['review_count'] != null
          ? int.tryParse(json['review_count'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'average_rating': averageRating,
      'review_count': reviewCount,
    };
    if (image != null) map['image'] = image;
    if (id != null) map['id'] = id;
    return map;
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    int? stock,
    File? imageFile,
    String? stockStatus,
    bool? isInStock,
    bool? isLowStock,
    bool? isOutOfStock,
    double? averageRating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      stock: stock ?? this.stock,
      imageFile: imageFile ?? this.imageFile,
      stockStatus: stockStatus ?? this.stockStatus,
      isInStock: isInStock ?? this.isInStock,
      isLowStock: isLowStock ?? this.isLowStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}