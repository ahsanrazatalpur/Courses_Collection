// lib/models/coupon.dart

class Coupon {
  final int? id;
  final String code;
  final String discountType; // 'percentage' or 'flat'
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final double minimumCartValue;
  final int? usageLimit;
  final bool isActive;
  final int timesUsed;

  Coupon({
    this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.minimumCartValue,
    this.usageLimit,
    required this.isActive,
    this.timesUsed = 0,
  });

  // ====================== FROM JSON ========================
  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      minimumCartValue: double.tryParse(json['minimum_cart_value']?.toString() ?? '0') ?? 0.0,
      usageLimit: json['usage_limit'],
      isActive: json['is_active'] ?? true,
      timesUsed: json['times_used'] ?? 0,
    );
  }

  // ======================== TO JSON ========================
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'minimum_cart_value': minimumCartValue,
      'usage_limit': usageLimit,
      'is_active': isActive,
      'times_used': timesUsed,
    };
  }
}