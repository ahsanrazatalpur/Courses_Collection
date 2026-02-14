// lib/widgets/footer_widget.dart
// ✅ ZERO external dependencies — only Flutter built-in packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  // ── Your Info ────────────────────────────────────────────────────────────
  static const String _github   = 'https://github.com/ahsanrazatalpur';
  static const String _linkedin = 'https://www.linkedin.com/in/ahsan-raza-talpur-43809a361';
  static const String _facebook = 'https://www.facebook.com/share/186FMUQyCo/';
  static const String _phone    = '03113125335';
  static const String _email    = 'ahsanrazatalpur01@gmail.com';
  static const String _dev      = 'Ahsan Raza Talpur';

  // ── Copy to clipboard + snackbar ─────────────────────────────────────────
  Future<void> _copy(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied!',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w         = MediaQuery.of(context).size.width;
    final isMobile  = w < 600;
    final isCompact = w < 380;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
        ),
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Green accent bar ─────────────────────────────────────────────
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF00BCD4), Color(0xFF4CAF50)]),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              isCompact ? 12 : 20,
              isCompact ? 20 : 28,
              isCompact ? 12 : 20,
              isCompact ? 16 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Brand ──────────────────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Icon(Icons.storefront, color: Colors.white, size: isCompact ? 18 : 22),
                  ),
                  const SizedBox(width: 10),
                  Text('E-Commerce Store',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 15 : 18,
                          letterSpacing: 0.5)),
                ]),

                SizedBox(height: isCompact ? 16 : 22),
                const _GlassDivider(),
                SizedBox(height: isCompact ? 16 : 22),

                // ── Contact: phone + email ─────────────────────────────────
                // On mobile → stacked column; on desktop → side by side
                isMobile
                    ? Column(mainAxisSize: MainAxisSize.min, children: [
                        _ContactTile(
                          icon: Icons.phone_rounded,
                          label: _phone,
                          iconColor: const Color(0xFF4CAF50),
                          hint: 'Tap to call • Hold to copy',
                          onTap: () => _copy(context, _phone, 'Phone number'),
                          isCompact: isCompact,
                        ),
                        SizedBox(height: isCompact ? 8 : 12),
                        _ContactTile(
                          icon: Icons.email_rounded,
                          label: _email,
                          iconColor: const Color(0xFF00BCD4),
                          hint: 'Tap to copy email',
                          onTap: () => _copy(context, _email, 'Email'),
                          isCompact: isCompact,
                        ),
                      ])
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _ContactTile(
                          icon: Icons.phone_rounded,
                          label: _phone,
                          iconColor: const Color(0xFF4CAF50),
                          hint: 'Tap to copy',
                          onTap: () => _copy(context, _phone, 'Phone number'),
                          isCompact: false,
                        ),
                        Container(
                            height: 22, width: 1,
                            color: Colors.white.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(horizontal: 20)),
                        _ContactTile(
                          icon: Icons.email_rounded,
                          label: _email,
                          iconColor: const Color(0xFF00BCD4),
                          hint: 'Tap to copy',
                          onTap: () => _copy(context, _email, 'Email'),
                          isCompact: false,
                        ),
                      ]),

                SizedBox(height: isCompact ? 16 : 22),

                // ── Social icons ──────────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _SocialBtn(
                    icon: Icons.code_rounded,
                    label: 'GitHub',
                    hoverColor: const Color(0xFF2d333b),
                    copyText: _github,
                    onTap: () => _copy(context, _github, 'GitHub link'),
                    isCompact: isCompact,
                  ),
                  SizedBox(width: isCompact ? 8 : 12),
                  _SocialBtn(
                    icon: Icons.work_rounded,
                    label: 'LinkedIn',
                    hoverColor: const Color(0xFF0A66C2),
                    copyText: _linkedin,
                    onTap: () => _copy(context, _linkedin, 'LinkedIn link'),
                    isCompact: isCompact,
                  ),
                  SizedBox(width: isCompact ? 8 : 12),
                  _SocialBtn(
                    icon: Icons.facebook_rounded,
                    label: 'Facebook',
                    hoverColor: const Color(0xFF1877F2),
                    copyText: _facebook,
                    onTap: () => _copy(context, _facebook, 'Facebook link'),
                    isCompact: isCompact,
                  ),
                ]),

                // ── Links hint ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Tap any icon to copy the link',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: isCompact ? 9 : 10),
                  ),
                ),

                SizedBox(height: isCompact ? 16 : 20),
                const _GlassDivider(),
                SizedBox(height: isCompact ? 12 : 16),

                // ── Developer credit pill ─────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 18,
                      vertical: isCompact ? 7 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.terminal_rounded,
                        color: const Color(0xFF4CAF50), size: isCompact ? 12 : 14),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'Designed & Developed by  $_dev',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isCompact ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ),

                SizedBox(height: isCompact ? 8 : 12),

                // ── Copyright ─────────────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.copyright_rounded,
                      color: Colors.white.withOpacity(0.35),
                      size: isCompact ? 11 : 13),
                  const SizedBox(width: 4),
                  Text('2026 E-Commerce Store. All rights reserved.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: isCompact ? 9 : 11)),
                ]),

                SizedBox(height: isCompact ? 4 : 6),

                // ── Built with Flutter ────────────────────────────────────
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Built with',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.28),
                          fontSize: isCompact ? 9 : 10)),
                  const SizedBox(width: 4),
                  Icon(Icons.favorite_rounded,
                      color: Colors.red.shade300, size: isCompact ? 9 : 11),
                  const SizedBox(width: 4),
                  Text('using Flutter',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.28),
                          fontSize: isCompact ? 9 : 10)),
                ]),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glass Divider ─────────────────────────────────────────────────────────────
class _GlassDivider extends StatelessWidget {
  const _GlassDivider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent, Colors.white.withOpacity(0.2)]),
          ),
        ),
      ),
      Container(
        width: 6, height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.6), blurRadius: 6)],
        ),
      ),
      Expanded(
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.transparent]),
          ),
        ),
      ),
    ]);
  }
}

// ─── Contact Tile ──────────────────────────────────────────────────────────────
class _ContactTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final String hint;
  final VoidCallback onTap;
  final bool isCompact;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.hint,
    required this.onTap,
    required this.isCompact,
  });

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.hint,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
                horizontal: widget.isCompact ? 10 : 14,
                vertical:   widget.isCompact ? 7  : 9),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.iconColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _hovered
                    ? widget.iconColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.14),
              ),
              boxShadow: _hovered
                  ? [BoxShadow(
                      color: widget.iconColor.withOpacity(0.2),
                      blurRadius: 10, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon,
                  color: _hovered ? widget.iconColor : Colors.white.withOpacity(0.7),
                  size: widget.isCompact ? 13 : 15),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  widget.label,
                  style: TextStyle(
                      color: _hovered ? Colors.white : Colors.white.withOpacity(0.75),
                      fontSize: widget.isCompact ? 10 : 12,
                      fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Social Button ─────────────────────────────────────────────────────────────
class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color hoverColor;
  final String copyText;
  final VoidCallback onTap;
  final bool isCompact;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.hoverColor,
    required this.copyText,
    required this.onTap,
    required this.isCompact,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pad  = widget.isCompact ? 10.0 : 12.0;
    final size = widget.isCompact ? 18.0 : 21.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: '${widget.label} — tap to copy link',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: _hovered ? widget.hoverColor : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: _hovered
                    ? widget.hoverColor
                    : Colors.white.withOpacity(0.18),
                width: 1.5,
              ),
              boxShadow: _hovered
                  ? [BoxShadow(
                      color: widget.hoverColor.withOpacity(0.45),
                      blurRadius: 14, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(widget.icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }
}