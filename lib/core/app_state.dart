import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import 'models/app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  final List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadNotificationsCount {
    final count = _notifications.where((n) => !n.isRead).length;
    debugPrint('🔔 Unread notifications count: $count');
    return count;
  }

  AppState() {
    _loadNotifications();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // ==== Cart Operations ====
  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get cartSubtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.price);
  int get cartCount => _cartItems.length;

  // ==== Auth Operations Wrapper ====
  Future<void> signOut() async {
    await _auth.signOut();
    _cartItems.clear();
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // ==== Notifications Operations ====
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsData = prefs.getString('saved_notifications');
    if (notificationsData != null) {
      final List<dynamic> decodedList = json.decode(notificationsData);
      _notifications.clear();
      _notifications.addAll(
        decodedList.map((item) => AppNotification.fromMap(item)).toList(),
      );
      // Sort newest first
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(
      _notifications.map((n) => n.toMap()).toList(),
    );
    await prefs.setString('saved_notifications', encodedList);
  }

  Future<void> addNotification({
    required String title,
    required String body,
  }) async {
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
    );
    // Insert at top
    _notifications.insert(0, newNotification);
    notifyListeners();
    await _saveNotifications();
  }

  Future<void> markAllNotificationsAsRead() async {
    bool changed = false;
    for (var n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      debugPrint('📢 Marked ${_notifications.length} notifications as read. Unread count: $unreadNotificationsCount');
      notifyListeners();
      await _saveNotifications();
    }
  }
}
