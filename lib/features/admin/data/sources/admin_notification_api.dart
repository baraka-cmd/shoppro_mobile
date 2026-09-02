// ============================================
// API SOURCE : AdminNotificationApi
// ============================================
// Source de données distante pour la gestion des notifications.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant les notifications système.
//
// Responsabilités :
// - Appels API de gestion des notifications avec Dio
// - Marquage lu/non lu
// - Archivage
// - Suppression
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Packages externes
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Source de données API pour la gestion des notifications.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminNotificationApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminNotificationApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des notifications.
  ///
  /// Endpoint : GET /admin/notifications
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  /// - [type] : Filtrer par type
  /// - [priority] : Filtrer par priorité
  /// - [isRead] : Filtrer par statut de lecture
  /// - [isArchived] : Filtrer par archivage
  /// - [sortBy] : Champ de tri
  /// - [sortDirection] : Direction du tri
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 20,
    String? type,
    String? priority,
    bool? isRead,
    bool? isArchived,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/notifications',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (type != null && type.isNotEmpty) 'type': type,
          if (priority != null && priority.isNotEmpty) 'priority': priority,
          if (isRead != null) 'is_read': isRead,
          if (isArchived != null) 'is_archived': isArchived,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDirection != null) 'sort_direction': sortDirection,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Recherche des notifications.
  ///
  /// Endpoint : GET /admin/notifications/search
  Future<Map<String, dynamic>> searchNotifications(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/notifications/search',
        queryParameters: {'q': query, 'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications non lues.
  ///
  /// Endpoint : GET /admin/notifications/unread
  Future<Map<String, dynamic>> getUnreadNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/notifications/unread',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications lues.
  ///
  /// Endpoint : GET /admin/notifications/read
  Future<Map<String, dynamic>> getReadNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/notifications/read',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications archivées.
  ///
  /// Endpoint : GET /admin/notifications/archived
  Future<Map<String, dynamic>> getArchivedNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/notifications/archived',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications urgentes.
  ///
  /// Endpoint : GET /admin/notifications/urgent
  Future<Map<String, dynamic>> getUrgentNotifications() async {
    try {
      final response = await _dio.get('/admin/notifications/urgent');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications de haute priorité.
  ///
  /// Endpoint : GET /admin/notifications/high-priority
  Future<Map<String, dynamic>> getHighPriorityNotifications() async {
    try {
      final response = await _dio.get('/admin/notifications/high-priority');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications par type.
  ///
  /// Endpoint : GET /admin/notifications/by-type/{type}
  Future<Map<String, dynamic>> getNotificationsByType(String type) async {
    try {
      final response = await _dio.get('/admin/notifications/by-type/$type');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les notifications récentes.
  ///
  /// Endpoint : GET /admin/notifications/recent
  Future<Map<String, dynamic>> getRecentNotifications({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/notifications/recent',
        queryParameters: {'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'une notification.
  ///
  /// Endpoint : GET /admin/notifications/{id}
  Future<Map<String, dynamic>> getNotificationById(int id) async {
    try {
      final response = await _dio.get('/admin/notifications/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MARQUAGE
  // ============================================

  /// Marque une notification comme lue.
  ///
  /// Endpoint : POST /admin/notifications/{id}/read
  Future<Map<String, dynamic>> markAsRead(int id) async {
    try {
      final response = await _dio.post('/admin/notifications/$id/read');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque une notification comme non lue.
  ///
  /// Endpoint : POST /admin/notifications/{id}/unread
  Future<Map<String, dynamic>> markAsUnread(int id) async {
    try {
      final response = await _dio.post('/admin/notifications/$id/unread');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque toutes les notifications comme lues.
  ///
  /// Endpoint : POST /admin/notifications/mark-all-read
  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await _dio.post('/admin/notifications/mark-all-read');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque plusieurs notifications comme lues.
  ///
  /// Endpoint : POST /admin/notifications/bulk-read
  Future<Map<String, dynamic>> bulkMarkAsRead(List<int> notificationIds) async {
    try {
      final response = await _dio.post(
        '/admin/notifications/bulk-read',
        data: {'ids': notificationIds},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ARCHIVAGE
  // ============================================

  /// Archive une notification.
  ///
  /// Endpoint : POST /admin/notifications/{id}/archive
  Future<Map<String, dynamic>> archiveNotification(int id) async {
    try {
      final response = await _dio.post('/admin/notifications/$id/archive');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Désarchive une notification.
  ///
  /// Endpoint : POST /admin/notifications/{id}/unarchive
  Future<Map<String, dynamic>> unarchiveNotification(int id) async {
    try {
      final response = await _dio.post('/admin/notifications/$id/unarchive');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Archive toutes les notifications lues.
  ///
  /// Endpoint : POST /admin/notifications/archive-all-read
  Future<Map<String, dynamic>> archiveAllReadNotifications() async {
    try {
      final response = await _dio.post('/admin/notifications/archive-all-read');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Archive plusieurs notifications.
  ///
  /// Endpoint : POST /admin/notifications/bulk-archive
  Future<Map<String, dynamic>> bulkArchiveNotifications(List<int> notificationIds) async {
    try {
      final response = await _dio.post(
        '/admin/notifications/bulk-archive',
        data: {'ids': notificationIds},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime une notification.
  ///
  /// Endpoint : DELETE /admin/notifications/{id}
  Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final response = await _dio.delete('/admin/notifications/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime toutes les notifications lues.
  ///
  /// Endpoint : DELETE /admin/notifications/delete-all-read
  Future<Map<String, dynamic>> deleteAllReadNotifications() async {
    try {
      final response = await _dio.delete('/admin/notifications/delete-all-read');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime toutes les notifications archivées.
  ///
  /// Endpoint : DELETE /admin/notifications/delete-all-archived
  Future<Map<String, dynamic>> deleteAllArchivedNotifications() async {
    try {
      final response = await _dio.delete('/admin/notifications/delete-all-archived');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime toutes les notifications.
  ///
  /// Endpoint : DELETE /admin/notifications/clear-all
  Future<Map<String, dynamic>> clearAllNotifications() async {
    try {
      final response = await _dio.delete('/admin/notifications/clear-all');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime plusieurs notifications.
  ///
  /// Endpoint : POST /admin/notifications/bulk-delete
  Future<Map<String, dynamic>> bulkDeleteNotifications(List<int> notificationIds) async {
    try {
      final response = await _dio.post(
        '/admin/notifications/bulk-delete',
        data: {'ids': notificationIds},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de notifications.
  ///
  /// Endpoint : GET /admin/notifications/stats/count
  Future<Map<String, dynamic>> getTotalNotificationsCount() async {
    try {
      final response = await _dio.get('/admin/notifications/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de notifications non lues.
  ///
  /// Endpoint : GET /admin/notifications/stats/unread-count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final response = await _dio.get('/admin/notifications/stats/unread-count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de notifications par type.
  ///
  /// Endpoint : GET /admin/notifications/stats/by-type
  Future<Map<String, dynamic>> getNotificationsCountByType() async {
    try {
      final response = await _dio.get('/admin/notifications/stats/by-type');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de notifications par priorité.
  ///
  /// Endpoint : GET /admin/notifications/stats/by-priority
  Future<Map<String, dynamic>> getNotificationsCountByPriority() async {
    try {
      final response = await _dio.get('/admin/notifications/stats/by-priority');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Parse la réponse HTTP.
  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  /// Gère les erreurs Dio avec messages clairs.
  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès refusé.');
      case 404:
        return Exception('Notification introuvable.');
      case 422:
        final errors = e.response?.data?['errors'];
        return Exception('Erreur de validation: $errors');
      case 500:
        return Exception('Erreur serveur.');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Exception('Délai de connexion dépassé.');
        }
        if (e.type == DioExceptionType.connectionError) {
          return Exception('Impossible de se connecter au serveur.');
        }
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}