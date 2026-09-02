// ============================================
// API SOURCE : AdminReviewApi
// ============================================
// Source de données distante pour la gestion des avis clients.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant la modération des avis.
//
// Responsabilités :
// - Appels API de modération avec Dio
// - Gestion des filtres et pagination
// - Réponse aux avis
// - Actions en masse
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

/// Source de données API pour la gestion des avis.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminReviewApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminReviewApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des avis.
  ///
  /// Endpoint : GET /admin/reviews
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  /// - [status] : Filtrer par statut
  /// - [rating] : Filtrer par note
  /// - [productId] : Filtrer par produit
  /// - [userId] : Filtrer par utilisateur
  /// - [sortBy] : Champ de tri
  /// - [sortDirection] : Direction du tri
  Future<Map<String, dynamic>> getReviews({
    int page = 1,
    int perPage = 20,
    String? status,
    int? rating,
    int? productId,
    int? userId,
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
  ///
  /// Endpoint : GET /admin/reviews/search
  Future<Map<String, dynamic>> searchReviews(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/search',
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

  /// Récupère les avis en attente.
  ///
  /// Endpoint : GET /admin/reviews/pending
  Future<Map<String, dynamic>> getPendingReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/pending',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les avis approuvés.
  ///
  /// Endpoint : GET /admin/reviews/approved
  Future<Map<String, dynamic>> getApprovedReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/approved',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les avis rejetés.
  ///
  /// Endpoint : GET /admin/reviews/rejected
  Future<Map<String, dynamic>> getRejectedReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/rejected',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les avis spam.
  ///
  /// Endpoint : GET /admin/reviews/spam
  Future<Map<String, dynamic>> getSpamReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/reviews/spam',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les avis d'un produit.
  ///
  /// Endpoint : GET /admin/reviews/by-product/{productId}
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

  /// Récupère les avis d'un utilisateur.
  ///
  /// Endpoint : GET /admin/reviews/by-user/{userId}
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

  /// Récupère les détails d'un avis.
  ///
  /// Endpoint : GET /admin/reviews/{id}
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

  /// Approuve un avis.
  ///
  /// Endpoint : POST /admin/reviews/{id}/approve
  Future<Map<String, dynamic>> approveReview(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/approve');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Rejette un avis.
  ///
  /// Endpoint : POST /admin/reviews/{id}/reject
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

  /// Marque un avis comme spam.
  ///
  /// Endpoint : POST /admin/reviews/{id}/mark-spam
  Future<Map<String, dynamic>> markReviewAsSpam(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/mark-spam');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remet un avis en attente.
  ///
  /// Endpoint : POST /admin/reviews/{id}/reset
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

  /// Répond à un avis.
///
/// Endpoint : POST /admin/reviews/{id}/respond
Future<Map<String, dynamic>> respondToReview(int reviewId, String reviewResponse) async {
  try {
    final apiResponse = await _dio.post(
      '/admin/reviews/$reviewId/respond',
      data: {'response': reviewResponse},
    );
    return _parseResponse(apiResponse);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

/// Modifie la réponse admin.
///
/// Endpoint : PUT /admin/reviews/{id}/respond
Future<Map<String, dynamic>> updateAdminResponse(int reviewId, String reviewResponse) async {
  try {
    final apiResponse = await _dio.put(
      '/admin/reviews/$reviewId/respond',
      data: {'response': reviewResponse},
    );
    return _parseResponse(apiResponse);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}

  /// Supprime la réponse admin.
  ///
  /// Endpoint : DELETE /admin/reviews/{id}/respond
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

  /// Marque un avis comme recommandé.
  ///
  /// Endpoint : POST /admin/reviews/{id}/recommend
  Future<Map<String, dynamic>> markAsRecommended(int id) async {
    try {
      final response = await _dio.post('/admin/reviews/$id/recommend');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Retire la recommandation.
  ///
  /// Endpoint : DELETE /admin/reviews/{id}/recommend
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

  /// Supprime un avis (soft delete).
  ///
  /// Endpoint : DELETE /admin/reviews/{id}
  Future<Map<String, dynamic>> deleteReview(int id) async {
    try {
      final response = await _dio.delete('/admin/reviews/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Restaure un avis supprimé.
  ///
  /// Endpoint : POST /admin/reviews/{id}/restore
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

  /// Récupère le nombre total d'avis.
  ///
  /// Endpoint : GET /admin/reviews/stats/count
  Future<Map<String, dynamic>> getTotalReviewsCount() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre d'avis par statut.
  ///
  /// Endpoint : GET /admin/reviews/stats/by-status
  Future<Map<String, dynamic>> getReviewsCountByStatus() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/by-status');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre d'avis par note.
  ///
  /// Endpoint : GET /admin/reviews/stats/by-rating
  Future<Map<String, dynamic>> getReviewsCountByRating() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/by-rating');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère la note moyenne.
  ///
  /// Endpoint : GET /admin/reviews/stats/average-rating
  Future<Map<String, dynamic>> getAverageRating() async {
    try {
      final response = await _dio.get('/admin/reviews/stats/average-rating');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Approuve plusieurs avis.
  ///
  /// Endpoint : POST /admin/reviews/bulk-approve
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

  /// Rejette plusieurs avis.
  ///
  /// Endpoint : POST /admin/reviews/bulk-reject
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

  /// Supprime plusieurs avis.
  ///
  /// Endpoint : POST /admin/reviews/bulk-delete
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
        return Exception('Avis introuvable.');
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