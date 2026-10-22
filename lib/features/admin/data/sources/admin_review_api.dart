// ============================================
// API SOURCE : AdminReviewApi (ENRICHIE)
// ============================================
// Source de données distante pour la gestion des avis.
// - Liste paginée + filtres
// - Regroupement par produit
// - Photos
// - Modération
// - Statistiques par produit
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class AdminReviewApi {
  final Dio _dio;

  AdminReviewApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des avis.
  ///
  /// Params :
  /// - [status] : pending | approved | rejected | spam
  /// - [rating] : 1-5
  /// - [productId] : filtrer par produit
  /// - [userId] : filtrer par utilisateur
  /// - [searchQuery] : recherche
  /// - [withPhotos] : true pour n'avoir que les avis avec photos
  /// - [verified] : true pour n'avoir que les avis vérifiés
  /// - [groupBy] : 'product' pour grouper par produit
  /// - [sortBy] : created_at | rating | helpful_count
  /// - [sortDirection] : asc | desc
  Future<Map<String, dynamic>> getReviews({
    int page = 1,
    int perPage = 20,
    String? status,
    int? rating,
    int? productId,
    int? userId,
    String? searchQuery,
    bool? withPhotos,
    bool? verified,
    String? groupBy,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null && status.isNotEmpty) 'status': status,
          if (rating != null) 'rating': rating,
          if (productId != null) 'product_id': productId,
          if (userId != null) 'user_id': userId,
          if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
          if (withPhotos == true) 'with_photos': '1',
          if (verified == true) 'verified': '1',
          if (groupBy != null) 'group_by': groupBy,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDirection != null) 'sort_direction': sortDirection,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Recherche des avis.
  Future<Map<String, dynamic>> searchReviews(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/reviews',
        queryParameters: {
          'search': query,
          'per_page': limit,
          'page': 1,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getPendingReviews({int page = 1, int perPage = 20}) async {
    return _getByStatus('pending', page: page, perPage: perPage);
  }

  Future<Map<String, dynamic>> getApprovedReviews({int page = 1, int perPage = 20}) async {
    return _getByStatus('approved', page: page, perPage: perPage);
  }

  Future<Map<String, dynamic>> getRejectedReviews({int page = 1, int perPage = 20}) async {
    return _getByStatus('rejected', page: page, perPage: perPage);
  }

  Future<Map<String, dynamic>> getSpamReviews({int page = 1, int perPage = 20}) async {
    return _getByStatus('spam', page: page, perPage: perPage);
  }

  Future<Map<String, dynamic>> _getByStatus(
    String status, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/$status',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Avis d'un produit.
  Future<Map<String, dynamic>> getReviewsByProduct(
    int productId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/by-product/$productId',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Avis d'un utilisateur.
  Future<Map<String, dynamic>> getReviewsByUser(int userId) async {
    try {
      final response = await _dio.get('/admin/reviews/by-user/$userId');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  Future<Map<String, dynamic>> getReviewById(int id) async {
    try {
      final response = await _dio.get('/admin/reviews/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MODÉRATION
  // ============================================

  Future<Map<String, dynamic>> approveReview(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/approve');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> rejectReview(int id, {String? reason}) async {
    try {
      final response = await _dio.post(
        '/admin/reviews/$id/reject',
        data: {'reason': reason},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> markReviewAsSpam(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/mark-spam');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resetReviewStatus(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/reset');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  Future<Map<String, dynamic>> respondToReview(int reviewId, String reviewResponse) async {
    try {
      final response = await _dio.post(
        '/admin/reviews/$reviewId/respond',
        data: {'response': reviewResponse},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateAdminResponse(int reviewId, String reviewResponse) async {
    try {
      final response = await _dio.put(
        '/admin/reviews/$reviewId/respond',
        data: {'response': reviewResponse},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteAdminResponse(int reviewId) async {
    try {
      final response = await _dio.delete('/admin/reviews/$reviewId/respond');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // RECOMMANDATION
  // ============================================

  Future<Map<String, dynamic>> markAsRecommended(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/recommend');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> unmarkAsRecommended(int id) async {
    try {
      final response = await _dio.delete('/admin/reviews/$id/recommend');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  Future<Map<String, dynamic>> deleteReview(int id) async {
    try {
      final response = await _dio.delete('/admin/reviews/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> restoreReview(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/restore');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  Future<Map<String, dynamic>> getTotalReviewsCount() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getReviewsCountByStatus() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/by-status');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getReviewsCountByRating() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/by-rating');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAverageRating() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/average-rating');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// ✅ NOUVEAU — Statistiques par produit.
  Future<Map<String, dynamic>> getStatsByProduct() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/by-product');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  Future<Map<String, dynamic>> bulkApproveReviews(List<int> reviewIds) async {
    try {
      final response = await _dio.post(
        '/admin/reviews/bulk-approve',
        data: {'ids': reviewIds},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> bulkRejectReviews(List<int> reviewIds) async {
    try {
      final response = await _dio.post(
        '/admin/reviews/bulk-reject',
        data: {'ids': reviewIds},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> bulkDeleteReviews(List<int> reviewIds) async {
    try {
      final response = await _dio.post(
        '/admin/reviews/bulk-delete',
        data: {'ids': reviewIds},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès refusé.');
      case 404:
        return Exception('Avis introuvable.');
      case 422:
        final data = e.response?.data;
        if (data is Map && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) {
              return Exception(first.first.toString());
            }
          }
        }
        return Exception('Erreur de validation.');
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