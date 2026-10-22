// ============================================
// API SOURCE : SellerReviewApi
// ============================================
// Gère les appels HTTP pour les avis vendeur.
//
// Responsabilités :
//   - Liste paginée avec filtres (statut, note, photos, vérifiés)
//   - Détail d'un avis
//   - Actions : respond, approve, reject, markAsSpam
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Gestion des codes HTTP : 200, 401, 403, 404, 409, 422, 500
//   - Messages d'erreur en français
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_review_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerReviewForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerReviewForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerReviewUnauthorizedException implements Exception {
  final String message;

  SellerReviewUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerReviewNotFoundException implements Exception {
  final String message;

  SellerReviewNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerReviewConflictException implements Exception {
  final String message;

  SellerReviewConflictException(this.message);

  @override
  String toString() => message;
}

class SellerReviewValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  SellerReviewValidationException(this.message, {this.errors = const {}});

  @override
  String toString() => message;

  String? getFirstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty
        ? fieldErrors.first
        : null;
  }
}

class SellerReviewServerException implements Exception {
  final String message;

  SellerReviewServerException(this.message);

  @override
  String toString() => message;
}

class SellerReviewNetworkException implements Exception {
  final String message;

  SellerReviewNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTAT PAGINÉ
// ============================================

class SellerReviewsResult {
  final List<SellerReviewModel> reviews;
  final SellerReviewsStatsModel stats;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerReviewsResult({
    required this.reviews,
    required this.stats,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.hasMore,
  });
}

// ============================================
// API CLIENT
// ============================================

class SellerReviewApi {
  final Dio _dio;

  SellerReviewApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // INDEX — LISTE
  // ============================================

  /// GET /seller/reviews
  ///
  /// Liste paginée des avis sur les produits du vendeur.
  ///
  /// [status]     : all | pending | approved | rejected | spam
  /// [rating]     : 1-5
  /// [productId]  : filtrer par produit
  /// [withPhotos] : uniquement les avis avec photos
  /// [verified]   : uniquement les achats vérifiés
  /// [search]     : recherche dans le titre/contenu
  /// [sortBy]     : created_at | rating | helpful_count
  Future<SellerReviewsResult> getReviews({
    int page = 1,
    int perPage = 15,
    String? status,
    int? rating,
    int? productId,
    bool withPhotos = false,
    bool verified = false,
    String? search,
    String sortBy = 'created_at',
    String sortDir = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_dir': sortDir,
      };

      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }
      if (rating != null) {
        queryParams['rating'] = rating;
      }
      if (productId != null) {
        queryParams['product_id'] = productId;
      }
      if (withPhotos) {
        queryParams['with_photos'] = true;
      }
      if (verified) {
        queryParams['verified'] = true;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        '/seller/reviews',
        queryParameters: queryParams,
      );

      return _parseReviewsListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerReviewApi.getReviews: $e');
      throw SellerReviewServerException(
        'Impossible de récupérer les avis.',
      );
    }
  }

  // ============================================
  // SHOW — DÉTAIL
  // ============================================

  /// GET /seller/reviews/{id}
  Future<SellerReviewModel> getReviewById(int id) async {
    try {
      final response = await _dio.get('/seller/reviews/$id');
      return _parseSingleReviewResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerReviewApi.getReviewById: $e');
      throw SellerReviewServerException(
        'Impossible de récupérer l\'avis.',
      );
    }
  }

  // ============================================
  // RESPOND — RÉPONDRE
  // ============================================

  /// POST /seller/reviews/{id}/respond
  ///
  /// Le vendeur répond à un avis approuvé.
  Future<SellerReviewModel> respondToReview(
    int id, {
    required String response,
  }) async {
    try {
      final result = await _dio.post(
        '/seller/reviews/$id/respond',
        data: {'response': response},
      );

      return _parseSingleReviewResponse(result);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerReviewApi.respondToReview: $e');
      throw SellerReviewServerException(
        'Impossible de publier la réponse.',
      );
    }
  }

  // ============================================
  // APPROVE
  // ============================================

  /// POST /seller/reviews/{id}/approve
  Future<SellerReviewModel> approveReview(int id) async {
    try {
      final response = await _dio.post('/seller/reviews/$id/approve');
      return _parseSingleReviewResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerReviewApi.approveReview: $e');
      throw SellerReviewServerException(
        'Impossible d\'approuver l\'avis.',
      );
    }
  }

  // ============================================
  // REJECT
  // ============================================

  /// POST /seller/reviews/{id}/reject
  Future<SellerReviewModel> rejectReview(
    int id, {
    String? reason,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await _dio.post(
        '/seller/reviews/$id/reject',
        data: body.isNotEmpty ? body : null,
      );

      return _parseSingleReviewResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerReviewApi.rejectReview: $e');
      throw SellerReviewServerException(
        'Impossible de rejeter l\'avis.',
      );
    }
  }

  // ============================================
  // MARK AS SPAM
  // ============================================

  /// POST /seller/reviews/{id}/spam
  Future<SellerReviewModel> markAsSpam(int id) async {
    try {
      final response = await _dio.post('/seller/reviews/$id/spam');
      return _parseSingleReviewResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerReviewApi.markAsSpam: $e');
      throw SellerReviewServerException(
        'Impossible de marquer l\'avis comme spam.',
      );
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerReviewsResult _parseReviewsListResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerReviewServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerReviewServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];
    final stats = body['stats'];

    if (data is! List) {
      throw SellerReviewServerException('Données manquantes.');
    }

    final reviews = <SellerReviewModel>[];
    for (final item in data) {
      if (item is Map) {
        reviews.add(SellerReviewModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final pag = pagination is Map ? pagination : {};
    final statsData = stats is Map
        ? SellerReviewsStatsModel.fromJson(Map<String, dynamic>.from(stats))
        : const SellerReviewsStatsModel();

    return SellerReviewsResult(
      reviews: reviews,
      stats: statsData,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 15),
      hasMore: pag['has_more'] == true,
    );
  }

  SellerReviewModel _parseSingleReviewResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerReviewServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerReviewServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerReviewServerException('Données de l\'avis manquantes.');
    }

    return SellerReviewModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerReviewApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerReviewNetworkException(
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
        return SellerReviewUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerReviewForbiddenException(message, code: code);

      case 404:
        return SellerReviewNotFoundException(
          message.isNotEmpty ? message : 'Avis introuvable.',
        );

      case 409:
        return SellerReviewConflictException(message);

      case 422:
        Map<String, List<String>> errors = {};
        if (body is Map && body['errors'] is Map) {
          final rawErrors = body['errors'] as Map;
          errors = rawErrors.map((key, value) {
            if (value is List) {
              return MapEntry(
                key.toString(),
                value.map((e) => e.toString()).toList(),
              );
            }
            return MapEntry(key.toString(), [value.toString()]);
          });
        }
        return SellerReviewValidationException(message, errors: errors);

      case 500:
      case 502:
      case 503:
        return SellerReviewServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerReviewServerException(message);
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