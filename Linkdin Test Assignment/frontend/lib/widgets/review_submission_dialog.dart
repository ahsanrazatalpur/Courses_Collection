// lib/widgets/review_submission_dialog.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';

class ReviewSubmissionDialog extends StatefulWidget {
  final int productId;
  final String productName;
  final String token;
  final int? existingReviewId;
  final int? existingRating;
  final String? existingTitle;
  final String? existingComment;
  final VoidCallback? onSuccess;

  const ReviewSubmissionDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.token,
    this.existingReviewId,
    this.existingRating,
    this.existingTitle,
    this.existingComment,
    this.onSuccess,
  });

  @override
  State<ReviewSubmissionDialog> createState() => _ReviewSubmissionDialogState();
}

class _ReviewSubmissionDialogState extends State<ReviewSubmissionDialog> {
  int _rating = 0;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill if editing existing review
    if (widget.existingReviewId != null) {
      _rating = widget.existingRating ?? 0;
      _titleController.text = widget.existingTitle ?? '';
      _commentController.text = widget.existingComment ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    // Validation
    if (_rating == 0) {
      TopPopup.show(context, "Please select a rating", Colors.orange);
      return;
    }
    
    if (_commentController.text.trim().isEmpty) {
      TopPopup.show(context, "Please write a review", Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    bool success;
    
    if (widget.existingReviewId != null) {
      // Update existing review
      success = await ApiService.updateReview(
        reviewId: widget.existingReviewId!,
        rating: _rating,
        comment: _commentController.text.trim(),
        title: _titleController.text.trim().isEmpty 
            ? null 
            : _titleController.text.trim(),
        token: widget.token,
      );
    } else {
      // Submit new review
      success = await ApiService.submitReview(
        productId: widget.productId,
        rating: _rating,
        comment: _commentController.text.trim(),
        title: _titleController.text.trim().isEmpty 
            ? null 
            : _titleController.text.trim(),
        token: widget.token,
      );
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      TopPopup.show(
        context, 
        widget.existingReviewId != null 
            ? "Review updated successfully!" 
            : "Review submitted successfully!",
        Colors.green
      );
      
      // Call success callback
      widget.onSuccess?.call();
    } else {
      TopPopup.show(
        context, 
        "Failed to submit review. Please try again.",
        Colors.red
      );
    }
  }

  // ✅ FIXED: Mobile-friendly star rating that doesn't overflow
  Widget _buildStarRating() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // ✅ Responsive star size - smaller on mobile
    final starSize = isMobile ? 32.0 : 40.0;
    final starSpacing = isMobile ? 4.0 : 8.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: starSpacing / 2),
          child: GestureDetector(
            onTap: () {
              setState(() => _rating = starNumber);
            },
            child: Icon(
              starNumber <= _rating ? Icons.star : Icons.star_border,
              color: starNumber <= _rating ? Colors.amber : Colors.grey,
              size: starSize,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReviewId != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth - 32 : 400,
          ),
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Review' : 'Write a Review',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              SizedBox(height: isMobile ? 6 : 8),
              
              // Product name
              Text(
                widget.productName,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.grey,
                ),
              ),
              
              SizedBox(height: isMobile ? 20 : 24),
              
              // Star rating
              Text(
                'Your Rating',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 10 : 12),
              _buildStarRating(),
              
              SizedBox(height: isMobile ? 20 : 24),
              
              // Title field (optional)
              TextField(
                controller: _titleController,
                style: TextStyle(fontSize: isMobile ? 14 : 16),
                decoration: InputDecoration(
                  labelText: 'Review Title (Optional)',
                  labelStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                  hintText: 'Summarize your review',
                  hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
                maxLength: 200,
              ),
              
              SizedBox(height: isMobile ? 12 : 16),
              
              // Comment field (required)
              TextField(
                controller: _commentController,
                style: TextStyle(fontSize: isMobile ? 14 : 16),
                decoration: InputDecoration(
                  labelText: 'Your Review *',
                  labelStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                  hintText: 'Share your experience with this product',
                  hintStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  alignLabelWithHint: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                ),
                maxLines: isMobile ? 4 : 5,
                maxLength: 1000,
              ),
              
              SizedBox(height: isMobile ? 20 : 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: isMobile ? 44 : 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: isMobile ? 18 : 20,
                          width: isMobile ? 18 : 20,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Review' : 'Submit Review',
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}