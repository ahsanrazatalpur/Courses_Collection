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

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return IconButton(
          icon: Icon(
            starNumber <= _rating ? Icons.star : Icons.star_border,
            color: starNumber <= _rating ? Colors.amber : Colors.grey,
            size: 40,
          ),
          onPressed: () {
            setState(() => _rating = starNumber);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReviewId != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Product name
              Text(
                widget.productName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Star rating
              const Text(
                'Your Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStarRating(),
              
              const SizedBox(height: 24),
              
              // Title field (optional)
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Review Title (Optional)',
                  hintText: 'Summarize your review',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                maxLength: 200,
              ),
              
              const SizedBox(height: 16),
              
              // Comment field (required)
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Your Review *',
                  hintText: 'Share your experience with this product',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 1000,
              ),
              
              const SizedBox(height: 24),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48,
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Review' : 'Submit Review',
                          style: const TextStyle(
                            fontSize: 16,
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