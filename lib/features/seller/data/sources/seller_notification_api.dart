// ============================================
// API SOURCE : SellerNotificationApi
// ============================================
// Gère les appels HTTP pour les notifications vendeur.
//
// Responsabilités :
//   - Liste paginée avec filtres (all, unread, read)
//   - Marquer une notification comme lue
//   - Marquer toutes les notifications comme lues
//   - Récupérer le compteur de notifications non lues
//   - Supprimer une notification
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Gestion des codes HTTP : 200, 401, 403, 404, 422, 500
//   - Scope strict côté backend : only auth()->user()->notifications
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_notification_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerNotificationForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerNotificationForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerNotificationUnauthorizedException implements Exception {
  final String message;

  SellerNotificationUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerNotificationNotFoundException implements Exception {
  final String message;

  SellerNotificationNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerNotificationServerException implements Exception {
  final String message;

  SellerNotificationServerException(this.message);

  @override
  String toString() => message;
}

class SellerNotificationNetworkException implements Exception {
  final String message;

  SellerNotificationNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTATS PAGINÉS
// ============================================

class SellerNotificationsResult {
  final List<SellerNotificationModel> notifications;
  final SellerNotificationsStatsModel stats;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerNotificationsResult({
    required this.notifications,
    required this.stats,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.hasMore,
  });
}

class SellerReadAllResult {
  final int markedCount;
  final int unreadCount;

  SellerReadAllResult({
    required this.markedCount,
    required this.unreadCount,
  });
}

// ============================================
// API CLIENT
// ============================================

class SellerNotificationApi {
  final Dio _dio;

  SellerNotificationApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // INDEX — LISTE
  // ============================================

  /// GET /seller/notifications
  ///
  /// Liste paginée des notifications du vendeur.
  ///
  /// [filter] : all | unread | read
  /// [type]   : new_order | new_review | low_stock | payout_received | kyc_validated
  Future<SellerNotificationsResult> getNotifications({
    int page = 1,
    int perPage = 20,
    String filter = 'all',
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'filter': filter,
      };

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _dio.get(
        '/seller/notifications',
        queryParameters: queryParams,
      );

      return _parseNotificationsResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerNotificationApi.getNotifications: $e');
      throw SellerNotificationServerException(
        'Impossible de récupérer les notifications.',
      );
    }
  }

  // ============================================
  // READ — MARQUER COMME LUE
  // ============================================

  /// POST /seller/notifications/{id}/read
  ///
  /// Marque une notification comme lue.
  ///
  /// Retourne le nombre de notifications encore non lues.
  Future<int> markAsRead(String notificationId) async {
    try {
      final response = await _dio.post(
        '/seller/notifications/$notificationId/read',
      );

      final body = response.data;

      if (body is! Map || body['success'] != true) {
        throw SellerNotificationServerException(
          body is Map
              ? (body['message']?.toString() ?? 'Erreur inconnue.')
              : 'Erreur inconnue.',
        );
      }

      return _toInt(body['unread_count']);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerNotificationApi.markAsRead: $e');
      if (e is SellerNotificationServerException) rethrow;
      throw SellerNotificationServerException(
        'Impossible de marquer la notification comme lue.',
      );
    }
  }

  // ============================================
  // READ ALL — TOUT MARQUER COMME LU
  // ============================================

  /// POST /seller/notifications/read-all
  ///
  /// Marque toutes les notifications comme lues.
  Future<SellerReadAllResult> markAllAsRead() async {
    try {
      final response = await _dio.post('/seller/notifications/read-all');

      final body = response.data;

      if (body is! Map || body['success'] != true) {
        throw SellerNotificationServerException(
          body is Map
              ? (body['message']?.toString() ?? 'Erreur inconnue.')
              : 'Erreur inconnue.',
        );
      }

      return SellerReadAllResult(
        markedCount: _toInt(body['marked_count']),
        unreadCount: _toInt(body['unread_count']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerNotificationApi.markAllAsRead: $e');
      if (e is SellerNotificationServerException) rethrow;
      throw SellerNotificationServerException(
        'Impossible de marquer les notifications comme lues.',
      );
    }
  }

  // ============================================
  // UNREAD COUNT
  // ============================================

  /// GET /seller/notifications/unread-count
  ///
  /// Retourne le nombre de notifications non lues.
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/seller/notifications/unread-count');

      final body = response.data;

      if (body is! Map || body['success'] != true) {
        throw SellerNotificationServerException(
          body is Map
              ? (body['message']?.toString() ?? 'Erreur inconnue.')
              : 'Erreur inconnue.',
        );
      }

      return _toInt(body['unread_count']);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerNotificationApi.getUnreadCount: $e');
      if (e is SellerNotificationServerException) rethrow;
      throw SellerNotificationServerException(
        'Impossible de récupérer le compteur.',
      );
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// DELETE /seller/notifications/{id}
  ///
  /// Supprime une notification.
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete('/seller/notifications/$notificationId');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerNotificationApi.deleteNotification: $e');
      throw SellerNotificationServerException(
        'Impossible de supprimer la notification.',
      );
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerNotificationsResult _parseNotificationsResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerNotificationServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerNotificationServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];
    final counts = body['counts'];

    if (data is! List) {
      throw SellerNotificationServerException('Données manquantes.');
    }

    final notifications = <SellerNotificationModel>[];
    for (final item in data) {
      if (item is Map) {
        notifications.add(
          SellerNotificationModel.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    final pag = pagination is Map ? pagination : {};
    final statsData = counts is Map
        ? SellerNotificationsStatsModel.fromJson(
            Map<String, dynamic>.from(counts),
          )
        : const SellerNotificationsStatsModel();

    return SellerNotificationsResult(
      notifications: notifications,
      stats: statsData,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 20),
      hasMore: pag['has_more'] == true,
    );
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerNotificationApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerNotificationNetworkException(
        'Connexion impossible. Vérifiez votre réseau.',
      );
    }

    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    String message = 'Une erreur est survenue.';
    if (body is Map && body['message'] != null) {
      message = body['message'].toString();
    }

    switch (statusCode) {
      case 401:
        return SellerNotificationUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerNotificationForbiddenException(message, code: code);

      case 404:
        return SellerNotificationNotFoundException(
          message.isNotEmpty ? message : 'Notification introuvable.',
        );

      case 500:
      case 502:
      case 503:
        return SellerNotificationServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerNotificationServerException(message);
    }
  }

  int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}