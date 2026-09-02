// ============================================
// REPOSITORY IMPL : AdminReviewRepositoryImpl
// ============================================
// Implémentation concrète du repository de gestion des avis.
// Cette classe implémente l'interface [AdminReviewRepository]
// et orchestre les appels API pour la modération.
//
// Responsabilités :
// - Appels API via AdminReviewApi
// - Transformation des données
// - Modération des avis
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_review.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_review_repository.dart';

// Models (même feature admin)
import '../models/admin_review_model.dart';

// Sources (même feature admin)
import '../sources/admin_review_api.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository de gestion des avis.
///
/// Gère toutes les opérations de modération des avis clients.
class AdminReviewRepositoryImpl implements AdminReviewRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminReviewApi _api;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminReviewRepositoryImpl({AdminReviewApi? api}) : _api = api ?? AdminReviewApi();

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  @override
  Future<List<AdminReview>> getReviews({
    int page = 1,
    int perPage = 20,
    AdminReviewStatus? status,
    int? rating,
    int? productId,
    int? userId,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _api.getReviews(
        page: page,
        perPage: perPage,
        status: status?.code,
        rating: rating,
        productId: productId,
        userId: userId,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getReviews: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> searchReviews(String query, {int limit = 20}) async {
    try {
      final response = await _api.searchReviews(query, limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur searchReviews: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getPendingReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getPendingReviews(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getPendingReviews: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getApprovedReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getApprovedReviews(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getApprovedReviews: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getRejectedReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getRejectedReviews(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getRejectedReviews: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getSpamReviews({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getSpamReviews(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getSpamReviews: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getReviewsByProduct(
    int productId, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getReviewsByProduct(productId, page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getReviewsByProduct: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getReviewsByUser(int userId) async {
    try {
      final response = await _api.getReviewsByUser(userId);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getReviewsByUser: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getReviewsByRating(int rating) async {
    return getReviews(rating: rating);
  }

  // ============================================
  // DÉTAILS
  // ============================================

  @override
  Future<AdminReview?> getReviewById(int id) async {
    try {
      final response = await _api.getReviewById(id);
      final data = response['data'];
      if (data is Map) {
        return AdminReviewModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getReviewById: $e');
      rethrow;
    }
  }

  // ============================================
  // MODÉRATION
  // ============================================

  @override
  Future<bool> approveReview(int id) async {
    try {
      final response = await _api.approveReview(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur approveReview: $e');
      rethrow;
    }
  }

  @override
  Future<bool> rejectReview(int id, {String? reason}) async {
    try {
      final response = await _api.rejectReview(id, reason: reason);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur rejectReview: $e');
      rethrow;
    }
  }

  @override
  Future<bool> markReviewAsSpam(int id) async {
    try {
      final response = await _api.markReviewAsSpam(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markReviewAsSpam: $e');
      rethrow;
    }
  }

  @override
  Future<bool> resetReviewStatus(int id) async {
    try {
      final response = await _api.resetReviewStatus(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur resetReviewStatus: $e');
      rethrow;
    }
  }

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  @override
  Future<bool> respondToReview(int reviewId, String response) async {
    try {
      final result = await _api.respondToReview(reviewId, response);
      return result['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur respondToReview: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateAdminResponse(int reviewId, String response) async {
    try {
      final result = await _api.updateAdminResponse(reviewId, response);
      return result['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur updateAdminResponse: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteAdminResponse(int reviewId) async {
    try {
      final result = await _api.deleteAdminResponse(reviewId);
      return result['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteAdminResponse: $e');
      rethrow;
    }
  }

  // ============================================
  // RECOMMANDATION
  // ============================================

  @override
  Future<bool> markAsRecommended(int id) async {
    try {
      final response = await _api.markAsRecommended(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur markAsRecommended: $e');
      rethrow;
    }
  }

  @override
  Future<bool> unmarkAsRecommended(int id) async {
    try {
      final response = await _api.unmarkAsRecommended(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur unmarkAsRecommended: $e');
      rethrow;
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  @override
  Future<int> getTotalReviewsCount() async {
    try {
      final response = await _api.getTotalReviewsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalReviewsCount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getReviewsCountByStatus() async {
    try {
      final response = await _api.getReviewsCountByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getReviewsCountByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<Map<int, int>> getReviewsCountByRating() async {
    try {
      final response = await _api.getReviewsCountByRating();
      final data = response['data'];
      if (data is Map) {
        return Map<int, int>.from(
          data.map((key, value) => MapEntry(int.tryParse(key.toString()) ?? 0, (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getReviewsCountByRating: $e');
      rethrow;
    }
  }

  @override
  Future<double> getAverageRating() async {
    try {
      final response = await _api.getAverageRating();
      final data = response['data'];
      if (data is Map) {
        return (data['average'] as num?)?.toDouble() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getAverageRating: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminReview>> getMostHelpfulReviews({int limit = 10}) async {
    return getReviews(sortBy: 'helpful_count', sortDirection: 'desc', perPage: limit);
  }

  @override
  Future<List<AdminReview>> getMostViewedReviews({int limit = 10}) async {
    return getReviews(sortBy: 'views_count', sortDirection: 'desc', perPage: limit);
  }

  @override
  Future<List<AdminReview>> getRecentReviews({int limit = 10}) async {
    return getReviews(sortBy: 'created_at', sortDirection: 'desc', perPage: limit);
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  @override
  Future<bool> deleteReview(int id) async {
    try {
      final response = await _api.deleteReview(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deleteReview: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restoreReview(int id) async {
    try {
      final response = await _api.restoreReview(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur restoreReview: $e');
      rethrow;
    }
  }

  @override
  Future<bool> forceDeleteReview(int id) async {
    try {
      final response = await _api.deleteReview(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur forceDeleteReview: $e');
      rethrow;
    }
  }

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  @override
  Future<int> bulkApproveReviews(List<int> reviewIds) async {
    try {
      final response = await _api.bulkApproveReviews(reviewIds);
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur bulkApproveReviews: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkRejectReviews(List<int> reviewIds) async {
    try {
      final response = await _api.bulkRejectReviews(reviewIds);
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur bulkRejectReviews: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkDeleteReviews(List<int> reviewIds) async {
    try {
      final response = await _api.bulkDeleteReviews(reviewIds);
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur bulkDeleteReviews: $e');
      rethrow;
    }
  }

  @override
  Future<int> bulkMarkAsSpam(List<int> reviewIds) async {
    var count = 0;
    for (final id in reviewIds) {
      if (await markReviewAsSpam(id)) count++;
    }
    return count;
  }

  // ============================================
  // PAGINATION
  // ============================================

  @override
  Future<bool> hasMoreReviews({required int page, int perPage = 20}) async {
    final reviews = await getReviews(page: page + 1, perPage: perPage);
    return reviews.isNotEmpty;
  }

  @override
  Future<int> getTotalPages({int perPage = 20}) async {
    final total = await getTotalReviewsCount();
    return (total / perPage).ceil();
  }
}