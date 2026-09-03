// ============================================
// IMPLÉMENTATION DU REPOSITORY DES NOTIFICATIONS - PREMIUM
// ============================================
// Gère la logique métier avec stockage local,
// upsert, archivage et synchronisation.
// ============================================

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/app_notification_model.dart';
import '../sources/notification_local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl({NotificationLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? NotificationLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<AppNotification>> getNotifications() async {
    final notifications = await _localDataSource.getNotifications();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  @override
  Future<List<AppNotification>> getActiveNotifications() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isArchived).toList();
  }

  @override
  Future<List<AppNotification>> getArchivedNotifications() async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.isArchived).toList();
  }

  @override
  Future<AppNotification?> getNotificationById(int notificationId) async {
    final notifications = await getNotifications();
    for (final notification in notifications) {
      if (notification.id == notificationId) {
        return notification;
      }
    }
    return null;
  }

  @override
  Future<List<AppNotification>> getUnreadNotifications() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead && !n.isArchived).toList();
  }

  @override
  Future<List<AppNotification>> getNotificationsByType(String type) async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.type == type).toList();
  }

  @override
  Future<List<AppNotification>> getRecentNotifications({int limit = 10}) async {
    final notifications = await getNotifications();
    return notifications.take(limit).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    return await _localDataSource.getUnreadCount();
  }

  @override
  Future<int> getTotalCount() async {
    final notifications = await getNotifications();
    return notifications.length;
  }

  // ============================================
  // CRÉATION (UPSERT)
  // ============================================

  @override
  Future<List<AppNotification>> addNotification(
      AppNotification notification) async {
    return await upsertNotification(notification);
  }

  @override
  Future<List<AppNotification>> addNotifications(
      List<AppNotification> newNotifications) async {
    var notifications = await getNotifications();

    for (final notification in newNotifications) {
      final index =
          notifications.indexWhere((n) => n.id == notification.id);
      if (index >= 0) {
        notifications[index] = notification;
      } else {
        notifications.add(notification);
      }
    }

    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  @override
  Future<List<AppNotification>> upsertNotification(
      AppNotification notification) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notification.id);

    if (index >= 0) {
      notifications[index] = notification;
    } else {
      notifications.add(notification);
    }

    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  // ============================================
  // MARQUAGE
  // ============================================

  @override
  Future<List<AppNotification>> markAsRead(int notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index >= 0) {
      notifications[index] = notifications[index].markAsRead();
      await _localDataSource.saveNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<List<AppNotification>> markAsUnread(int notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index >= 0) {
      notifications[index] = notifications[index].markAsUnread();
      await _localDataSource.saveNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<void> markAllAsRead() async {
    final notifications = await getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].markAsRead();
      }
    }

    await _localDataSource.saveNotifications(notifications);
  }

  @override
  Future<List<AppNotification>> markMultipleAsRead(
      List<int> notificationIds) async {
    final notifications = await getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      if (notificationIds.contains(notifications[i].id)) {
        notifications[i] = notifications[i].markAsRead();
      }
    }

    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  // ============================================
  // ARCHIVAGE
  // ============================================

  @override
  Future<List<AppNotification>> archiveNotification(int notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index >= 0) {
      notifications[index] = notifications[index].archive();
      await _localDataSource.saveNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<List<AppNotification>> unarchiveNotification(
      int notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index >= 0) {
      notifications[index] = notifications[index].unarchive();
      await _localDataSource.saveNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<void> archiveAllRead() async {
    final notifications = await getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      if (notifications[i].isRead && !notifications[i].isArchived) {
        notifications[i] = notifications[i].archive();
      }
    }

    await _localDataSource.saveNotifications(notifications);
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  @override
  Future<List<AppNotification>> removeNotification(int notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  @override
  Future<List<AppNotification>> removeNotifications(
      List<int> notificationIds) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => notificationIds.contains(n.id));
    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  @override
  Future<void> clearAllNotifications() async {
    await _localDataSource.clearNotifications();
  }

  // ============================================
  // SAUVEGARDE
  // ============================================

  @override
  Future<void> saveNotifications(List<AppNotification> notifications) async {
    await _localDataSource.saveNotifications(notifications);
  }

  @override
  Future<List<AppNotification>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel (upsert)
    return await getNotifications();
  }

  @override
  Future<bool> isNotificationsSynced() async {
    return true;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  @override
  Future<void> saveNotificationsSnapshot() async {
    await _localDataSource.saveNotificationsSnapshot();
  }

  @override
  Future<List<AppNotification>> restoreNotificationsSnapshot() async {
    return await _localDataSource.restoreNotificationsSnapshot() ?? [];
  }

  @override
  Future<void> clearNotificationsSnapshot() async {
    await _localDataSource.clearNotificationsSnapshot();
  }
}