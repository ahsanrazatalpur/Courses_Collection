// lib/models/notification.dart

class AppNotification {
  final String id;
  final String type; // 'low_stock', 'out_of_stock', 'review_reminder', 'order_update'
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data; // Extra data (product_id, order_id, etc.)

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      if (data != null) 'data': data,
    };
  }

  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}