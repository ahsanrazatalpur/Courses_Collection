// lib/pages/my_reviews_page.dart - ENHANCED RESPONSIVE VERSION

import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../widgets/review_submission_dialog.dart';
import '../widgets/footer_widget.dart';

class MyReviewsPage extends StatefulWidget {
  final String token;

  const MyReviewsPage({super.key, required this.token});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Review> _myReviews = [];
  List<PendingReviewProduct> _pendingReviews = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadMyReviews(),
      _loadPendingReviews(),
    ]);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMyReviews() async {
    try {
      final reviews = await ApiService.fetchMyReviews(token: widget.token);
      if (mounted) {
        setState(() => _myReviews = reviews);
      }
    } catch (e) {
      debugPrint("Error loading my reviews: $e");
    }
  }

  Future<void> _loadPendingReviews() async {
    try {
      final pending = await ApiService.fetchPendingReviews(token: widget.token);
      if (mounted) {
        setState(() => _pendingReviews = pending);
      }
    } catch (e) {
      debugPrint("Error loading pending reviews: $e");
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

    final success = await ApiService.deleteReview(
      reviewId: review.id!,
      token: widget.token,
    );

    if (!mounted) return;

    if (success) {
      TopPopup.show(context, "Review deleted", Colors.green);
      _loadData();
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

  Widget _buildReviewCard(Review review, bool isMobile, bool isTablet) {
    final cardPadding = isMobile ? 12.0 : (isTablet ? 14.0 : 16.0);
    final titleFontSize = isMobile ? 15.0 : (isTablet ? 15.5 : 16.0);
    final textFontSize = isMobile ? 13.0 : (isTablet ? 13.5 : 14.0);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isTablet ? 16 : 20),
        vertical: isMobile ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and verified badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.productName,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                if (review.isVerified)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: isMobile ? 12 : 14,
                          color: Colors.green,
                        ),
                        SizedBox(width: isMobile ? 3 : 4),
                        Text(
                          "Verified",
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: isMobile ? 6 : 8),
            
            // Rating and date - FIXED FOR MOBILE
            Row(
              children: [
                _buildStars(review.rating, size: isMobile ? 12 : 16),
                SizedBox(width: isMobile ? 4 : 8),
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
                  SizedBox(width: isMobile ? 3 : 4),
                  Text(
                    "(edited)",
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: isMobile ? 10 : 12),
            
            // Title (if present)
            if (review.title != null && review.title!.isNotEmpty) ...[
              Text(
                review.title!,
                style: TextStyle(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
            ],
            
            // Comment
            Text(
              review.comment,
              style: TextStyle(fontSize: textFontSize),
            ),
            
            SizedBox(height: isMobile ? 10 : 12),
            
            // Likes info
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: isMobile ? 14 : 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${review.likesCount} ${review.likesCount == 1 ? 'like' : 'likes'}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: isMobile ? 12 : 16),
            
            // Action buttons - responsive layout
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ReviewSubmissionDialog(
                              productId: review.productId,
                              productName: review.productName,
                              token: widget.token,
                              existingReviewId: review.id,
                              existingRating: review.rating,
                              existingTitle: review.title,
                              existingComment: review.comment,
                              onSuccess: _loadData,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text("Edit Review"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          side: const BorderSide(color: Colors.indigo),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _deleteReview(review),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text("Delete Review"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ReviewSubmissionDialog(
                              productId: review.productId,
                              productName: review.productName,
                              token: widget.token,
                              existingReviewId: review.id,
                              existingRating: review.rating,
                              existingTitle: review.title,
                              existingComment: review.comment,
                              onSuccess: _loadData,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit"),
                        style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _deleteReview(review),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Delete"),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(PendingReviewProduct product, bool isMobile, bool isTablet) {
    final imageSize = isMobile ? 50.0 : (isTablet ? 55.0 : 60.0);
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isTablet ? 16 : 20),
        vertical: isMobile ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 12),
        child: Row(
          children: [
            // Product image
            product.image != null && product.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: isMobile ? 24 : 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: isMobile ? 24 : 30,
                      color: Colors.grey,
                    ),
                  ),
            SizedBox(width: isMobile ? 10 : 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs ${product.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                ],
              ),
            ),
            // Write review button
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ReviewSubmissionDialog(
                    productId: product.id,
                    productName: product.name,
                    token: widget.token,
                    onSuccess: _loadData,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 8 : 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isMobile ? "Write" : "Write Review",
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReviewsTab(bool isMobile, bool isTablet) {
    if (_myReviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: isMobile ? 64 : 80,
                color: Colors.grey,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                "You haven't written any reviews yet",
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Purchase and receive products to leave reviews",
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: isMobile ? 6 : 8,
        bottom: isMobile ? 6 : 8,
      ),
      itemCount: _myReviews.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        // Show footer as last item
        if (index == _myReviews.length) {
          return Padding(
            padding: EdgeInsets.only(
              top: isMobile ? 16 : 24,
              bottom: isMobile ? 16 : 24,
            ),
            child: const FooterWidget(),
          );
        }
        return _buildReviewCard(_myReviews[index], isMobile, isTablet);
      },
    );
  }

  Widget _buildPendingReviewsTab(bool isMobile, bool isTablet) {
    if (_pendingReviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: isMobile ? 64 : 80,
                color: Colors.green,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                "You're all caught up!",
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "No products waiting for review",
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

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: isMobile ? 6 : 8,
        bottom: isMobile ? 6 : 8,
      ),
      itemCount: _pendingReviews.length + 1, // +1 for footer
      itemBuilder: (context, index) {
        // Show footer as last item
        if (index == _pendingReviews.length) {
          return Padding(
            padding: EdgeInsets.only(
              top: isMobile ? 16 : 24,
              bottom: isMobile ? 16 : 24,
            ),
            child: const FooterWidget(),
          );
        }
        return _buildPendingCard(_pendingReviews[index], isMobile, isTablet);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final tabFontSize = isMobile ? 13.0 : 14.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        // ✅ Left-aligned title with review icon
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "My Reviews",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.rate_review,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: tabFontSize,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(fontSize: tabFontSize),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review, size: isMobile ? 18 : 20),
                  SizedBox(width: isMobile ? 4 : 8),
                  Flexible(
                    child: Text(
                      isMobile ? "My (${_myReviews.length})" : "My Reviews (${_myReviews.length})",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions, size: isMobile ? 18 : 20),
                  SizedBox(width: isMobile ? 4 : 8),
                  Flexible(
                    child: Text(
                      "Pending (${_pendingReviews.length})",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            )
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _loadData,
                  color: Colors.indigo,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyReviewsTab(isMobile, isTablet),
                      _buildPendingReviewsTab(isMobile, isTablet),
                    ],
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