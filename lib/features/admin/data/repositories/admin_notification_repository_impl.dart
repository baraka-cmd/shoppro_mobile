// ============================================
// REPOSITORY IMPL : AdminNotificationRepositoryImpl
// ============================================
// Implémentation concrète du repository de gestion des notifications.
// Cette classe implémente l'interface [AdminNotificationRepository]
// et orchestre les appels API pour les notifications système.
//
// Responsabilités :
// - Appels API via AdminNotificationApi
// - Transformation des données
// - Marquage lu/non lu
// - Archivage et suppression
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_notification.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_notification_repository.dart';

// Models (même feature admin)
import '../models/admin_notification_model.dart';

// Sources (même feature admin)
import '../sources/admin_notification_api.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository de gestion des notifications.
///
/// Gère toutes les opérations de gestion des notifications système.
class AdminNotificationRepositoryImpl implements AdminNotificationRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminNotificationApi _api;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminNotificationRepositoryImpl({AdminNotificationApi? api})
      : _api = api ?? AdminNotificationApi();

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  @override
  Future<List<AdminNotification>> getNotifications({
    int page = 1,
    int perPage = 20,
    AdminNotificationType? type,
    AdminNotificationPriority? priority,
    bool? isRead,
    bool? isArchived,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _api.getNotifications(
        page: page,
        perPage: perPage,
        type: type?.code,
        priority: priority?.code,
        isRead: isRead,
        isArchived: isArchived,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> searchNotifications(String query, {int limit = 20}) async {
    try {
      final response = await _api.searchNotifications(query, limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur searchNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getUnreadNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getUnreadNotifications(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getUnreadNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getReadNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getReadNotifications(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getReadNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getArchivedNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getArchivedNotifications(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getArchivedNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getUrgentNotifications() async {
    try {
      final response = await _api.getUrgentNotifications();
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getUrgentNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getHighPriorityNotifications() async {
    try {
      final response = await _api.getHighPriorityNotifications();
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getHighPriorityNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getNotificationsByType(AdminNotificationType type) async {
    try {
      final response = await _api.getNotificationsByType(type.code);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getNotificationsByType: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminNotification>> getRecentNotifications({int limit = 20}) async {
    try {
      final response = await _api.getRecentNotifications(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminNotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRecentNotifications: $e');
      rethrow;
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  @override
  Future<AdminNotification?> getNotificationById(int id) async {
    try {
      final response = await _api.getNotificationById(id);
      final data = response['data'];
      if (data is Map) {
        return AdminNotificationModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getNotificationById: $e');
      rethrow;
    }
  }

  // ============================================
  // MARQUAGE
  // ============================================

  @override
  Future<bool> markAsRead(int id) async {
    try {
      final response = await _api.markAsRead(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markAsUnread(int id) async {
    try {
      final response = await _api.markAsUnread(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markAsUnread: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      final response = await _api.markAllAsRead();
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markAllAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markAllAsUnread() async {
    try {
      // Récupérer toutes les notifications lues et les marquer non lues
      final readNotifications = await getReadNotifications(perPage: 100);
      var success = true;
      for (final notification in readNotifications) {
        if (!await markAsUnread(notification.id)) {
          success = false;
        }
      }
      return success;
    } catch (e) {
      debugPrint('Erreur markAllAsUnread: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkMarkAsRead(List<int> notificationIds) async {
    try {
      final response = await _api.bulkMarkAsRead(notificationIds);
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur bulkMarkAsRead: $e');
      rethrow;
    }
  }

  // ============================================
  // ARCHIVAGE
  // ============================================

  @override
  Future<bool> archiveNotification(int id) async {
    try {
      final response = await _api.archiveNotification(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur archiveNotification: $e');
      rethrow;
    }
  }

  @override
  Future<bool> unarchiveNotification(int id) async {
    try {
      final response = await _api.unarchiveNotification(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur unarchiveNotification: $e');
      rethrow;
    }
  }

  @override
  Future<int> archiveAllReadNotifications() async {
    try {
      final response = await _api.archiveAllReadNotifications();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur archiveAllReadNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkArchiveNotifications(List<int> notificationIds) async {
    try {
      final response = await _api.bulkArchiveNotifications(notificationIds);
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur bulkArchiveNotifications: $e');
      rethrow;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  @override
  Future<bool> deleteNotification(int id) async {
    try {
      final response = await _api.deleteNotification(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteNotification: $e');
      rethrow;
    }
  }

  @override
  Future<int> deleteAllReadNotifications() async {
    try {
      final response = await _api.deleteAllReadNotifications();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur deleteAllReadNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<int> deleteAllArchivedNotifications() async {
    try {
      final response = await _api.deleteAllArchivedNotifications();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur deleteAllArchivedNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<bool> clearAllNotifications() async {
    try {
      final response = await _api.clearAllNotifications();
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur clearAllNotifications: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkDeleteNotifications(List<int> notificationIds) async {
    try {
      final response = await _api.bulkDeleteNotifications(notificationIds);
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur bulkDeleteNotifications: $e');
      rethrow;
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  @override
  Future<int> getTotalNotificationsCount() async {
    try {
      final response = await _api.getTotalNotificationsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalNotificationsCount: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.getUnreadCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getUnreadCount: $e');
      rethrow;
    }
  }

  @override
  Future<int> getReadCount() async {
    final total = await getTotalNotificationsCount();
    final unread = await getUnreadCount();
    return total - unread;
  }

  @override
  Future<int> getArchivedCount() async {
    try {
      final archived = await getArchivedNotifications(perPage: 100);
      return archived.length;
    } catch (e) {
      debugPrint('Erreur getArchivedCount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getNotificationsCountByType() async {
    try {
      final response = await _api.getNotificationsCountByType();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getNotificationsCountByType: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getNotificationsCountByPriority() async {
    try {
      final response = await _api.getNotificationsCountByPriority();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getNotificationsCountByPriority: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNotificationsByDay({int days = 30}) async {
    try {
      final notifications = await getNotifications(perPage: 100);
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      final byDay = <String, int>{};

      for (final notification in notifications) {
        if (notification.createdAt.isAfter(startDate)) {
          final dayKey = notification.createdAt.toIso8601String().split('T').first;
          byDay[dayKey] = (byDay[dayKey] ?? 0) + 1;
        }
      }

      return byDay.entries
          .map((e) => {'date': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    } catch (e) {
      debugPrint('Erreur getNotificationsByDay: $e');
      rethrow;
    }
  }

  // ============================================
  // PAGINATION
  // ============================================

  @override
  Future<bool> hasMoreNotifications({required int page, int perPage = 20}) async {
    final notifications = await getNotifications(page: page + 1, perPage: perPage);
    return notifications.isNotEmpty;
  }

  @override
  Future<int> getTotalPages({int perPage = 20}) async {
    final total = await getTotalNotificationsCount();
    return (total / perPage).ceil();
  }
}