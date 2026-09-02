// Implémentation du repository des notifications
// Gère la logique métier avec stockage local

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/app_notification_model.dart';
import '../sources/notification_local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl({NotificationLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? NotificationLocalDataSource();

  @override
  Future<List<AppNotification>> getNotifications() async {
    final notifications = await _localDataSource.getNotifications();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
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
    return notifications.where((n) => !n.isRead).toList();
  }

  @override
  Future<List<AppNotification>> getNotificationsByType(String type) async {
    final notifications = await getNotifications();
    return notifications.where((n) => n.type == type).toList();
  }

  @override
  Future<List<AppNotification>> addNotification(AppNotification notification) async {
    final notifications = await getNotifications();
    notifications.add(notification);
    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  @override
  Future<List<AppNotification>> markAsRead(int notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      await _localDataSource.saveNotifications(notifications);
    }

    return notifications;
  }

  @override
  Future<void> markAllAsRead() async {
    final notifications = await getNotifications();

    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }

    await _localDataSource.saveNotifications(notifications);
  }

  @override
  Future<List<AppNotification>> removeNotification(int notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _localDataSource.saveNotifications(notifications);
    return notifications;
  }

  @override
  Future<void> clearAllNotifications() async {
    await _localDataSource.clearNotifications();
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

  @override
  Future<void> saveNotifications(List<AppNotification> notifications) async {
    await _localDataSource.saveNotifications(notifications);
  }

  @override
  Future<List<AppNotification>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getNotifications();
  }
}