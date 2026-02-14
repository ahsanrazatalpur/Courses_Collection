// lib/services/notification_service.dart - COMPLETE FIXED VERSION

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../models/product.dart';

class NotificationService {
  static const String _notificationsKey = 'app_notifications';

  // ==================== SAVE NOTIFICATIONS ====================
  static Future<void> saveNotifications(List<AppNotification> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      print("Error saving notifications: $e");
    }
  }

  // ==================== LOAD NOTIFICATIONS ====================
  static Future<List<AppNotification>> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      print("Error loading notifications: $e");
      return [];
    }
  }

  // ==================== ADD NOTIFICATION ====================
  static Future<void> addNotification(AppNotification notification) async {
    final notifications = await loadNotifications();
    
    // Check if notification already exists (prevent duplicates)
    final exists = notifications.any((n) => 
      n.type == notification.type && 
      n.data?['product_id'] == notification.data?['product_id']
    );
    
    if (!exists) {
      notifications.insert(0, notification); // Add to beginning
      await saveNotifications(notifications);
    }
  }

  // ==================== MARK AS READ ====================
  static Future<void> markAsRead(String notificationId) async {
    final notifications = await loadNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await saveNotifications(notifications);
    }
  }

  // ==================== MARK ALL AS READ ====================
  static Future<void> markAllAsRead() async {
    final notifications = await loadNotifications();
    final updated = notifications.map((n) => n.copyWith(isRead: true)).toList();
    await saveNotifications(updated);
  }

  // ==================== DELETE NOTIFICATION ====================
  static Future<void> deleteNotification(String notificationId) async {
    final notifications = await loadNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await saveNotifications(notifications);
  }

  // ==================== CLEAR ALL ====================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  // ==================== GET UNREAD COUNT ====================
  static Future<int> getUnreadCount() async {
    final notifications = await loadNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // ==================== CHECK STOCK ALERTS (ADMIN) ====================
  static Future<void> checkStockAlerts(List<Product> products) async {
    final notifications = await loadNotifications();
    
    for (var product in products) {
      // Out of stock alert
      if (product.stock == 0) {
        final exists = notifications.any((n) => 
          n.type == 'out_of_stock' && 
          n.data?['product_id'] == product.id
        );
        
        if (!exists) {
          await addNotification(AppNotification(
            id: 'out_of_stock_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
            type: 'out_of_stock',
            title: '❌ Out of Stock Alert',
            message: '${product.name} is now out of stock!',
            createdAt: DateTime.now(),
            data: {'product_id': product.id, 'product_name': product.name},
          ));
        }
      }
      // Low stock alert
      else if (product.stock > 0 && product.stock <= 5) {
        final exists = notifications.any((n) => 
          n.type == 'low_stock' && 
          n.data?['product_id'] == product.id
        );
        
        if (!exists) {
          await addNotification(AppNotification(
            id: 'low_stock_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
            type: 'low_stock',
            title: '⚠️ Low Stock Warning',
            message: '${product.name} only has ${product.stock} items left!',
            createdAt: DateTime.now(),
            data: {'product_id': product.id, 'product_name': product.name, 'stock': product.stock},
          ));
        }
      }
      // Remove stock alerts if stock is restored
      else if (product.stock > 5) {
        final toRemove = notifications.where((n) => 
          (n.type == 'low_stock' || n.type == 'out_of_stock') && 
          n.data?['product_id'] == product.id
        ).toList();
        
        for (var notification in toRemove) {
          await deleteNotification(notification.id);
        }
      }
    }
  }

  // ==================== CHECK REVIEW REMINDERS (USER) ====================
  static Future<void> checkReviewReminders(List<int> pendingProductIds, Map<int, String> productNames) async {
    final notifications = await loadNotifications();
    
    // Add notifications for pending reviews
    for (var productId in pendingProductIds) {
      final exists = notifications.any((n) => 
        n.type == 'review_reminder' && 
        n.data?['product_id'] == productId
      );
      
      if (!exists) {
        await addNotification(AppNotification(
          id: 'review_reminder_${productId}_${DateTime.now().millisecondsSinceEpoch}',
          type: 'review_reminder',
          title: '⭐ Review Reminder',
          message: 'How was ${productNames[productId] ?? 'your product'}? Share your experience!',
          createdAt: DateTime.now(),
          data: {'product_id': productId, 'product_name': productNames[productId]},
        ));
      }
    }
    
    // Remove review reminders that are no longer pending
    final currentNotifications = await loadNotifications();
    final reviewReminders = currentNotifications.where((n) => n.type == 'review_reminder').toList();
    
    for (var notification in reviewReminders) {
      final productId = notification.data?['product_id'];
      if (productId != null && !pendingProductIds.contains(productId)) {
        await deleteNotification(notification.id);
      }
    }
  }
}