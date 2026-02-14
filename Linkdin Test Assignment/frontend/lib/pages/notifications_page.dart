// lib/pages/notifications_page.dart

import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  final String token;
  final bool isAdmin;

  const NotificationsPage({
    super.key,
    required this.token,
    this.isAdmin = false,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String _filter = 'all'; // 'all', 'unread', 'read'

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await NotificationService.loadNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  List<AppNotification> get _filteredNotifications {
    switch (_filter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'read':
        return _notifications.where((n) => n.isRead).toList();
      default:
        return _notifications;
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    await NotificationService.markAsRead(notification.id);
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead();
    await _loadNotifications();
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    await NotificationService.deleteNotification(notification.id);
    await _loadNotifications();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Notifications"),
        content: const Text("Are you sure you want to delete all notifications?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationService.clearAll();
      await _loadNotifications();
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'out_of_stock':
        return Icons.remove_shopping_cart;
      case 'low_stock':
        return Icons.warning_amber;
      case 'review_reminder':
        return Icons.rate_review;
      case 'order_update':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'out_of_stock':
        return Colors.red;
      case 'low_stock':
        return Colors.orange;
      case 'review_reminder':
        return Colors.blue;
      case 'order_update':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: notification.isRead ? 1 : 3,
        color: notification.isRead ? Colors.grey.shade100 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead ? Colors.grey.shade300 : color.withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification);
            }
            // TODO: Navigate to relevant page based on notification type
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Notifications",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (unreadCount > 0)
              Text(
                "$unreadCount unread",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    _markAllAsRead();
                    break;
                  case 'clear_all':
                    _clearAll();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all, size: 20),
                      SizedBox(width: 12),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Clear all', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.indigo.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', _notifications.length),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 'unread', unreadCount),
                const SizedBox(width: 8),
                _buildFilterChip('Read', 'read', _notifications.length - unreadCount),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _filteredNotifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) => _buildNotificationCard(_filteredNotifications[index]),
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filter == value;
    
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.indigo.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.indigo : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.indigo,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _filter == 'all' 
                ? "No notifications yet" 
                : _filter == 'unread'
                    ? "No unread notifications"
                    : "No read notifications",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isAdmin
                ? "Stock alerts and updates will appear here"
                : "Review reminders and updates will appear here",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}