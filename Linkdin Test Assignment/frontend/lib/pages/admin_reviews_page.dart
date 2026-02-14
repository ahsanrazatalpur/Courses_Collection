// lib/pages/admin_reviews_page.dart - REDESIGNED CARDS + ANDROID RESPONSIVE

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';

class AdminReviewsPage extends StatefulWidget {
  final String token;
  const AdminReviewsPage({super.key, required this.token});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Review> _allReviews      = [];
  List<Review> _flaggedReviews  = [];
  bool _isLoadingAll     = true;
  bool _isLoadingFlagged = true;

  // ─── Colors ──────────────────────────────────────────────────────────────────
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen   = Color(0xFF4CAF50);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color lightGrey     = Color(0xFFF5F5F5);
  static const Color cardBg        = Color(0xFFFAFAFA);
  static const Color mediumGrey    = Color(0xFF9E9E9E);
  static const Color darkGrey      = Color(0xFF424242);
  static const Color borderGrey    = Color(0xFFE8E8E8);

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    _loadAllReviews();
    _loadFlaggedReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Data ────────────────────────────────────────────────────────────────────
  Future<void> _loadAllReviews() async {
    setState(() => _isLoadingAll = true);
    final reviews = await ApiService.fetchAllReviews(token: widget.token);
    if (!mounted) return;
    setState(() { _allReviews = reviews; _isLoadingAll = false; });
  }

  Future<void> _loadFlaggedReviews() async {
    setState(() => _isLoadingFlagged = true);
    final reviews = await ApiService.fetchFlaggedReviews(token: widget.token);
    if (!mounted) return;
    setState(() { _flaggedReviews = reviews; _isLoadingFlagged = false; });
  }

  Future<void> _deleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Review",
            style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
        content: Text(
          "Delete review by ${review.userName} for \"${review.productName}\"?\n\nThis cannot be undone.",
          style: TextStyle(color: darkGrey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryIndigo,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                SizedBox(height: 16),
                Text("Deleting...",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await ApiService.adminDeleteReview(
        reviewId: review.id!, token: widget.token);
    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      TopPopup.show(context, "Review deleted", accentGreen);
      _loadAllReviews();
      _loadFlaggedReviews();
    } else {
      TopPopup.show(context, "Failed to delete review", Colors.red);
    }
  }

  // ─── Star Row ────────────────────────────────────────────────────────────────
  Widget _stars(int rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
        color: i < rating ? Colors.amber : Colors.amber.withOpacity(0.35),
        size: size,
      )),
    );
  }

  // ─── Review Card ─────────────────────────────────────────────────────────────
  Widget _buildReviewCard(Review review, double screenW) {
    final bool isTiny   = screenW < 320;
    final bool isMobile = screenW < 600;

    final double hPad    = isTiny ? 10 : isMobile ? 14 : 18;
    final double vPad    = isTiny ? 10 : 14;
    final double starSz  = isTiny ? 13 : isMobile ? 15 : 16;
    final double prodSz  = isTiny ? 13 : isMobile ? 15 : 16;
    final double userSz  = isTiny ? 11 : isMobile ? 12 : 13;
    final double bodySz  = isTiny ? 12 : isMobile ? 13 : 14;
    final double metaSz  = isTiny ? 10 : isMobile ? 11 : 12;
    final double avatSz  = isTiny ? 32 : isMobile ? 38 : 42;

    // Avatar initials color based on username
    final List<Color> avatarColors = [
      const Color(0xFF5C6BC0), const Color(0xFF26A69A),
      const Color(0xFFEF5350), const Color(0xFF7E57C2),
      const Color(0xFF29B6F6), const Color(0xFF66BB6A),
    ];
    final Color avatarColor =
        avatarColors[review.userName.hashCode.abs() % avatarColors.length];
    final String initials = review.userName.isNotEmpty
        ? review.userName[0].toUpperCase()
        : '?';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 5 : 7,
      ),
      child: Card(
        elevation: 2,
        shadowColor: primaryIndigo.withOpacity(0.08),
        color: white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderGrey, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── TOP BANNER: Product name + rating bar ──────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: hPad, vertical: isTiny ? 8 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primaryIndigo.withOpacity(0.07),
                    primaryIndigo.withOpacity(0.02),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: borderGrey, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Product icon
                  Container(
                    padding: EdgeInsets.all(isTiny ? 5 : 7),
                    decoration: BoxDecoration(
                      color: primaryIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.shopping_bag_outlined,
                        color: primaryIndigo, size: isTiny ? 14 : 16),
                  ),
                  SizedBox(width: isTiny ? 6 : 10),
                  Expanded(
                    child: Text(
                      review.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: prodSz,
                        fontWeight: FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Star rating compact
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTiny ? 6 : 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.amber.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.amber, size: isTiny ? 11 : 13),
                        const SizedBox(width: 3),
                        Text(
                          "${review.rating}.0",
                          style: TextStyle(
                            fontSize: metaSz,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── User info row ────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar circle
                      Container(
                        width: avatSz,
                        height: avatSz,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: avatSz * 0.42,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isTiny ? 8 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + badges
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    review.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: userSz + 1,
                                      color: darkGrey,
                                    ),
                                  ),
                                ),
                                if (review.isVerified) ...[
                                  SizedBox(width: isTiny ? 4 : 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                          color: accentGreen.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_rounded,
                                            size: isTiny ? 9 : 10,
                                            color: accentGreen),
                                        const SizedBox(width: 2),
                                        Text("Verified",
                                            style: TextStyle(
                                                fontSize: isTiny ? 8 : 9,
                                                color: accentGreen,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Stars + time
                            Row(
                              children: [
                                _stars(review.rating, starSz),
                                SizedBox(width: isTiny ? 6 : 8),
                                Flexible(
                                  child: Text(
                                    review.timeAgo +
                                        (review.isEdited ? " · edited" : ""),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: metaSz,
                                        color: mediumGrey,
                                        fontStyle: review.isEdited
                                            ? FontStyle.italic
                                            : FontStyle.normal),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isTiny ? 10 : 12),

                  // ── Review title ─────────────────────────────────────────
                  if (review.title != null && review.title!.isNotEmpty) ...[
                    Text(
                      review.title!,
                      style: TextStyle(
                        fontSize: bodySz + 1,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    SizedBox(height: isTiny ? 4 : 6),
                  ],

                  // ── Review comment ───────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTiny ? 8 : 10),
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Text(
                      review.comment,
                      style: TextStyle(
                        fontSize: bodySz,
                        color: darkGrey,
                        height: 1.45,
                      ),
                    ),
                  ),

                  SizedBox(height: isTiny ? 10 : 12),

                  // ── Footer: likes + delete ───────────────────────────────
                  Row(
                    children: [
                      // Likes chip
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTiny ? 8 : 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.pink.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_rounded,
                                size: isTiny ? 12 : 14,
                                color: Colors.pink.shade400),
                            SizedBox(width: isTiny ? 3 : 4),
                            Text(
                              "${review.likesCount} ${review.likesCount == 1 ? 'like' : 'likes'}",
                              style: TextStyle(
                                  fontSize: metaSz,
                                  color: Colors.pink.shade400,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Delete button
                      _deleteBtn(
                        onTap: () => _deleteReview(review),
                        small: isTiny,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete Button ────────────────────────────────────────────────────────────
  Widget _deleteBtn({required VoidCallback onTap, required bool small}) {
    return StatefulBuilder(builder: (ctx, setH) {
      bool h = false;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setH(() => h = true),
        onExit:  (_) => setH(() => h = false),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
                horizontal: small ? 10 : 14, vertical: small ? 6 : 8),
            decoration: BoxDecoration(
              color: h ? Colors.red : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: h ? Colors.red : Colors.red.withOpacity(0.35),
                  width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: h ? white : Colors.red,
                    size: small ? 14 : 16),
                SizedBox(width: small ? 3 : 5),
                Text(
                  "Delete",
                  style: TextStyle(
                      color: h ? white : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: small ? 10 : 12),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── Stats Bar ────────────────────────────────────────────────────────────────
  Widget _statsBar(List<Review> reviews, double screenW) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    final bool isTiny = screenW < 320;

    final avg = reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length;
    final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isTiny ? 10 : 16, vertical: 8),
      padding: EdgeInsets.all(isTiny ? 10 : 14),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
              color: primaryIndigo.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Average score
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                    fontSize: isTiny ? 28 : 34,
                    fontWeight: FontWeight.w900,
                    color: primaryIndigo),
              ),
              _stars(avg.round(), isTiny ? 12 : 14),
              SizedBox(height: 2),
              Text("${reviews.length} reviews",
                  style: TextStyle(
                      fontSize: isTiny ? 9 : 11, color: mediumGrey)),
            ],
          ),
          SizedBox(width: isTiny ? 10 : 16),
          // Rating distribution bars
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                final pct   = reviews.isEmpty ? 0.0 : count / reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(children: [
                    Icon(Icons.star_rounded,
                        color: Colors.amber,
                        size: isTiny ? 10 : 12),
                    SizedBox(width: 2),
                    Text("$star",
                        style: TextStyle(
                            fontSize: isTiny ? 9 : 10, color: darkGrey)),
                    SizedBox(width: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: isTiny ? 5 : 7,
                          backgroundColor: lightGrey,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  star >= 4
                                      ? accentGreen
                                      : star == 3
                                          ? Colors.orange
                                          : Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    SizedBox(
                      width: isTiny ? 16 : 20,
                      child: Text("$count",
                          style: TextStyle(
                              fontSize: isTiny ? 9 : 10,
                              color: mediumGrey,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── All Reviews Tab ──────────────────────────────────────────────────────────
  Widget _buildAllTab(double screenW) {
    if (_isLoadingAll) {
      return Center(
          child: CircularProgressIndicator(color: primaryIndigo, strokeWidth: 3));
    }
    if (_allReviews.isEmpty) {
      return _emptyState(
          icon: Icons.rate_review_outlined,
          title: "No Reviews Yet",
          subtitle: "Customer reviews will appear here",
          color: mediumGrey,
          screenW: screenW);
    }
    return RefreshIndicator(
      onRefresh: _loadAllReviews,
      color: primaryIndigo,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _allReviews.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) return _statsBar(_allReviews, screenW);
          return _buildReviewCard(_allReviews[i - 1], screenW);
        },
      ),
    );
  }

  // ─── Flagged Tab ──────────────────────────────────────────────────────────────
  Widget _buildFlaggedTab(double screenW) {
    final bool isTiny = screenW < 320;

    if (_isLoadingFlagged) {
      return Center(
          child: CircularProgressIndicator(color: primaryIndigo, strokeWidth: 3));
    }
    if (_flaggedReviews.isEmpty) {
      return _emptyState(
          icon: Icons.check_circle_outline_rounded,
          title: "All Clear!",
          subtitle: "No flagged reviews at the moment",
          color: accentGreen,
          screenW: screenW);
    }
    return RefreshIndicator(
      onRefresh: _loadFlaggedReviews,
      color: primaryIndigo,
      child: Column(
        children: [
          // Warning banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(
                isTiny ? 10 : 16, 10, isTiny ? 10 : 16, 0),
            padding: EdgeInsets.all(isTiny ? 10 : 13),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.orange.shade200, width: 1),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: isTiny ? 18 : 22),
              SizedBox(width: isTiny ? 8 : 10),
              Expanded(
                child: Text(
                  "Reviews with ≤ 2 stars flagged for moderation",
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: isTiny ? 11 : 12,
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _flaggedReviews.length,
              itemBuilder: (_, i) =>
                  _buildReviewCard(_flaggedReviews[i], screenW),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────────
  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double screenW,
  }) {
    final bool isTiny = screenW < 320;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: isTiny ? 48 : 60, color: color),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: isTiny ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: darkGrey)),
            const SizedBox(height: 6),
            Text(subtitle,
                style:
                    TextStyle(fontSize: isTiny ? 12 : 13, color: mediumGrey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final double w  = MediaQuery.of(context).size.width;
    final bool isTiny  = w < 320;
    final bool isSmall = w < 350;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),

        // ── Title with review icon ───────────────────────────────────────
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                isSmall ? "Reviews" : "Review Moderation",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 15 : 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isSmall ? 6 : 8),
            // ✅ Review icon after text as requested
            Container(
              padding: EdgeInsets.all(isTiny ? 4 : 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.rate_review_rounded,
                color: white,
                size: isSmall ? 16 : 18,
              ),
            ),
          ],
        ),

        // ── Tab Bar ─────────────────────────────────────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: primaryIndigo,
            child: TabBar(
              controller: _tabController,
              indicatorColor: white,
              indicatorWeight: 3,
              labelColor: white,
              unselectedLabelColor: Colors.white60,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTiny ? 11 : 13),
              unselectedLabelStyle: TextStyle(fontSize: isTiny ? 10 : 12),
              tabs: [
                // All reviews tab
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_list_bulleted_rounded,
                          size: isTiny ? 14 : 16),
                      SizedBox(width: isTiny ? 4 : 6),
                      Text(isSmall
                          ? "All (${_allReviews.length})"
                          : "All Reviews (${_allReviews.length})"),
                    ],
                  ),
                ),
                // Flagged tab
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_rounded,
                          size: isTiny ? 14 : 16,
                          color: _flaggedReviews.isNotEmpty
                              ? Colors.orange.shade300
                              : null),
                      SizedBox(width: isTiny ? 4 : 6),
                      Text(
                        isSmall
                            ? "Flagged (${_flaggedReviews.length})"
                            : "Flagged (${_flaggedReviews.length})",
                        style: _flaggedReviews.isNotEmpty
                            ? TextStyle(color: Colors.orange.shade300)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTab(w),
          _buildFlaggedTab(w),
        ],
      ),
    );
  }
}