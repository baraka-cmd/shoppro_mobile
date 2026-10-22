// ============================================
// API SOURCE : SellerProductApi
// ============================================
// Gère les appels HTTP pour les produits vendeur.
//
// Responsabilités :
//   - Liste paginée avec filtres
//   - Détail d'un produit
//   - Création (brouillon)
//   - Mise à jour
//   - Archivage (soft delete)
//   - Publication / Dépublication
//   - Duplication
//   - Aperçu client
//   - Upload images (multipart)
//   - Suppression image
//   - Réorganisation images
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient
//   - Gestion des codes HTTP (200, 201, 401, 403, 404, 422, 500)
//   - Messages d'erreur en français
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_product_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

/// Exception : accès non autorisé (KYC pending, rôle invalide)
class SellerProductForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerProductForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception : non authentifié (token expiré)
class SellerProductUnauthorizedException implements Exception {
  final String message;

  SellerProductUnauthorizedException(this.message);

  @override
  String toString() => message;
}

/// Exception : produit introuvable
class SellerProductNotFoundException implements Exception {
  final String message;

  SellerProductNotFoundException(this.message);

  @override
  String toString() => message;
}

/// Exception : erreur de validation
class SellerProductValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  SellerProductValidationException(this.message, {this.errors = const {}});

  @override
  String toString() => message;

  /// Retourne le premier message d'erreur pour un champ donné
  String? getFirstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty ? fieldErrors.first : null;
  }
}

/// Exception : conflit (déjà existant, etc.)
class SellerProductConflictException implements Exception {
  final String message;

  SellerProductConflictException(this.message);

  @override
  String toString() => message;
}

/// Exception : erreur serveur
class SellerProductServerException implements Exception {
  final String message;

  SellerProductServerException(this.message);

  @override
  String toString() => message;
}

/// Exception : erreur réseau (offline, timeout)
class SellerProductNetworkException implements Exception {
  final String message;

  SellerProductNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// RÉSULTAT DE LA LISTE PAGINÉE
// ============================================

class SellerProductsResult {
  final List<SellerProductModel> products;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final bool hasMore;

  SellerProductsResult({
    required this.products,
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

class SellerProductApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final Dio _dio;

  SellerProductApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // ENDPOINTS
  // ============================================

  /// GET /seller/products
  ///
  /// Liste paginée des produits du vendeur.
  Future<SellerProductsResult> getProducts({
    int page = 1,
    int perPage = 15,
    String? search,
    int? categoryId,
    String? status,
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

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/seller/products',
        queryParameters: queryParams,
      );

      return _parseProductsListResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.getProducts: $e');
      throw SellerProductServerException(
        'Impossible de récupérer les produits.',
      );
    }
  }

  /// GET /seller/products/{id}
  ///
  /// Détail d'un produit.
  Future<SellerProductModel> getProductById(int id) async {
    try {
      final response = await _dio.get('/seller/products/$id');
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.getProductById: $e');
      throw SellerProductServerException(
        'Impossible de récupérer le produit.',
      );
    }
  }

  /// POST /seller/products
  ///
  /// Crée un nouveau produit en brouillon.
  Future<SellerProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/seller/products', data: data);
      return _parseSingleProductResponse(response, expectedStatus: 201);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.createProduct: $e');
      throw SellerProductServerException(
        'Impossible de créer le produit.',
      );
    }
  }

  /// PUT /seller/products/{id}
  ///
  /// Met à jour un produit existant.
  Future<SellerProductModel> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/seller/products/$id', data: data);
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.updateProduct: $e');
      throw SellerProductServerException(
        'Impossible de mettre à jour le produit.',
      );
    }
  }

  /// DELETE /seller/products/{id}
  ///
  /// Archive un produit (soft delete).
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/seller/products/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.deleteProduct: $e');
      throw SellerProductServerException(
        'Impossible d\'archiver le produit.',
      );
    }
  }

  /// POST /seller/products/{id}/publish
  ///
  /// Publie un produit (draft → active).
  Future<SellerProductModel> publishProduct(int id) async {
    try {
      final response = await _dio.post('/seller/products/$id/publish');
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.publishProduct: $e');
      throw SellerProductServerException(
        'Impossible de publier le produit.',
      );
    }
  }

  /// POST /seller/products/{id}/unpublish
  ///
  /// Dépublie un produit (active → draft).
  Future<SellerProductModel> unpublishProduct(int id) async {
    try {
      final response = await _dio.post('/seller/products/$id/unpublish');
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.unpublishProduct: $e');
      throw SellerProductServerException(
        'Impossible de dépublier le produit.',
      );
    }
  }

  /// POST /seller/products/{id}/duplicate
  ///
  /// Duplique un produit.
  Future<SellerProductModel> duplicateProduct(int id) async {
    try {
      final response = await _dio.post('/seller/products/$id/duplicate');
      return _parseSingleProductResponse(response, expectedStatus: 201);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.duplicateProduct: $e');
      throw SellerProductServerException(
        'Impossible de dupliquer le produit.',
      );
    }
  }

  /// GET /seller/products/{id}/preview
  ///
  /// Aperçu du produit côté client.
  Future<SellerProductModel> previewProduct(int id) async {
    try {
      final response = await _dio.get('/seller/products/$id/preview');
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.previewProduct: $e');
      throw SellerProductServerException(
        'Impossible de générer l\'aperçu.',
      );
    }
  }

  /// POST /seller/products/{id}/images
  ///
  /// Upload d'images (multipart).
  ///
  /// [imagePaths] : liste de chemins locaux des images
  Future<SellerProductModel> uploadImages(
    int id,
    List<String> imagePaths,
  ) async {
    try {
      if (imagePaths.isEmpty) {
        throw SellerProductValidationException(
          'Aucune image à uploader.',
        );
      }

      // Construire le FormData
      final formData = FormData();

      for (var path in imagePaths) {
        final fileName = path.split('/').last.split('\\').last;
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/seller/products/$id/images',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _parseSingleProductResponse(response, expectedStatus: 201);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.uploadImages: $e');
      if (e is SellerProductValidationException) rethrow;
      throw SellerProductServerException(
        'Impossible d\'uploader les images.',
      );
    }
  }

  /// DELETE /seller/products/{id}/images/{imageId}
  ///
  /// Supprime une image d'un produit.
  Future<SellerProductModel> deleteImage(int productId, int imageId) async {
    try {
      final response = await _dio.delete(
        '/seller/products/$productId/images/$imageId',
      );
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.deleteImage: $e');
      throw SellerProductServerException(
        'Impossible de supprimer l\'image.',
      );
    }
  }

  /// POST /seller/products/{id}/images/reorder
  ///
  /// Réorganise les images.
  Future<SellerProductModel> reorderImages(
    int id,
    List<int> imageIds,
  ) async {
    try {
      final response = await _dio.post(
        '/seller/products/$id/images/reorder',
        data: {'image_ids': imageIds},
      );
      return _parseSingleProductResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProductApi.reorderImages: $e');
      throw SellerProductServerException(
        'Impossible de réorganiser les images.',
      );
    }
  }

  // ============================================
  // PARSING DES RÉPONSES
  // ============================================

  SellerProductsResult _parseProductsListResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerProductServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerProductServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];
    final pagination = body['pagination'];

    if (data is! List) {
      throw SellerProductServerException('Données manquantes.');
    }

    final products = data
        .whereType<Map>()
        .map((e) => SellerProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final pag = pagination is Map ? pagination : {};

    return SellerProductsResult(
      products: products,
      total: _toInt(pag['total']),
      currentPage: _toInt(pag['current_page'], defaultValue: 1),
      lastPage: _toInt(pag['last_page'], defaultValue: 1),
      perPage: _toInt(pag['per_page'], defaultValue: 15),
      hasMore: pag['has_more'] == true,
    );
  }

  SellerProductModel _parseSingleProductResponse(
    Response response, {
    int expectedStatus = 200,
  }) {
    final body = response.data;

    if (body is! Map) {
      throw SellerProductServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerProductServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerProductServerException('Données du produit manquantes.');
    }

    return SellerProductModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
  debugPrint('❌ SellerProductApi DioException: '
      '${e.type} - ${e.response?.statusCode} - ${e.message}');

  // Erreur réseau
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError) {
    return SellerProductNetworkException(
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
      return SellerProductUnauthorizedException(
        message.isNotEmpty
            ? message
            : 'Session expirée. Veuillez vous reconnecter.',
      );

    case 403:
      String? code;
      if (body is Map && body['code'] != null) {
        code = body['code'].toString();
      }
      return SellerProductForbiddenException(message, code: code);

    case 404:
      return SellerProductNotFoundException(
        message.isNotEmpty ? message : 'Produit introuvable.',
      );

    case 409:
      return SellerProductConflictException(message);

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

      // 🔍 DEBUG : Affichage détaillé des erreurs de validation
      debugPrint('==========================================');
      debugPrint('🔴 ERREUR 422 - VALIDATION');
      debugPrint('Message: $message');
      debugPrint('--- Détails des champs en erreur ---');
      if (errors.isEmpty) {
        debugPrint('  (Aucun détail disponible)');
        debugPrint('  Body brut: $body');
      } else {
        for (final entry in errors.entries) {
          debugPrint('  • ${entry.key}: ${entry.value.join(", ")}');
        }
      }
      debugPrint('==========================================');

      return SellerProductValidationException(message, errors: errors);

    case 500:
    case 502:
    case 503:
      return SellerProductServerException(
        message.isNotEmpty
            ? message
            : 'Le serveur rencontre un problème. Réessayez plus tard.',
      );

    default:
      return SellerProductServerException(message);
  }
}


  /// Convertit une valeur en int avec fallback.
  int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}