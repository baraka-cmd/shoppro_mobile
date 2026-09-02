// Source de données locale des notifications
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/app_notification.dart';
import '../models/app_notification_model.dart';

class NotificationLocalDataSource {
  static final NotificationLocalDataSource _instance = NotificationLocalDataSource._internal();
  factory NotificationLocalDataSource() => _instance;
  NotificationLocalDataSource._internal();

  static const String _notificationsKey = 'notifications_data';

  /// Sauvegarder les notifications
  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = jsonEncode(
      notifications.map((n) => n.toJson()).toList(),
    );
    await prefs.setString(_notificationsKey, notificationsJson);
  }

  /// Récupérer les notifications
  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson == null || notificationsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(notificationsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => AppNotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Effacer toutes les notifications
  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }
}