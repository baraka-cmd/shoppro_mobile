// ============================================
// API SOURCE : AdminPromotionApi
// ============================================
// Source de données distante pour la gestion des promotions.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant les promotions administrées.
//
// Responsabilités :
// - Appels API CRUD avec Dio
// - Gestion des filtres et pagination
// - Gestion des statuts de promotion
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

/// Source de données API pour la gestion des promotions.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminPromotionApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminPromotionApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des promotions.
  ///
  /// Endpoint : GET /admin/promotions
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  /// - [type] : Filtrer par type
  /// - [status] : Filtrer par statut
  /// - [sortBy] : Champ de tri
  /// - [sortDirection] : Direction du tri
  Future<Map<String, dynamic>> getPromotions({
    int page = 1,
    int perPage = 20,
    String? type,
    String? status,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/promotions',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (type != null && type.isNotEmpty) 'type': type,
          if (status != null && status.isNotEmpty) 'status': status,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDirection != null) 'sort_direction': sortDirection,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Recherche des promotions.
  ///
  /// Endpoint : GET /admin/promotions/search
  Future<Map<String, dynamic>> searchPromotions(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/promotions/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les promotions actives.
  ///
  /// Endpoint : GET /admin/promotions/active
  Future<Map<String, dynamic>> getActivePromotions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/promotions/active',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les promotions à venir.
  ///
  /// Endpoint : GET /admin/promotions/upcoming
  Future<Map<String, dynamic>> getUpcomingPromotions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/promotions/upcoming',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les promotions expirées.
  ///
  /// Endpoint : GET /admin/promotions/expired
  Future<Map<String, dynamic>> getExpiredPromotions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/promotions/expired',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les promotions en vedette.
  ///
  /// Endpoint : GET /admin/promotions/featured
  Future<Map<String, dynamic>> getFeaturedPromotions({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/admin/promotions/featured',
        queryParameters: {'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les promotions expirant bientôt.
  ///
  /// Endpoint : GET /admin/promotions/expiring-soon
  Future<Map<String, dynamic>> getExpiringSoonPromotions() async {
    try {
      final response = await _dio.get('/admin/promotions/expiring-soon');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  /// Récupère les détails d'une promotion.
  ///
  /// Endpoint : GET /admin/promotions/{id}
  Future<Map<String, dynamic>> getPromotionById(int id) async {
    try {
      final response = await _dio.get('/admin/promotions/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les détails d'une promotion par slug.
  ///
  /// Endpoint : GET /admin/promotions/by-slug/{slug}
  Future<Map<String, dynamic>> getPromotionBySlug(String slug) async {
    try {
      final response = await _dio.get('/admin/promotions/by-slug/$slug');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRUD
  // ============================================

  /// Crée une nouvelle promotion.
  ///
  /// Endpoint : POST /admin/promotions
  Future<Map<String, dynamic>> createPromotion(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/promotions', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour une promotion.
  ///
  /// Endpoint : PUT /admin/promotions/{id}
  Future<Map<String, dynamic>> updatePromotion(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/promotions/$id', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime une promotion (soft delete).
  ///
  /// Endpoint : DELETE /admin/promotions/{id}
  Future<Map<String, dynamic>> deletePromotion(int id) async {
    try {
      final response = await _dio.delete('/admin/promotions/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Restaure une promotion supprimée.
  ///
  /// Endpoint : POST /admin/promotions/{id}/restore
  Future<Map<String, dynamic>> restorePromotion(int id) async {
    try {
      final response = await _dio.post('/admin/promotions/$id/restore');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DU STATUT
  // ============================================

  /// Active une promotion.
  ///
  /// Endpoint : POST /admin/promotions/{id}/activate
  Future<Map<String, dynamic>> activatePromotion(int id) async {
    try {
      final response = await _dio.post('/admin/promotions/$id/activate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Désactive une promotion.
  ///
  /// Endpoint : POST /admin/promotions/{id}/deactivate
  Future<Map<String, dynamic>> deactivatePromotion(int id) async {
    try {
      final response = await _dio.post('/admin/promotions/$id/deactivate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met en pause une promotion.
  ///
  /// Endpoint : POST /admin/promotions/{id}/pause
  Future<Map<String, dynamic>> pausePromotion(int id) async {
    try {
      final response = await _dio.post('/admin/promotions/$id/pause');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reprend une promotion en pause.
  ///
  /// Endpoint : POST /admin/promotions/{id}/resume
  Future<Map<String, dynamic>> resumePromotion(int id) async {
    try {
      final response = await _dio.post('/admin/promotions/$id/resume');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Annule une promotion.
  ///
  /// Endpoint : POST /admin/promotions/{id}/cancel
  Future<Map<String, dynamic>> cancelPromotion(int id, {String? reason}) async {
    try {
      final response = await _dio.post(
        '/admin/promotions/$id/cancel',
        data: {'reason': reason},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met en vedette une promotion.
  ///
  /// Endpoint : POST /admin/promotions/{id}/feature
  Future<Map<String, dynamic>> setFeaturedPromotion(int id, {required bool isFeatured}) async {
    try {
      final response = await _dio.post(
        '/admin/promotions/$id/feature',
        data: {'is_featured': isFeatured},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Vérifie si un slug est disponible.
  ///
  /// Endpoint : GET /admin/promotions/check-slug/{slug}
  Future<Map<String, dynamic>> checkSlugAvailability(String slug) async {
    try {
      final response = await _dio.get('/admin/promotions/check-slug/$slug');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de promotions.
  ///
  /// Endpoint : GET /admin/promotions/stats/count
  Future<Map<String, dynamic>> getTotalPromotionsCount() async {
    try {
      final response = await _dio.get('/admin/promotions/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de promotions par statut.
  ///
  /// Endpoint : GET /admin/promotions/stats/by-status
  Future<Map<String, dynamic>> getPromotionsCountByStatus() async {
    try {
      final response = await _dio.get('/admin/promotions/stats/by-status');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les statistiques d'une promotion.
  ///
  /// Endpoint : GET /admin/promotions/{id}/stats
  Future<Map<String, dynamic>> getPromotionStats(int id) async {
    try {
      final response = await _dio.get('/admin/promotions/$id/stats');
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
        return Exception('Promotion introuvable.');
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