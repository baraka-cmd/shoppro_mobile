// ============================================
// INTERFACE DU REPOSITORY DES NOTIFICATIONS - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des notifications,
// upsert, archivage et synchronisation.
// ============================================

import '../entities/app_notification.dart';

abstract class NotificationRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer toutes les notifications
  Future<List<AppNotification>> getNotifications();

  /// Récupérer les notifications non archivées
  Future<List<AppNotification>> getActiveNotifications();

  /// Récupérer les notifications archivées
  Future<List<AppNotification>> getArchivedNotifications();

  /// Récupérer une notification par ID
  Future<AppNotification?> getNotificationById(int notificationId);

  /// Récupérer les notifications non lues
  Future<List<AppNotification>> getUnreadNotifications();

  /// Récupérer les notifications par type
  Future<List<AppNotification>> getNotificationsByType(String type);

  /// Récupérer les notifications récentes
  Future<List<AppNotification>> getRecentNotifications({int limit = 10});

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount();

  /// Récupérer le nombre total
  Future<int> getTotalCount();

  // ============================================
  // CRÉATION (Upsert)
  // ============================================

  /// Ajouter une notification (ou mettre à jour si existe)
  Future<List<AppNotification>> addNotification(AppNotification notification);

  /// Ajouter plusieurs notifications (upsert)
  Future<List<AppNotification>> addNotifications(
      List<AppNotification> notifications);

  /// Upsert une notification (update si existe, insert sinon)
  Future<List<AppNotification>> upsertNotification(
      AppNotification notification);

  // ============================================
  // MARQUAGE
  // ============================================

  /// Marquer une notification comme lue
  Future<List<AppNotification>> markAsRead(int notificationId);

  /// Marquer une notification comme non lue
  Future<List<AppNotification>> markAsUnread(int notificationId);

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead();

  /// Marquer plusieurs notifications comme lues
  Future<List<AppNotification>> markMultipleAsRead(
      List<int> notificationIds);

  // ============================================
  // ARCHIVAGE
  // ============================================

  /// Archiver une notification
  Future<List<AppNotification>> archiveNotification(int notificationId);

  /// Désarchiver une notification
  Future<List<AppNotification>> unarchiveNotification(int notificationId);

  /// Archiver toutes les notifications lues
  Future<void> archiveAllRead();

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une notification
  Future<List<AppNotification>> removeNotification(int notificationId);

  /// Supprimer plusieurs notifications
  Future<List<AppNotification>> removeNotifications(
      List<int> notificationIds);

  /// Supprimer toutes les notifications
  Future<void> clearAllNotifications();

  // ============================================
  // SAUVEGARDE
  // ============================================

  /// Sauvegarder les notifications localement
  Future<void> saveNotifications(List<AppNotification> notifications);

  /// Synchroniser avec le backend (upsert)
  Future<List<AppNotification>> syncWithBackend();

  /// Vérifier si les notifications sont synchronisées
  Future<bool> isNotificationsSynced();

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Sauvegarder le snapshot des notifications
  Future<void> saveNotificationsSnapshot();

  /// Restaurer le snapshot des notifications
  Future<List<AppNotification>> restoreNotificationsSnapshot();

  /// Effacer le snapshot
  Future<void> clearNotificationsSnapshot();
}