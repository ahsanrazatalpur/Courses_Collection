// lib/models/review.dart - UPDATED WITH MISSING FIELDS

class Review {
  final int? id;
  final int productId;
  final String productName;
  final String username;
  final String userName;
  final int rating;
  final String? title;
  final String comment;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ✅ NEW: Missing fields
  final bool isEdited;
  final int likesCount;
  final bool userHasLiked;

  Review({
    this.id,
    required this.productId,
    required this.productName,
    required this.username,
    required this.userName,
    required this.rating,
    this.title,
    required this.comment,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,        // ✅ NEW
    this.likesCount = 0,          // ✅ NEW
    this.userHasLiked = false,    // ✅ NEW
  });

  // ================= FROM JSON =================
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product'],
      productName: json['product_name'] ?? 'Unknown Product',
      username: json['username'] ?? 'Anonymous',
      userName: json['user_name'] ?? json['username'] ?? 'Anonymous',
      rating: json['rating'] ?? 0,
      title: json['title'],
      comment: json['comment'] ?? '',
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      // ✅ NEW: Parse new fields
      isEdited: json['is_edited'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      userHasLiked: json['user_has_liked'] ?? false,
    );
  }

  // ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product': productId,
      'rating': rating,
      if (title != null && title!.isNotEmpty) 'title': title,
      'comment': comment,
    };
  }

  // ================= COPY WITH =================
  Review copyWith({
    int? id,
    int? productId,
    String? productName,
    String? username,
    String? userName,
    int? rating,
    String? title,
    String? comment,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,        // ✅ NEW
    int? likesCount,       // ✅ NEW
    bool? userHasLiked,    // ✅ NEW
  }) {
    return Review(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      username: username ?? this.username,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,           // ✅ NEW
      likesCount: likesCount ?? this.likesCount,     // ✅ NEW
      userHasLiked: userHasLiked ?? this.userHasLiked, // ✅ NEW
    );
  }

  // ================= HELPER: TIME AGO =================
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}


// ================= PRODUCT REVIEW SUMMARY =================
class ProductReviewSummary {
  final int productId;
  final String productName;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<Review> reviews;

  ProductReviewSummary({
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.reviews,
  });

  factory ProductReviewSummary.fromJson(Map<String, dynamic> json) {
    // Parse rating distribution
    final Map<int, int> distribution = {};
    final ratingDist = json['rating_distribution'] as Map<String, dynamic>? ?? {};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = ratingDist['${i}_star'] ?? 0;
    }

    // Parse reviews list
    final reviewsList = (json['reviews'] as List<dynamic>? ?? [])
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductReviewSummary(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? 'Unknown',
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      ratingDistribution: distribution,
      reviews: reviewsList,
    );
  }
}


// ================= REVIEW ELIGIBILITY =================
class ReviewEligibility {
  final bool canReview;
  final String reason;
  final Review? existingReview;

  ReviewEligibility({
    required this.canReview,
    required this.reason,
    this.existingReview,
  });

  factory ReviewEligibility.fromJson(Map<String, dynamic> json) {
    return ReviewEligibility(
      canReview: json['can_review'] ?? false,
      reason: json['reason'] ?? '',
      existingReview: json['existing_review'] != null
          ? Review.fromJson(json['existing_review'])
          : null,
    );
  }
}


// ================= PENDING REVIEW PRODUCT =================
class PendingReviewProduct {
  final int id;
  final String name;
  final String? image;
  final double price;

  PendingReviewProduct({
    required this.id,
    required this.name,
    this.image,
    required this.price,
  });

  factory PendingReviewProduct.fromJson(Map<String, dynamic> json) {
    return PendingReviewProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      image: json['image'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}