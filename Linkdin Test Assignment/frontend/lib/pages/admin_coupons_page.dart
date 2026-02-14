// lib/pages/admin_coupons_page.dart - REDESIGNED CARD UI + ANDROID RESPONSIVE

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../models/coupon.dart';

class AdminCouponsPage extends StatefulWidget {
  final String token;
  const AdminCouponsPage({super.key, required this.token});

  @override
  State<AdminCouponsPage> createState() => _AdminCouponsPageState();
}

class _AdminCouponsPageState extends State<AdminCouponsPage> {
  List<Coupon> coupons = [];
  bool _isLoading = true;

  // ─── Colors ──────────────────────────────────────────────────────────────────
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentGreen   = Color(0xFF4CAF50);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color lightGrey     = Color(0xFFF5F5F5);
  static const Color mediumGrey    = Color(0xFF9E9E9E);
  static const Color darkGrey      = Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  // ─── Data ────────────────────────────────────────────────────────────────────
  Future<void> fetchCoupons() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.fetchCoupons(token: widget.token);
      if (!mounted) return;
      setState(() { coupons = data; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      TopPopup.show(context, "Failed to load coupons: $e", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteCoupon(int id, String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Coupon",
            style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold)),
        content: Text("Delete coupon '$code'?",
            style: TextStyle(color: darkGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: mediumGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

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
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                SizedBox(height: 16),
                Text("Deleting...",
                    style: TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await ApiService.deleteCoupon(id, token: widget.token);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (success) {
      TopPopup.show(context, "Coupon deleted", accentGreen);
      fetchCoupons();
    } else {
      TopPopup.show(context, "Failed to delete coupon", Colors.red);
    }
  }

  // ─── Hover Button ────────────────────────────────────────────────────────────
  Widget _hoverBtn({
    required Widget child,
    required VoidCallback onTap,
    Color? color,
    EdgeInsets? padding,
    double radius = 10,
  }) {
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
            padding: padding ?? const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
            decoration: BoxDecoration(
              color: h ? accentGreen : (color ?? primaryIndigo),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: h
                  ? [BoxShadow(
                      color: accentGreen.withOpacity(0.35),
                      blurRadius: 10, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Center(child: child),
          ),
        ),
      );
    });
  }

  // ─── Modal ───────────────────────────────────────────────────────────────────
  void _showModal({Coupon? coupon}) {
    final isEdit = coupon != null;
    final codeCtrl    = TextEditingController(text: coupon?.code ?? '');
    final valueCtrl   = TextEditingController(text: coupon?.discountValue.toString() ?? '');
    final minCtrl     = TextEditingController(text: coupon?.minimumCartValue.toString() ?? '0');
    final limitCtrl   = TextEditingController(text: coupon?.usageLimit?.toString() ?? '');

    String discountType = coupon?.discountType ?? 'percentage';
    DateTime startDate  = coupon?.startDate ?? DateTime.now();
    DateTime endDate    = coupon?.endDate   ?? DateTime.now().add(const Duration(days: 30));
    bool isActive       = coupon?.isActive  ?? true;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 400 ? 10 : 16,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(builder: (ctx, setM) {
          final sw = MediaQuery.of(ctx).size.width;
          final sm = sw < 400;
          final vg = sm ? 10.0 : 14.0;

          InputDecoration _deco(String label, {String? hint, IconData? icon}) =>
              InputDecoration(
                labelText: label, hintText: hint,
                prefixIcon: icon != null ? Icon(icon, size: sm ? 18 : 20) : null,
                filled: true, fillColor: lightGrey,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: sm ? 10 : 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: accentGreen, width: 2)),
              );

          Widget _dateTile(String label, DateTime date, IconData icon,
              VoidCallback onTap) {
            return InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: sm ? 10 : 13),
                decoration: BoxDecoration(
                    color: lightGrey,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(icon, color: primaryIndigo, size: sm ? 18 : 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: sm ? 10 : 11, color: mediumGrey)),
                      Text(DateFormat('dd MMM yyyy, hh:mm a').format(date),
                          style: TextStyle(
                              fontSize: sm ? 12 : 13,
                              fontWeight: FontWeight.w600,
                              color: darkGrey)),
                    ],
                  )),
                  Icon(Icons.chevron_right, color: mediumGrey, size: 18),
                ]),
              ),
            );
          }

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: EdgeInsets.all(sm ? 14 : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(
                          isEdit ? "Edit Coupon" : "Create Coupon",
                          style: TextStyle(
                              fontSize: sm ? 17 : 20,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo),
                        )),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Divider(height: vg * 1.4),

                    // Code
                    TextField(
                      controller: codeCtrl,
                      style: TextStyle(fontSize: sm ? 13 : 14),
                      textCapitalization: TextCapitalization.characters,
                      decoration: _deco("Coupon Code *",
                          hint: "e.g., SAVE20",
                          icon: Icons.confirmation_number),
                    ),
                    SizedBox(height: vg),

                    // Discount Type toggle (pill style)
                    Text("Discount Type",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: sm ? 12 : 13,
                            color: darkGrey)),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Expanded(child: GestureDetector(
                          onTap: () => setM(() => discountType = 'percentage'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                                vertical: sm ? 9 : 11),
                            decoration: BoxDecoration(
                              color: discountType == 'percentage'
                                  ? primaryIndigo : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.percent,
                                    size: 15,
                                    color: discountType == 'percentage'
                                        ? white : mediumGrey),
                                const SizedBox(width: 4),
                                Text("Percentage",
                                    style: TextStyle(
                                        fontSize: sm ? 11 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: discountType == 'percentage'
                                            ? white : mediumGrey)),
                              ],
                            ),
                          ),
                        )),
                        Expanded(child: GestureDetector(
                          onTap: () => setM(() => discountType = 'flat'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                                vertical: sm ? 9 : 11),
                            decoration: BoxDecoration(
                              color: discountType == 'flat'
                                  ? primaryIndigo : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money,
                                    size: 15,
                                    color: discountType == 'flat'
                                        ? white : mediumGrey),
                                const SizedBox(width: 4),
                                Text("Flat Amount",
                                    style: TextStyle(
                                        fontSize: sm ? 11 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: discountType == 'flat'
                                            ? white : mediumGrey)),
                              ],
                            ),
                          ),
                        )),
                      ]),
                    ),
                    SizedBox(height: vg),

                    // Discount Value
                    TextField(
                      controller: valueCtrl,
                      style: TextStyle(fontSize: sm ? 13 : 14),
                      keyboardType: TextInputType.number,
                      decoration: _deco(
                        discountType == 'percentage'
                            ? "Discount % *" : "Discount Amount (Rs) *",
                        hint: discountType == 'percentage' ? "e.g., 20" : "e.g., 500",
                        icon: discountType == 'percentage'
                            ? Icons.percent : Icons.attach_money,
                      ),
                    ),
                    SizedBox(height: vg),

                    // Min Cart Value
                    TextField(
                      controller: minCtrl,
                      style: TextStyle(fontSize: sm ? 13 : 14),
                      keyboardType: TextInputType.number,
                      decoration: _deco("Min. Cart Value (Rs)",
                          hint: "0 for no minimum",
                          icon: Icons.shopping_cart_outlined),
                    ),
                    SizedBox(height: vg),

                    // Usage Limit
                    TextField(
                      controller: limitCtrl,
                      style: TextStyle(fontSize: sm ? 13 : 14),
                      keyboardType: TextInputType.number,
                      decoration: _deco("Usage Limit",
                          hint: "Leave empty = unlimited",
                          icon: Icons.people_outline),
                    ),
                    SizedBox(height: vg),

                    // Start Date
                    _dateTile("Start Date", startDate, Icons.calendar_today, () async {
                      final d = await showDatePicker(
                        context: ctx, initialDate: startDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d == null) return;
                      final t = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(startDate));
                      if (t != null) {
                        setM(() => startDate = DateTime(
                            d.year, d.month, d.day, t.hour, t.minute));
                      }
                    }),
                    SizedBox(height: vg),

                    // End Date
                    _dateTile("End Date", endDate, Icons.event, () async {
                      final d = await showDatePicker(
                        context: ctx, initialDate: endDate,
                        firstDate: startDate,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d == null) return;
                      final t = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(endDate));
                      if (t != null) {
                        setM(() => endDate = DateTime(
                            d.year, d.month, d.day, t.hour, t.minute));
                      }
                    }),
                    SizedBox(height: vg),

                    // Active toggle
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: sm ? 8 : 10),
                      decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? accentGreen.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            color: isActive ? accentGreen : mediumGrey,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Active Status",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: sm ? 12 : 13)),
                            Text(isActive ? "Coupon is active" : "Coupon is inactive",
                                style: TextStyle(
                                    fontSize: sm ? 10 : 11,
                                    color: mediumGrey)),
                          ],
                        )),
                        Switch(
                          value: isActive,
                          onChanged: (v) => setM(() => isActive = v),
                          activeColor: accentGreen,
                        ),
                      ]),
                    ),
                    SizedBox(height: sm ? 16 : 22),

                    // Buttons
                    Row(children: [
                      Expanded(child: _hoverBtn(
                        color: primaryIndigo,
                        padding: EdgeInsets.symmetric(vertical: sm ? 12 : 14),
                        onTap: () async {
                          if (codeCtrl.text.trim().isEmpty) {
                            TopPopup.show(ctx, "Coupon code is required", Colors.red);
                            return;
                          }
                          if (valueCtrl.text.trim().isEmpty) {
                            TopPopup.show(ctx, "Discount value is required", Colors.red);
                            return;
                          }
                          final c = Coupon(
                            id: coupon?.id,
                            code: codeCtrl.text.trim().toUpperCase(),
                            discountType: discountType,
                            discountValue: double.tryParse(valueCtrl.text) ?? 0,
                            startDate: startDate,
                            endDate: endDate,
                            minimumCartValue: double.tryParse(minCtrl.text) ?? 0,
                            usageLimit: limitCtrl.text.trim().isEmpty
                                ? null : int.tryParse(limitCtrl.text),
                            isActive: isActive,
                            timesUsed: coupon?.timesUsed ?? 0,
                          );
                          final ok = isEdit
                              ? await ApiService.updateCoupon(c, token: widget.token)
                              : await ApiService.createCoupon(c, token: widget.token);
                          if (!mounted) return;
                          if (ok) {
                            Navigator.pop(ctx);
                            fetchCoupons();
                            TopPopup.show(ctx,
                                isEdit ? "Coupon updated!" : "Coupon created!",
                                accentGreen);
                          } else {
                            TopPopup.show(ctx, "Operation failed", Colors.red);
                          }
                        },
                        child: Text(isEdit ? "Update Coupon" : "Create Coupon",
                            style: TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                                fontSize: sm ? 13 : 15)),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: mediumGrey),
                          padding: EdgeInsets.symmetric(vertical: sm ? 12 : 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Cancel",
                            style: TextStyle(
                                color: darkGrey,
                                fontSize: sm ? 13 : 15)),
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── MAIN COUPON CARD ────────────────────────────────────────────────────────
  // Full-width card with a colored left accent bar + all info visible
  Widget _buildCouponCard(Coupon coupon, double screenW) {
    final isExpired    = coupon.endDate.isBefore(DateTime.now());
    final isNotStarted = coupon.startDate.isAfter(DateTime.now());

    final Color statusColor = isExpired
        ? Colors.red
        : isNotStarted
            ? Colors.orange
            : coupon.isActive
                ? accentGreen
                : mediumGrey;

    final String statusText = isExpired
        ? "EXPIRED"
        : isNotStarted
            ? "UPCOMING"
            : coupon.isActive
                ? "ACTIVE"
                : "INACTIVE";

    final IconData statusIcon = isExpired
        ? Icons.cancel_outlined
        : isNotStarted
            ? Icons.schedule
            : coupon.isActive
                ? Icons.check_circle_outline
                : Icons.pause_circle_outline;

    // Responsive sizing
    final bool isTiny   = screenW < 320;
    final bool isMobile = screenW < 600;
    final bool isTablet = screenW >= 600 && screenW < 900;

    final double hPad   = isTiny ? 8 : isMobile ? 12 : isTablet ? 16 : 20;
    final double vPad   = isTiny ? 10 : 14;
    final double codeSz = isTiny ? 14 : isMobile ? 16 : 18;
    final double discSz = isTiny ? 20 : isMobile ? 24 : 28;
    final double labelSz = isTiny ? 9 : 10;
    final double valueSz = isTiny ? 11 : isMobile ? 12 : 13;

    // Discount display
    final String discountText = coupon.discountType == 'percentage'
        ? "${coupon.discountValue.toStringAsFixed(coupon.discountValue % 1 == 0 ? 0 : 1)}%"
        : "Rs ${coupon.discountValue.toStringAsFixed(coupon.discountValue % 1 == 0 ? 0 : 1)}";

    // Usage text
    final String usageText = coupon.usageLimit != null
        ? "${coupon.timesUsed} / ${coupon.usageLimit} used"
        : "${coupon.timesUsed} used (Unlimited)";

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : isTablet ? 14 : 18,
        vertical: 6,
      ),
      child: Card(
        elevation: 3,
        shadowColor: statusColor.withOpacity(0.2),
        color: white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isExpired
                ? Colors.red.withOpacity(0.25)
                : primaryIndigo.withOpacity(0.1),
            width: isExpired ? 1.5 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── LEFT ACCENT BAR + DISCOUNT ──────────────────────────────
              Container(
                width: isTiny ? 64 : isMobile ? 80 : 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryIndigo,
                      primaryIndigo.withOpacity(0.82),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        coupon.discountType == 'percentage'
                            ? Icons.percent
                            : Icons.currency_rupee,
                        color: white,
                        size: isTiny ? 16 : 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        discountText,
                        style: TextStyle(
                          color: white,
                          fontSize: discSz,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Text(
                      "OFF",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isTiny ? 9 : 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── MAIN CONTENT ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: hPad, vertical: vPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ── Row 1: Code + Status badge ──────────────────────
                      Row(
                        children: [
                          // Coupon code chip
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTiny ? 6 : 8,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryIndigo.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: primaryIndigo.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.confirmation_number_outlined,
                                    size: isTiny ? 11 : 13,
                                    color: primaryIndigo),
                                const SizedBox(width: 4),
                                Text(
                                  coupon.code,
                                  style: TextStyle(
                                    color: primaryIndigo,
                                    fontWeight: FontWeight.w800,
                                    fontSize: codeSz,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTiny ? 6 : 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.4),
                                  width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon,
                                    size: isTiny ? 10 : 12,
                                    color: statusColor),
                                SizedBox(width: isTiny ? 2 : 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTiny ? 8 : 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isTiny ? 8 : 10),

                      // ── Row 2: Info chips grid ───────────────────────────
                      // Mobile: 2 columns, Tablet+: 4 across
                      isMobile
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(children: [
                                  Expanded(child: _infoTile(
                                    icon: Icons.shopping_cart_outlined,
                                    label: "Min. Cart",
                                    value: "Rs ${coupon.minimumCartValue.toStringAsFixed(0)}",
                                    color: Colors.blue,
                                    labelSz: labelSz,
                                    valueSz: valueSz,
                                  )),
                                  const SizedBox(width: 8),
                                  Expanded(child: _infoTile(
                                    icon: Icons.people_outline,
                                    label: "Usage",
                                    value: usageText,
                                    color: Colors.purple,
                                    labelSz: labelSz,
                                    valueSz: valueSz,
                                  )),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  Expanded(child: _infoTile(
                                    icon: Icons.calendar_today_outlined,
                                    label: "Starts",
                                    value: DateFormat('dd MMM yy').format(coupon.startDate),
                                    color: accentGreen,
                                    labelSz: labelSz,
                                    valueSz: valueSz,
                                  )),
                                  const SizedBox(width: 8),
                                  Expanded(child: _infoTile(
                                    icon: Icons.event_outlined,
                                    label: "Expires",
                                    value: DateFormat('dd MMM yy').format(coupon.endDate),
                                    color: isExpired ? Colors.red : Colors.orange,
                                    labelSz: labelSz,
                                    valueSz: valueSz,
                                  )),
                                ]),
                              ],
                            )
                          : Row(children: [
                              Expanded(child: _infoTile(
                                icon: Icons.shopping_cart_outlined,
                                label: "Min. Cart",
                                value: "Rs ${coupon.minimumCartValue.toStringAsFixed(0)}",
                                color: Colors.blue,
                                labelSz: labelSz,
                                valueSz: valueSz,
                              )),
                              const SizedBox(width: 6),
                              Expanded(child: _infoTile(
                                icon: Icons.people_outline,
                                label: "Usage",
                                value: usageText,
                                color: Colors.purple,
                                labelSz: labelSz,
                                valueSz: valueSz,
                              )),
                              const SizedBox(width: 6),
                              Expanded(child: _infoTile(
                                icon: Icons.calendar_today_outlined,
                                label: "Starts",
                                value: DateFormat('dd MMM yy').format(coupon.startDate),
                                color: accentGreen,
                                labelSz: labelSz,
                                valueSz: valueSz,
                              )),
                              const SizedBox(width: 6),
                              Expanded(child: _infoTile(
                                icon: Icons.event_outlined,
                                label: "Expires",
                                value: DateFormat('dd MMM yy').format(coupon.endDate),
                                color: isExpired ? Colors.red : Colors.orange,
                                labelSz: labelSz,
                                valueSz: valueSz,
                              )),
                            ]),

                      SizedBox(height: isTiny ? 8 : 10),

                      // ── Divider ──────────────────────────────────────────
                      Divider(color: lightGrey, height: 1),
                      SizedBox(height: isTiny ? 8 : 10),

                      // ── Row 3: Action buttons ────────────────────────────
                      Row(children: [
                        Expanded(child: _actionBtn(
                          icon: Icons.edit_outlined,
                          label: "Edit",
                          color: primaryIndigo,
                          onTap: () => _showModal(coupon: coupon),
                          small: isTiny,
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _actionBtn(
                          icon: Icons.delete_outline,
                          label: "Delete",
                          color: Colors.red,
                          onTap: () => deleteCoupon(coupon.id!, coupon.code),
                          small: isTiny,
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Info Tile ───────────────────────────────────────────────────────────────
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double labelSz,
    required double valueSz,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: labelSz + 2, color: color),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: labelSz,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: valueSz,
                color: darkGrey,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ─── Action Button ───────────────────────────────────────────────────────────
  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool small,
  }) {
    return _hoverBtn(
      color: color,
      radius: 8,
      padding: EdgeInsets.symmetric(vertical: small ? 7 : 9),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: white, size: small ? 13 : 15),
          SizedBox(width: small ? 3 : 5),
          Text(label,
              style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: small ? 10 : 12)),
        ],
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTiny   = w < 320;
    final isMobile = w < 600;
    final isSmall  = w < 350;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryIndigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_rounded,
                color: white, size: isSmall ? 20 : 24),
            SizedBox(width: isSmall ? 6 : 8),
            Flexible(
              child: Text(
                isSmall ? "Coupons" : "Manage Coupons",
                style: TextStyle(
                    color: white,
                    fontSize: isSmall ? 16 : 20,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Count badge (tablet+)
          if (!isMobile && coupons.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Text(
                  "${coupons.length} ${coupons.length == 1 ? 'Coupon' : 'Coupons'}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: white, size: isSmall ? 22 : 26),
            onPressed: () => _showModal(),
            tooltip: "Create Coupon",
          ),
          SizedBox(width: isSmall ? 2 : 6),
        ],
      ),

      // FAB for mobile
      floatingActionButton: isMobile && coupons.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showModal(),
              backgroundColor: primaryIndigo,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("New Coupon",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: primaryIndigo, strokeWidth: 3))
          : coupons.isEmpty
              ? _buildEmpty(isTiny)
              : RefreshIndicator(
                  onRefresh: fetchCoupons,
                  color: primaryIndigo,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: isMobile ? 10 : 14,
                      bottom: isMobile ? 80 : 20, // space for FAB
                    ),
                    itemCount: coupons.length,
                    itemBuilder: (_, i) => _buildCouponCard(coupons[i], w),
                  ),
                ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmpty(bool isTiny) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryIndigo.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_offer_outlined,
                  size: isTiny ? 48 : 64, color: primaryIndigo.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text("No Coupons Yet",
                style: TextStyle(
                    fontSize: isTiny ? 16 : 20,
                    color: darkGrey,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "Create your first coupon to start\nattracting more customers!",
              style: TextStyle(fontSize: isTiny ? 12 : 14, color: mediumGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _hoverBtn(
              onTap: () => _showModal(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text("Create First Coupon",
                      style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTiny ? 13 : 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}