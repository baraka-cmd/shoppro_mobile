// ============================================
// INTERFACE : AdminReviewRepository
// ============================================
// Contrat pour la gestion des avis clients.
// - Liste paginée + filtres
// - Regroupement par produit
// - Modération
// - Statistiques par produit
// ============================================

import '../entities/admin_review.dart';

abstract class AdminReviewRepository {
  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  Future<List<AdminReview>> getReviews({
    int page = 1,
    int perPage = 20,
    AdminReviewStatus? status,
    int? rating,
    int? productId,
    int? userId,
    String? searchQuery,
    bool? withPhotos,
    bool? verified,
    String? sortBy,
    String? sortDirection,
  });

  Future<List<AdminReview>> searchReviews(String query, {int limit = 20});

  Future<List<AdminReview>> getPendingReviews({int page = 1, int perPage = 20});

  Future<List<AdminReview>> getApprovedReviews({int page = 1, int perPage = 20});

  Future<List<AdminReview>> getRejectedReviews({int page = 1, int perPage = 20});

  Future<List<AdminReview>> getSpamReviews({int page = 1, int perPage = 20});

  Future<List<AdminReview>> getReviewsByProduct(
    int productId, {
    int page = 1,
    int perPage = 20,
  });

  Future<List<AdminReview>> getReviewsByUser(int userId);

  Future<List<AdminReview>> getReviewsByRating(int rating);

  // ============================================
  // ✅ NOUVEAU — REGROUPEMENT PAR PRODUIT
  // ============================================

  /// Récupère les avis groupés par produit.
  /// Retourne une liste de maps :
  /// [
  ///   {
  ///     'product': { id, name, image },
  ///     'stats': { total, average_rating, with_photos, pending, approved, ... },
  ///     'reviews': [ AdminReview... ]
  ///   },
  ///   ...
  /// ]
  Future<List<Map<String, dynamic>>> getReviewsGroupedByProduct();

  /// Récupère les statistiques des avis par produit.
  /// Retourne une liste de maps :
  /// [
  ///   {
  ///     'product_id', 'product_name', 'product_image',
  ///     'total', 'average_rating', 'pending', 'approved', 'rejected', 'spam'
  ///   },
  ///   ...
  /// ]
  Future<List<Map<String, dynamic>>> getStatsByProduct();

  // ============================================
  // DÉTAILS
  // ============================================

  Future<AdminReview?> getReviewById(int id);

  // ============================================
  // MODÉRATION
  // ============================================

  Future<bool> approveReview(int id);

  Future<bool> rejectReview(int id, {String? reason});

  Future<bool> markReviewAsSpam(int id);

  Future<bool> resetReviewStatus(int id);

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  Future<bool> respondToReview(int reviewId, String response);

  Future<bool> updateAdminResponse(int reviewId, String response);

  Future<bool> deleteAdminResponse(int reviewId);

  // ============================================
  // RECOMMANDATION
  // ============================================

  Future<bool> markAsRecommended(int id);

  Future<bool> unmarkAsRecommended(int id);

  // ============================================
  // STATISTIQUES
  // ============================================

  Future<int> getTotalReviewsCount();

  Future<Map<String, int>> getReviewsCountByStatus();

  Future<Map<int, int>> getReviewsCountByRating();

  Future<double> getAverageRating();

  Future<List<AdminReview>> getMostHelpfulReviews({int limit = 10});

  Future<List<AdminReview>> getMostViewedReviews({int limit = 10});

  Future<List<AdminReview>> getRecentReviews({int limit = 10});

  // ============================================
  // SUPPRESSION
  // ============================================

  Future<bool> deleteReview(int id);

  Future<bool> restoreReview(int id);

  Future<bool> forceDeleteReview(int id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  Future<int> bulkApproveReviews(List<int> reviewIds);

  Future<int> bulkRejectReviews(List<int> reviewIds);

  Future<int> bulkDeleteReviews(List<int> reviewIds);

  Future<int> bulkMarkAsSpam(List<int> reviewIds);

  // ============================================
  // PAGINATION
  // ============================================

  Future<bool> hasMoreReviews({required int page, int perPage = 20});

  Future<int> getTotalPages({int perPage = 20});
}