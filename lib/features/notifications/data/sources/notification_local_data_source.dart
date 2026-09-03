// ============================================
// SOURCE DE DONNÉES LOCALE DES NOTIFICATIONS - PREMIUM
// ============================================
// Gère la sauvegarde et la récupération dans
// SharedPreferences avec snapshot et gestion d'erreurs.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/app_notification.dart';
import '../models/app_notification_model.dart';

class NotificationLocalDataSource {
  static final NotificationLocalDataSource _instance = NotificationLocalDataSource._internal();
  factory NotificationLocalDataSource() => _instance;
  NotificationLocalDataSource._internal();

  static const String _notificationsKey = 'notifications_data';
  static const String _notificationsSnapshotKey = 'notifications_snapshot_data';

  // ============================================
  // NOTIFICATIONS PRINCIPALES
  // ============================================

  /// Sauvegarder les notifications
  Future<void> saveNotifications(List<AppNotification> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('❌ Erreur saveNotifications: $e');
    }
  }

  /// Récupérer les notifications
  Future<List<AppNotification>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null || notificationsJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(notificationsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => AppNotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getNotifications: $e');
      return [];
    }
  }

  /// Effacer toutes les notifications
  Future<void> clearNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
    } catch (e) {
      debugPrint('❌ Erreur clearNotifications: $e');
    }
  }

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead && !n.isArchived).length;
  }

  // ============================================
  // SNAPSHOT (ANNULATION)
  // ============================================

  /// Sauvegarder le snapshot des notifications
  Future<void> saveNotificationsSnapshot() async {
    try {
      final notifications = await getNotifications();
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_notificationsSnapshotKey, snapshotJson);
    } catch (e) {
      debugPrint('❌ Erreur saveNotificationsSnapshot: $e');
    }
  }

  /// Restaurer le snapshot des notifications
  Future<List<AppNotification>?> restoreNotificationsSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = prefs.getString(_notificationsSnapshotKey);

      if (snapshotJson == null || snapshotJson.isEmpty) {
        return null;
      }

      final List<dynamic> data = jsonDecode(snapshotJson);
      final notifications = data
          .whereType<Map<String, dynamic>>()
          .map((json) => AppNotificationModel.fromJson(json))
          .toList();

      await saveNotifications(notifications);
      await clearNotificationsSnapshot();
      return notifications;
    } catch (e) {
      debugPrint('❌ Erreur restoreNotificationsSnapshot: $e');
      return null;
    }
  }

  /// Effacer le snapshot
  Future<void> clearNotificationsSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsSnapshotKey);
    } catch (e) {
      debugPrint('❌ Erreur clearNotificationsSnapshot: $e');
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Effacer toutes les données des notifications
  Future<void> clearAll() async {
    await clearNotifications();
    await clearNotificationsSnapshot();
  }

  /// Vérifier si un snapshot existe
  Future<bool> hasSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_notificationsSnapshotKey);
    } catch (e) {
      return false;
    }
  }
}