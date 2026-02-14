// lib/pages/users_page.dart - PROFESSIONAL FULL-WIDTH RESPONSIVE VERSION

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../helpers/top_popup.dart';
import '../models/user.dart';

class UsersPage extends StatefulWidget {
  final String token;
  final int currentUserId;

  const UsersPage({
    super.key,
    required this.token,
    required this.currentUserId,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.fetchUsers(token: widget.token);
      if (!mounted) return;
      setState(() {
        users = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      TopPopup.show(context, "Failed to load users", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // ================= DELETE USER =================
  Future<void> deleteUser(int userId, String username) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Confirm Delete",
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete user '$username'?\n\nThis action cannot be undone.",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade50,
            ),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      ),
    );

    try {
      final success = await ApiService.deleteUser(userId, token: widget.token);

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        setState(() => users.removeWhere((u) => u.id == userId));
        TopPopup.show(context, "User '$username' deleted successfully", Colors.red);
      } else {
        TopPopup.show(context, "Failed to delete user", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      TopPopup.show(context, "Error: $e", Colors.red);
    }
  }

  // ================= BLOCK / UNBLOCK =================
  Future<void> toggleBlock(User user) async {
    final actionWord = user.isActive ? "block" : "unblock";
    
    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      ),
    );

    try {
      final success = await ApiService.updateUser(
        userId: user.id!,
        token: widget.token,
        data: {"is_blocked": !user.isActive},
      );

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        setState(() {
          final index = users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            users[index] = user.copyWith(isActive: !user.isActive);
          }
        });
        TopPopup.show(
          context,
          "User ${user.username} ${actionWord}ed successfully",
          user.isActive ? Colors.orange : Colors.green,
        );
      } else {
        TopPopup.show(context, "Failed to $actionWord user", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      TopPopup.show(context, "Error: $e", Colors.red);
    }
  }

  // ================= CHANGE ROLE =================
  Future<void> changeRole(User user) async {
    final newRole = user.role == "admin" ? "user" : "admin";
    
    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.indigo),
      ),
    );

    try {
      final success = await ApiService.updateUser(
        userId: user.id!,
        token: widget.token,
        data: {"role": newRole},
      );

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        setState(() {
          final index = users.indexWhere((u) => u.id == user.id);
          if (index != -1) {
            users[index] = user.copyWith(role: newRole);
          }
        });
        TopPopup.show(
          context,
          "Role updated to $newRole for ${user.username}",
          Colors.green,
        );
      } else {
        TopPopup.show(context, "Role update failed", Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      TopPopup.show(context, "Error: $e", Colors.red);
    }
  }

  // ================= BUILD USER CARD - FULL WIDTH =================
  Widget buildUserCard(User user, double width) {
    final bool isCurrentUser = user.id == widget.currentUserId;
    final bool isBlocked = !user.isActive;
    
    // Responsive breakpoints
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 900;
    final bool isDesktop = width >= 900;

    // Responsive sizing
    final avatarRadius = isMobile ? 30.0 : (isTablet ? 35.0 : 40.0);
    final avatarFontSize = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);
    final nameFontSize = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final emailFontSize = isMobile ? 12.0 : (isTablet ? 13.0 : 14.0);
    final badgeFontSize = isMobile ? 9.0 : (isTablet ? 10.0 : 11.0);
    final buttonFontSize = isMobile ? 12.0 : (isTablet ? 13.0 : 14.0);

    return Card(
      color: isBlocked ? Colors.orange.shade50 : Colors.white,
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6,
        horizontal: isMobile ? 8 : (isTablet ? 12 : 16),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBlocked ? Colors.orange : Colors.indigo.shade100,
          width: isBlocked ? 2 : 1,
        ),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 16 : 20)),
        child: isMobile
            ? _buildMobileLayout(user, isCurrentUser, isBlocked, avatarRadius, avatarFontSize, nameFontSize, emailFontSize, badgeFontSize, buttonFontSize)
            : _buildDesktopLayout(user, isCurrentUser, isBlocked, avatarRadius, avatarFontSize, nameFontSize, emailFontSize, badgeFontSize, buttonFontSize, isTablet),
      ),
    );
  }

  // ================= MOBILE LAYOUT (Vertical) =================
  Widget _buildMobileLayout(
    User user,
    bool isCurrentUser,
    bool isBlocked,
    double avatarRadius,
    double avatarFontSize,
    double nameFontSize,
    double emailFontSize,
    double badgeFontSize,
    double buttonFontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info Row
        Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: user.role == 'admin'
                  ? Colors.indigo
                  : user.isActive
                      ? Colors.green
                      : Colors.orange,
              child: Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: avatarFontSize,
                  fontWeight: FontWeight.bold,
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
                      Expanded(
                        child: Text(
                          user.username,
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: nameFontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "YOU",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: emailFontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Badges
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildBadge(
              user.role.toUpperCase(),
              user.role == 'admin' ? Colors.indigo : Colors.grey.shade600,
              badgeFontSize,
            ),
            _buildBadge(
              user.isActive ? "ACTIVE" : "BLOCKED",
              user.isActive ? Colors.green : Colors.orange,
              badgeFontSize,
            ),
          ],
        ),

        // Action Buttons (only if not current user)
        if (!isCurrentUser) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.indigo.shade100),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActionButton(
                icon: user.isActive ? Icons.block : Icons.check_circle,
                label: user.isActive ? "Block User" : "Unblock User",
                color: user.isActive ? Colors.orange : Colors.green,
                onPressed: () => toggleBlock(user),
                fontSize: buttonFontSize,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.admin_panel_settings,
                label: user.role == 'admin' ? "Change to User" : "Change to Admin",
                color: Colors.indigo,
                onPressed: () => changeRole(user),
                fontSize: buttonFontSize,
              ),
              const SizedBox(height: 8),
              _buildDeleteButton(user, buttonFontSize),
            ],
          ),
        ],
      ],
    );
  }

  // ================= DESKTOP LAYOUT (Horizontal) =================
  Widget _buildDesktopLayout(
    User user,
    bool isCurrentUser,
    bool isBlocked,
    double avatarRadius,
    double avatarFontSize,
    double nameFontSize,
    double emailFontSize,
    double badgeFontSize,
    double buttonFontSize,
    bool isTablet,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: user.role == 'admin'
              ? Colors.indigo
              : user.isActive
                  ? Colors.green
                  : Colors.orange,
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: avatarFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // User Info (25% of space)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.username,
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: nameFontSize,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 6 : 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "YOU",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: badgeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: emailFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Badges (15% of space)
        Expanded(
          flex: 2,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(
                user.role.toUpperCase(),
                user.role == 'admin' ? Colors.indigo : Colors.grey.shade600,
                badgeFontSize,
              ),
              _buildBadge(
                user.isActive ? "ACTIVE" : "BLOCKED",
                user.isActive ? Colors.green : Colors.orange,
                badgeFontSize,
              ),
            ],
          ),
        ),
        
        // Action Buttons (35% of space) - only if not current user
        if (!isCurrentUser) ...[
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: _buildActionButton(
                    icon: user.isActive ? Icons.block : Icons.check_circle,
                    label: user.isActive ? "Block" : "Unblock",
                    color: user.isActive ? Colors.orange : Colors.green,
                    onPressed: () => toggleBlock(user),
                    fontSize: buttonFontSize,
                    isCompact: isTablet,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildActionButton(
                    icon: Icons.admin_panel_settings,
                    label: user.role == 'admin' ? "→ User" : "→ Admin",
                    color: Colors.indigo,
                    onPressed: () => changeRole(user),
                    fontSize: buttonFontSize,
                    isCompact: isTablet,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildDeleteButton(user, buttonFontSize, isCompact: isTablet),
                ),
              ],
            ),
          ),
        ] else ...[
          // Empty space for current user to maintain alignment
          Expanded(flex: 4, child: SizedBox()),
        ],
      ],
    );
  }

  // ================= HELPER: BUILD BADGE =================
  Widget _buildBadge(String label, Color color, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize > 10 ? 10 : 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= HELPER: BUILD ACTION BUTTON =================
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required double fontSize,
    bool isCompact = false,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: isCompact ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: fontSize + 4),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ================= HELPER: BUILD DELETE BUTTON =================
  Widget _buildDeleteButton(User user, double fontSize, {bool isCompact = false}) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red, width: 2),
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: isCompact ? 8 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => deleteUser(user.id!, user.username),
      icon: Icon(Icons.delete, size: fontSize + 4),
      label: Text(
        "Delete",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              "User Management",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchUsers,
            tooltip: 'Refresh',
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    "${users.length} ${users.length == 1 ? 'User' : 'Users'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            )
          : users.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: isMobile ? 80 : 100,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        Text(
                          "No users found",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: fetchUsers,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 24 : 32,
                              vertical: isMobile ? 12 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchUsers,
                  color: Colors.indigo,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 6 : 8,
                    ),
                    itemCount: users.length,
                    itemBuilder: (_, index) => buildUserCard(users[index], width),
                  ),
                ),
    );
  }
}

// ================= USER COPY EXTENSION =================
extension UserCopy on User {
  User copyWith({String? role, bool? isActive}) {
    return User(
      id: id,
      username: username,
      email: email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}