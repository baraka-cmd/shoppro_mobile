// ============================================
// API SOURCE : SellerDashboardApi
// ============================================
// Gère les appels HTTP pour le dashboard vendeur.
//
// Responsabilités :
//   - GET /seller/dashboard           → KPIs complets
//   - GET /seller/dashboard/sales-chart → graphique
//   - GET /seller/dashboard/recent-orders → dernières commandes
//   - GET /seller/dashboard/top-products  → top produits
//   - GET /seller/dashboard/alerts        → alertes
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Gestion des codes HTTP : 200, 401, 403, 404, 500
//   - Messages d'erreur en français
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

// Model
import '../models/seller_dashboard_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

/// Exception : accès non autorisé (KYC pending, rôle invalide)
class SellerDashboardForbiddenException implements Exception {
  final String message;
  final String? kycStatus;
  final String? code;

  SellerDashboardForbiddenException(
    this.message, {
    this.kycStatus,
    this.code,
  });

  @override
  String toString() => message;
}

/// Exception : non authentifié (token expiré)
class SellerDashboardUnauthorizedException implements Exception {
  final String message;

  SellerDashboardUnauthorizedException(this.message);

  @override
  String toString() => message;
}

/// Exception : erreur serveur
class SellerDashboardServerException implements Exception {
  final String message;

  SellerDashboardServerException(this.message);

  @override
  String toString() => message;
}

/// Exception : erreur réseau (offline, timeout)
class SellerDashboardNetworkException implements Exception {
  final String message;

  SellerDashboardNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// API CLIENT
// ============================================

class SellerDashboardApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final Dio _dio;

  SellerDashboardApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // ENDPOINTS
  // ============================================

  /// GET /seller/dashboard
  ///
  /// Récupère tous les KPIs du dashboard.
  Future<SellerDashboardModel> getDashboard() async {
    try {
      final response = await _dio.get('/seller/dashboard');
      return _parseDashboardResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerDashboardApi.getDashboard: $e');
      throw SellerDashboardServerException(
        'Impossible de récupérer le dashboard.',
      );
    }
  }

  /// GET /seller/dashboard/sales-chart?period=7|30|90
  ///
  /// Récupère les données du graphique de ventes.
  Future<Map<String, dynamic>> getSalesChart({int period = 30}) async {
    try {
      final response = await _dio.get(
        '/seller/dashboard/sales-chart',
        queryParameters: {'period': period},
      );

      return _parseMapResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerDashboardApi.getSalesChart: $e');
      throw SellerDashboardServerException(
        'Impossible de récupérer le graphique.',
      );
    }
  }

  /// GET /seller/dashboard/recent-orders?limit=10
  ///
  /// Récupère les dernières commandes.
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/seller/dashboard/recent-orders',
        queryParameters: {'limit': limit},
      );

      return _parseListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerDashboardApi.getRecentOrders: $e');
      throw SellerDashboardServerException(
        'Impossible de récupérer les commandes récentes.',
      );
    }
  }

  /// GET /seller/dashboard/top-products?limit=5
  ///
  /// Récupère les produits les plus vendus.
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/seller/dashboard/top-products',
        queryParameters: {'limit': limit},
      );

      return _parseListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerDashboardApi.getTopProducts: $e');
      throw SellerDashboardServerException(
        'Impossible de récupérer les top produits.',
      );
    }
  }

  /// GET /seller/dashboard/alerts
  ///
  /// Récupère les alertes actionnables.
  Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final response = await _dio.get('/seller/dashboard/alerts');

      return _parseListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerDashboardApi.getAlerts: $e');
      throw SellerDashboardServerException(
        'Impossible de récupérer les alertes.',
      );
    }
  }

  // ============================================
  // PARSING DES RÉPONSES
  // ============================================

  /// Parse la réponse du dashboard.
  ///
  /// Structure attendue :
  /// {
  ///   "success": true,
  ///   "message": "...",
  ///   "data": { ...dashboard... }
  /// }
  SellerDashboardModel _parseDashboardResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerDashboardServerException(
        'Format de réponse invalide.',
      );
    }

    final success = body['success'] == true;
    if (!success) {
      throw SellerDashboardServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerDashboardServerException(
        'Données du dashboard manquantes.',
      );
    }

    return SellerDashboardModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  /// Parse une réponse Map (data générique).
  Map<String, dynamic> _parseMapResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerDashboardServerException(
        'Format de réponse invalide.',
      );
    }

    final success = body['success'] == true;
    if (!success) {
      throw SellerDashboardServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerDashboardServerException(
        'Données manquantes.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  /// Parse une réponse List.
  List<Map<String, dynamic>> _parseListResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerDashboardServerException(
        'Format de réponse invalide.',
      );
    }

    final success = body['success'] == true;
    if (!success) {
      throw SellerDashboardServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerDashboardApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerDashboardNetworkException(
        'Connexion impossible. Vérifiez votre réseau.',
      );
    }

    // Erreur HTTP
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    String message = 'Une erreur est survenue.';
    if (body is Map && body['message'] != null) {
      message = body['message'].toString();
    }

    switch (statusCode) {
      case 401:
        return SellerDashboardUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        // KYC pending / rejeté → message spécifique
        String? kycStatus;
        String? code;

        if (body is Map) {
          code = body['code']?.toString();
          final data = body['data'];
          if (data is Map && data['kyc_status'] != null) {
            kycStatus = data['kyc_status'].toString();
          }
        }

        return SellerDashboardForbiddenException(
          message.isNotEmpty ? message : 'Accès refusé.',
          kycStatus: kycStatus,
          code: code,
        );

      case 404:
        return SellerDashboardServerException(
          message.isNotEmpty ? message : 'Ressource introuvable.',
        );

      case 500:
      case 502:
      case 503:
        return SellerDashboardServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerDashboardServerException(message);
    }
  }
}