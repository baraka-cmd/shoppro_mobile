// ============================================
// REPOSITORY IMPL : AdminPromotionRepositoryImpl
// ============================================
// Implémentation concrète du repository de gestion des promotions.
// Cette classe implémente l'interface [AdminPromotionRepository]
// et orchestre les appels API.
//
// Responsabilités :
// - Appels API via AdminPromotionApi
// - Transformation des données
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_promotion.dart';

// Repositories interfaces (même feature admin)
import '../../domain/repositories/admin_promotion_repository.dart';

// Models (même feature admin)
import '../models/admin_promotion_model.dart';

// Sources (même feature admin)
import '../sources/admin_promotion_api.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Implémentation du repository de gestion des promotions.
///
/// Gère toutes les opérations CRUD et de gestion des promotions.
class AdminPromotionRepositoryImpl implements AdminPromotionRepository {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminPromotionApi _api;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminPromotionRepositoryImpl({AdminPromotionApi? api}) : _api = api ?? AdminPromotionApi();

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  @override
  Future<List<AdminPromotion>> getPromotions({
    int page = 1,
    int perPage = 20,
    AdminPromotionType? type,
    AdminPromotionStatus? status,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _api.getPromotions(
        page: page,
        perPage: perPage,
        type: type?.code,
        status: status?.code,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );

      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getPromotions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> searchPromotions(String query, {int limit = 20}) async {
    try {
      final response = await _api.searchPromotions(query, limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur searchPromotions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> getActivePromotions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getActivePromotions(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getActivePromotions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> getUpcomingPromotions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getUpcomingPromotions(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getUpcomingPromotions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> getExpiredPromotions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.getExpiredPromotions(page: page, perPage: perPage);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getExpiredPromotions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> getFeaturedPromotions({int limit = 10}) async {
    try {
      final response = await _api.getFeaturedPromotions(limit: limit);
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getFeaturedPromotions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> getExpiringSoonPromotions() async {
    try {
      final response = await _api.getExpiringSoonPromotions();
      final data = response['data'];
      if (data is List) {
        return data
            .map((e) => AdminPromotionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erreur getExpiringSoonPromotions: $e');
      rethrow;
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  @override
  Future<AdminPromotion?> getPromotionById(int id) async {
    try {
      final response = await _api.getPromotionById(id);
      final data = response['data'];
      if (data is Map) {
        return AdminPromotionModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getPromotionById: $e');
      rethrow;
    }
  }

  @override
  Future<AdminPromotion?> getPromotionBySlug(String slug) async {
    try {
      final response = await _api.getPromotionBySlug(slug);
      final data = response['data'];
      if (data is Map) {
        return AdminPromotionModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getPromotionBySlug: $e');
      rethrow;
    }
  }

  // ============================================
  // CRUD
  // ============================================

  @override
  Future<AdminPromotion> createPromotion(AdminPromotion promotion) async {
    try {
      final model = AdminPromotionModel.fromEntity(promotion);
      final response = await _api.createPromotion(model.toJson());
      final data = response['data'];
      return AdminPromotionModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur createPromotion: $e');
      rethrow;
    }
  }

  @override
  Future<AdminPromotion> updatePromotion(AdminPromotion promotion) async {
    try {
      final model = AdminPromotionModel.fromEntity(promotion);
      final response = await _api.updatePromotion(promotion.id, model.toJson());
      final data = response['data'];
      return AdminPromotionModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      debugPrint('Erreur updatePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deletePromotion(int id) async {
    try {
      final response = await _api.deletePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deletePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> restorePromotion(int id) async {
    try {
      final response = await _api.restorePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur restorePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> forceDeletePromotion(int id) async {
    try {
      final response = await _api.deletePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur forceDeletePromotion: $e');
      rethrow;
    }
  }

  // ============================================
  // GESTION DU STATUT
  // ============================================

  @override
  Future<bool> activatePromotion(int id) async {
    try {
      final response = await _api.activatePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur activatePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deactivatePromotion(int id) async {
    try {
      final response = await _api.deactivatePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur deactivatePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> pausePromotion(int id) async {
    try {
      final response = await _api.pausePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur pausePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> resumePromotion(int id) async {
    try {
      final response = await _api.resumePromotion(id);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur resumePromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> cancelPromotion(int id, {String? reason}) async {
    try {
      final response = await _api.cancelPromotion(id, reason: reason);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur cancelPromotion: $e');
      rethrow;
    }
  }

  @override
  Future<bool> setFeaturedPromotion(int id, {required bool isFeatured}) async {
    try {
      final response = await _api.setFeaturedPromotion(id, isFeatured: isFeatured);
      return response['success'] as bool? ?? true;
    } catch (e) {
      debugPrint('Erreur setFeaturedPromotion: $e');
      rethrow;
    }
  }

  // ============================================
  // VALIDITÉ
  // ============================================

  @override
  Future<bool> isPromotionValid(int id) async {
    final promotion = await getPromotionById(id);
    return promotion?.isCurrentlyActive ?? false;
  }

  @override
  Future<bool> isSlugAvailable(String slug) async {
    try {
      final response = await _api.checkSlugAvailability(slug);
      final data = response['data'];
      if (data is Map) {
        return data['available'] as bool? ?? true;
      }
      return true;
    } catch (e) {
      debugPrint('Erreur isSlugAvailable: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isUsageLimitReached(int id) async {
    final promotion = await getPromotionById(id);
    return promotion?.isUsageLimitReached ?? false;
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  @override
  Future<int> getTotalPromotionsCount() async {
    try {
      final response = await _api.getTotalPromotionsCount();
      final data = response['data'];
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur getTotalPromotionsCount: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getPromotionsCountByStatus() async {
    try {
      final response = await _api.getPromotionsCountByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getPromotionsCountByStatus: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getPromotionsCountByType() async {
    try {
      final response = await _api.getPromotionsCountByStatus();
      final data = response['data'];
      if (data is Map) {
        return Map<String, int>.from(
          data.map((key, value) => MapEntry(key.toString(), (value as num).toInt())),
        );
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getPromotionsCountByType: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPromotionStats(int id) async {
    try {
      final response = await _api.getPromotionStats(id);
      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      debugPrint('Erreur getPromotionStats: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminPromotion>> getMostUsedPromotions({int limit = 10}) async {
    return getPromotions(
      sortBy: 'usage_count',
      sortDirection: 'desc',
      perPage: limit,
    );
  }

  @override
  Future<List<AdminPromotion>> getTopRevenuePromotions({int limit = 10}) async {
    return getPromotions(
      sortBy: 'total_revenue',
      sortDirection: 'desc',
      perPage: limit,
    );
  }

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  @override
  Future<int> bulkActivatePromotions(List<int> promotionIds) async {
    var count = 0;
    for (final id in promotionIds) {
      if (await activatePromotion(id)) count++;
    }
    return count;
  }

  @override
  Future<int> bulkDeactivatePromotions(List<int> promotionIds) async {
    var count = 0;
    for (final id in promotionIds) {
      if (await deactivatePromotion(id)) count++;
    }
    return count;
  }

  @override
  Future<int> bulkDeletePromotions(List<int> promotionIds) async {
    var count = 0;
    for (final id in promotionIds) {
      if (await deletePromotion(id)) count++;
    }
    return count;
  }

  // ============================================
  // PAGINATION
  // ============================================

  @override
  Future<bool> hasMorePromotions({required int page, int perPage = 20}) async {
    final promotions = await getPromotions(page: page + 1, perPage: perPage);
    return promotions.isNotEmpty;
  }

  @override
  Future<int> getTotalPages({int perPage = 20}) async {
    final total = await getTotalPromotionsCount();
    return (total / perPage).ceil();
  }
}