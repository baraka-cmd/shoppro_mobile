// Interface du repository des notifications
// Définit le contrat que le repository doit respecter

import '../entities/app_notification.dart';

abstract class NotificationRepository {
  /// Récupérer toutes les notifications
  Future<List<AppNotification>> getNotifications();

  /// Récupérer une notification par ID
  Future<AppNotification?> getNotificationById(int notificationId);

  /// Récupérer les notifications non lues
  Future<List<AppNotification>> getUnreadNotifications();

  /// Récupérer les notifications par type
  Future<List<AppNotification>> getNotificationsByType(String type);

  /// Ajouter une notification
  Future<List<AppNotification>> addNotification(AppNotification notification);

  /// Marquer une notification comme lue
  Future<List<AppNotification>> markAsRead(int notificationId);

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead();

  /// Supprimer une notification
  Future<List<AppNotification>> removeNotification(int notificationId);

  /// Supprimer toutes les notifications
  Future<void> clearAllNotifications();

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount();

  /// Récupérer le nombre total
  Future<int> getTotalCount();

  /// Sauvegarder les notifications
  Future<void> saveNotifications(List<AppNotification> notifications);

  /// Synchroniser avec le backend
  Future<List<AppNotification>> syncWithBackend();
}