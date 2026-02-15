// lib/pages/product_reviews_page.dart - FIXED

import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../widgets/review_submission_dialog.dart';

class ProductReviewsPage extends StatefulWidget {
  final int productId;
  final String productName;
  final String token;
  final bool isAdmin;

  const ProductReviewsPage({
    super.key,
    required this.productId,
    required this.productName,
    required this.token,
    this.isAdmin = false,
  });

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  Map<String, dynamic>? _reviewData;
  List<Review> _reviews = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  int _selectedRatingFilter = 0; // 0 = all ratings
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
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

  Future<void> _loadReviews({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore) return;
      _currentPage++;
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _reviews = [];
      });
    }

    final data = await ApiService.fetchProductReviews(
      productId: widget.productId,
      page: _currentPage,
      pageSize: _pageSize,
      token: widget.token,
    );

    if (!mounted) return;

    if (data != null) {
      // ✅ FIX: Properly convert List<dynamic> to List<Review>
      final List<dynamic> reviewsJson = data['reviews'] as List<dynamic>;
      final List<Review> newReviews = reviewsJson
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        if (loadMore) {
          _reviews.addAll(newReviews);  // ✅ Now this works!
        } else {
          _reviews = newReviews;  // ✅ Now this works!
          _reviewData = data;
        }
        _hasMore = data['has_more'] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _likeReview(Review review) async {
    final result = await ApiService.toggleReviewLike(
      reviewId: review.id!,
      token: widget.token,
    );

    if (result != null && mounted) {
      setState(() {
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index >= 0) {
          _reviews[index] = review.copyWith(
            // Update like count locally for immediate feedback
          );
        }
      });
      _loadReviews(); // Refresh to get accurate data
    }
  }

  Future<void> _deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure you want to delete this review?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    bool success;
    if (widget.isAdmin) {
      success = await ApiService.adminDeleteReview(
        reviewId: review.id!,
        token: widget.token,
      );
    } else {
      success = await ApiService.deleteReview(
        reviewId: review.id!,
        token: widget.token,
      );
    }

    if (!mounted) return;

    if (success) {
      TopPopup.show(context, "Review deleted", Colors.green);
      _loadReviews();
    } else {
      TopPopup.show(context, "Failed to delete review", Colors.red);
    }
  }

  Widget _buildStars(int rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  Widget _buildRatingSummary() {
    if (_reviewData == null) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    final avgRating = _reviewData!['average_rating'] ?? 0.0;
    final totalReviews = _reviewData!['total_reviews'] ?? 0;
    final distribution = _reviewData!['rating_distribution'] as Map<String, dynamic>? ?? {};

    return Card(
      margin: EdgeInsets.all(isMobile ? 12 : (isTablet ? 16 : 20)),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive layout: Column for mobile, Row for tablet/desktop
            isMobile
                ? Column(
                    children: [
                      // Average rating
                      Column(
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          _buildStars(avgRating.round(), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            "$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Rating distribution - FIXED FOR MOBILE
                      Column(
                        children: List.generate(5, (index) {
                          final star = 5 - index;
                          final count = distribution['${star}_star'] ?? 0;
                          final percentage = totalReviews > 0
                              ? (count / totalReviews * 100).round()
                              : 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  child: Text(
                                    '$star',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.shade300,
                                    color: Colors.amber,
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '$percentage%',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Average rating
                      Column(
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          _buildStars(avgRating.round(), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            "$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      // Rating distribution
                      Expanded(
                        child: Column(
                          children: List.generate(5, (index) {
                            final star = 5 - index;
                            final count = distribution['${star}_star'] ?? 0;
                            final percentage = totalReviews > 0
                                ? (count / totalReviews * 100).round()
                                : 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text('$star'),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey.shade300,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '$percentage%',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;
    final isOwner = !widget.isAdmin; // In user context, they can edit their own

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isTablet ? 16 : 20),
        vertical: isMobile ? 6 : 8,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  radius: isMobile ? 18 : 20,
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (review.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.verified, size: 12, color: Colors.green),
                                  SizedBox(width: 2),
                                  Text(
                                    "Verified",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStars(review.rating, size: isMobile ? 14 : 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              review.timeAgo,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (review.isEdited) ...[
                            const SizedBox(width: 8),
                            const Text(
                              "(edited)",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons
                if (isOwner || widget.isAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: isMobile ? 20 : 24,
                    ),
                    onSelected: (value) {
                      if (value == 'edit' && isOwner) {
                        showDialog(
                          context: context,
                          builder: (_) => ReviewSubmissionDialog(
                            productId: widget.productId,
                            productName: widget.productName,
                            token: widget.token,
                            existingReviewId: review.id,
                            existingRating: review.rating,
                            existingTitle: review.title,
                            existingComment: review.comment,
                            onSuccess: _loadReviews,
                          ),
                        );
                      } else if (value == 'delete') {
                        _deleteReview(review);
                      }
                    },
                    itemBuilder: (context) => [
                      if (isOwner)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: isMobile ? 10 : 12),

            // Title (if present)
            if (review.title != null && review.title!.isNotEmpty) ...[
              Text(
                review.title!,
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Comment
            Text(
              review.comment,
              style: TextStyle(fontSize: isMobile ? 13 : 14),
            ),

            SizedBox(height: isMobile ? 10 : 12),
            const Divider(),
            const SizedBox(height: 8),

            // Like button and count
            Row(
              children: [
                InkWell(
                  onTap: () => _likeReview(review),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        review.userHasLiked ? Icons.favorite : Icons.favorite_border,
                        size: isMobile ? 18 : 20,
                        color: review.userHasLiked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${review.likesCount}',
                        style: TextStyle(
                          color: review.userHasLiked ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reviews",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
            Text(
              widget.productName,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isMobile ? 11 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading && _reviews.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => _loadReviews(),
                  child: _reviews.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 6 : 8,
                          ),
                          itemCount: _reviews.length + 2, // +1 for summary, +1 for load more
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildRatingSummary();
                            } else if (index == _reviews.length + 1) {
                              return _hasMore
                                  ? Padding(
                                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                                      child: Center(
                                        child: ElevatedButton(
                                          onPressed: () => _loadReviews(loadMore: true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigo,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isMobile ? 24 : 32,
                                              vertical: isMobile ? 12 : 16,
                                            ),
                                          ),
                                          child: Text(
                                            "Load More",
                                            style: TextStyle(
                                              fontSize: isMobile ? 14 : 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            } else {
                              return _buildReviewCard(_reviews[index - 1]);
                            }
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

  Widget _buildEmptyState() {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: isMobile ? 56 : 64,
              color: Colors.grey,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              "No reviews yet",
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Be the first to review this product",
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}