// ============================================
// REPOSITORY INTERFACE : AdminNotificationRepository
// ============================================
// Interface définissant le contrat pour la gestion des notifications
// système depuis le backoffice administrateur.
//
// Cette interface est dans la couche DOMAIN (métier) et ne dépend
// d'aucune implémentation concrète. Elle sera implémentée dans
// la couche DATA par AdminNotificationRepositoryImpl.
//
// Opérations couvertes :
// - Liste paginée des notifications
// - Filtrage par type et priorité
// - Marquage lu/non lu
// - Archivage
// - Suppression
// - Statistiques des notifications
// ============================================

// ============================================
// IMPORTS
// ============================================

// Entities (même feature admin)
import '../entities/admin_notification.dart';

// ============================================
// INTERFACE PRINCIPALE
// ============================================

/// Contrat pour le repository de gestion des notifications.
///
/// Cette interface définit toutes les opérations de gestion
/// des notifications système pour l'administration.
abstract class AdminNotificationRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des notifications.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page (commence à 1)
  /// - [perPage] : Nombre d'éléments par page (défaut : 20)
  /// - [type] : Filtrer par type de notification
  /// - [priority] : Filtrer par priorité
  /// - [isRead] : Filtrer par statut de lecture
  /// - [isArchived] : Filtrer par statut d'archivage
  /// - [sortBy] : Champ de tri (created_at, priority)
  /// - [sortDirection] : Direction du tri (asc, desc)
  ///
  /// Retourne une liste de [AdminNotification].
  Future<List<AdminNotification>> getNotifications({
    int page = 1,
    int perPage = 20,
    AdminNotificationType? type,
    AdminNotificationPriority? priority,
    bool? isRead,
    bool? isArchived,
    String? sortBy,
    String? sortDirection,
  });

  /// Recherche des notifications par titre ou corps.
  ///
  /// Paramètres :
  /// - [query] : Texte de recherche
  /// - [limit] : Nombre maximum de résultats (défaut : 20)
  Future<List<AdminNotification>> searchNotifications(String query, {int limit = 20});

  /// Récupère les notifications non lues.
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  Future<List<AdminNotification>> getUnreadNotifications({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les notifications lues.
  Future<List<AdminNotification>> getReadNotifications({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les notifications archivées.
  Future<List<AdminNotification>> getArchivedNotifications({
    int page = 1,
    int perPage = 20,
  });

  /// Récupère les notifications urgentes.
  Future<List<AdminNotification>> getUrgentNotifications();

  /// Récupère les notifications de haute priorité.
  Future<List<AdminNotification>> getHighPriorityNotifications();

  /// Récupère les notifications par type.
  ///
  /// Paramètres :
  /// - [type] : Type de notification
  Future<List<AdminNotification>> getNotificationsByType(AdminNotificationType type);

  /// Récupère les notifications récentes.
  ///
  /// Paramètres :
  /// - [limit] : Nombre maximum (défaut : 20)
  Future<List<AdminNotification>> getRecentNotifications({int limit = 20});

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'une notification par son ID.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la notification
  ///
  /// Retourne un [AdminNotification] ou null si introuvable.
  Future<AdminNotification?> getNotificationById(int id);

  // ============================================
  // MARQUAGE
  // ============================================

  /// Marque une notification comme lue.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la notification
  Future<bool> markAsRead(int id);

  /// Marque une notification comme non lue.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la notification
  Future<bool> markAsUnread(int id);

  /// Marque toutes les notifications comme lues.
  Future<bool> markAllAsRead();

  /// Marque toutes les notifications comme non lues.
  Future<bool> markAllAsUnread();

  /// Marque plusieurs notifications comme lues.
  ///
  /// Paramètres :
  /// - [notificationIds] : Liste des identifiants
  ///
  /// Retourne le nombre de notifications marquées.
  Future<int> bulkMarkAsRead(List<int> notificationIds);

  // ============================================
  // ARCHIVAGE
  // ============================================

  /// Archive une notification.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la notification
  Future<bool> archiveNotification(int id);

  /// Désarchive une notification.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la notification
  Future<bool> unarchiveNotification(int id);

  /// Archive toutes les notifications lues.
  Future<int> archiveAllReadNotifications();

  /// Archive plusieurs notifications en même temps.
  ///
  /// Paramètres :
  /// - [notificationIds] : Liste des identifiants
  ///
  /// Retourne le nombre de notifications archivées.
  Future<int> bulkArchiveNotifications(List<int> notificationIds);

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime une notification.
  ///
  /// Paramètres :
  /// - [id] : Identifiant de la notification
  Future<bool> deleteNotification(int id);

  /// Supprime toutes les notifications lues.
  Future<int> deleteAllReadNotifications();

  /// Supprime toutes les notifications archivées.
  Future<int> deleteAllArchivedNotifications();

  /// Supprime toutes les notifications.
  Future<bool> clearAllNotifications();

  /// Supprime plusieurs notifications en même temps.
  ///
  /// Paramètres :
  /// - [notificationIds] : Liste des identifiants
  ///
  /// Retourne le nombre de notifications supprimées.
  Future<int> bulkDeleteNotifications(List<int> notificationIds);

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de notifications.
  Future<int> getTotalNotificationsCount();

  /// Récupère le nombre de notifications non lues.
  Future<int> getUnreadCount();

  /// Récupère le nombre de notifications lues.
  Future<int> getReadCount();

  /// Récupère le nombre de notifications archivées.
  Future<int> getArchivedCount();

  /// Récupère le nombre de notifications par type.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'new_order': 15,
  ///   'low_stock': 5,
  ///   'new_review': 8,
  ///   ...
  /// }
  /// ```
  Future<Map<String, int>> getNotificationsCountByType();

  /// Récupère le nombre de notifications par priorité.
  ///
  /// Retourne une map :
  /// ```dart
  /// {
  ///   'low': 10,
  ///   'medium': 15,
  ///   'high': 5,
  ///   'urgent': 3,
  /// }
  /// ```
  Future<Map<String, int>> getNotificationsCountByPriority();

  /// Récupère le nombre de notifications par jour.
  ///
  /// Paramètres :
  /// - [days] : Nombre de jours (défaut : 30)
  ///
  /// Retourne une liste de maps :
  /// ```dart
  /// [
  ///   {'date': '2026-08-01', 'count': 5},
  ///   ...
  /// ]
  /// ```
  Future<List<Map<String, dynamic>>> getNotificationsByDay({int days = 30});

  // ============================================
  // PAGINATION
  // ============================================

  /// Vérifie s'il y a plus de pages à charger.
  ///
  /// Paramètres :
  /// - [page] : Page actuelle
  /// - [perPage] : Nombre d'éléments par page
  Future<bool> hasMoreNotifications({required int page, int perPage = 20});

  /// Récupère le nombre total de pages.
  ///
  /// Paramètres :
  /// - [perPage] : Nombre d'éléments par page
  Future<int> getTotalPages({int perPage = 20});
}