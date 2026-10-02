// ============================================
// SERVICE API DES PRODUITS
// ============================================
// Contient toutes les requêtes HTTP vers le backend Laravel.
// Gestion robuste des erreurs avec messages clairs.
// ============================================

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductApi {
  final Dio _dio = ApiClient().dio;

  /// Récupérer la liste paginée des produits
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'un produit
  Future<ProductModel> getProductDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.products}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return ProductModel.fromJson(data);
        }
      }

      throw Exception('Produit introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits en vedette
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.featuredProducts,
        queryParameters: {'limit': limit},
      );

      return _parseProductList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits populaires
  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularProducts,
        queryParameters: {'limit': limit},
      );

      return _parseProductList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits récents
  Future<List<ProductModel>> getRecentProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.recentProducts,
        queryParameters: {'limit': limit},
      );

      return _parseProductList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits en promotion
  Future<List<ProductModel>> getOnSaleProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.onSaleProducts,
        queryParameters: {'limit': limit},
      );

      return _parseProductList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Rechercher des produits
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchProducts,
        queryParameters: {
          'q': query,
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Filtrer les produits
  Future<Map<String, dynamic>> filterProducts({
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    double? minRating,
    bool? onSale,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': sortBy,
        'sort_direction': sortDirection,
      };

      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (brandId != null) queryParameters['brand_id'] = brandId;
      if (minPrice != null) queryParameters['min_price'] = minPrice;
      if (maxPrice != null) queryParameters['max_price'] = maxPrice;
      if (inStock != null) queryParameters['in_stock'] = inStock ? '1' : '0';
      if (minRating != null) queryParameters['min_rating'] = minRating;
      if (onSale != null) queryParameters['on_sale'] = onSale ? '1' : '0';

      final response = await _dio.get(
        ApiConstants.filterProducts,
        queryParameters: queryParameters,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits par catégorie
  Future<Map<String, dynamic>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.categories}/$categoryId/products',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits par marque
  Future<Map<String, dynamic>> getProductsByBrand({
    required int brandId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.brands}/$brandId/products',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits similaires
  Future<List<ProductModel>> getSimilarProducts(int productId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.products}/$productId/similar',
      );

      return _parseProductList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les avis d'un produit
  Future<List<dynamic>> getProductReviews({
    required int productId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.products}/$productId/reviews',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer la note moyenne d'un produit
  Future<double> getProductAverageRating(int productId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.products}/$productId/rating',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return _parseDouble(data['average_rating']);
        }
        if (data is num) {
          return data.toDouble();
        }
      }

      return 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // AVIS (NOUVEAU) — Envoi avec photos
  // ============================================

  /// Soumettre un avis avec photos optionnelles
  /// [productId] : ID du produit
  /// [rating] : note globale 1-5
  /// [comment] : commentaire (obligatoire)
  /// [title] : titre (optionnel)
  /// [qualityRating], [priceRating], [shippingRating] : notes spécifiques (0-5)
  /// [imagePaths] : chemins locaux des photos (max 5 recommandé)
  Future<Map<String, dynamic>> submitReview({
    required int productId,
    required double rating,
    required String comment,
    String? title,
    double qualityRating = 0,
    double priceRating = 0,
    double shippingRating = 0,
    List<String> imagePaths = const [],
  }) async {
    try {
      // Construction du FormData
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('product_id', productId.toString()),
        MapEntry('rating', rating.toStringAsFixed(1)),
        MapEntry('comment', comment),
      ]);

      if (title != null && title.trim().isNotEmpty) {
        formData.fields.add(MapEntry('title', title.trim()));
      }
      if (qualityRating > 0) {
        formData.fields.add(
          MapEntry('quality_rating', qualityRating.toStringAsFixed(1)),
        );
      }
      if (priceRating > 0) {
        formData.fields.add(
          MapEntry('price_rating', priceRating.toStringAsFixed(1)),
        );
      }
      if (shippingRating > 0) {
        formData.fields.add(
          MapEntry('shipping_rating', shippingRating.toStringAsFixed(1)),
        );
      }

      // Ajout des images
      for (int i = 0; i < imagePaths.length; i++) {
        final path = imagePaths[i];
        final file = File(path);
        if (!await file.exists()) continue;

        final fileName = path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'images[]', // 👈 Laravel attend un tableau d'images
            await MultipartFile.fromFile(
              path,
              filename: fileName,
              contentType: _guessContentType(fileName),
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/reviews', // 👈 Endpoint API : POST /api/v1/reviews
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Échec de l\'envoi de l\'avis');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer un avis
  Future<void> deleteReview(int reviewId) async {
    try {
      await _dio.delete('/reviews/$reviewId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Voter pour un avis (utile / pas utile)
  Future<Map<String, dynamic>> voteReview({
    required int reviewId,
    required bool helpful,
  }) async {
    try {
      final response = await _dio.post(
        '/reviews/$reviewId/vote',
        data: {'vote_type': helpful ? 'helpful' : 'not_helpful'},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Parser une liste de produits depuis une réponse API
  /// Supporte les formats : List, Map avec indices numériques, Map avec clé "products"
  List<ProductModel> _parseProductList(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return [];

    if (responseData['success'] != true) return [];

    final data = responseData['data'];

    // Format 1 : data est une List
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => ProductModel.fromJson(json))
          .toList();
    }

    // Format 2 : data est un Map avec indices numériques (0, 1, 2...)
    if (data is Map<String, dynamic>) {
      // Vérifier si c'est un Map avec une clé "products"
      if (data['products'] is List) {
        return (data['products'] as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }

      // Sinon, prendre les valeurs du Map
      return data.values
          .whereType<Map<String, dynamic>>()
          .map((json) => ProductModel.fromJson(json))
          .toList();
    }

    // Format 3 : data est un Map non typé
    if (data is Map) {
      return data.values
          .whereType<Map<String, dynamic>>()
          .map((json) => ProductModel.fromJson(json))
          .toList();
    }

    return [];
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Devine le Content-Type d'une image selon son extension
  DioMediaType? _guessContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return DioMediaType('image', 'png');
    if (lower.endsWith('.gif')) return DioMediaType('image', 'gif');
    if (lower.endsWith('.webp')) return DioMediaType('image', 'webp');
    if (lower.endsWith('.heic')) return DioMediaType('image', 'heic');
    return DioMediaType('image', 'jpeg');
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception(
            'Connexion lente. Vérifiez votre réseau et réessayez.');

      case DioExceptionType.connectionError:
        return Exception(
            'Impossible de se connecter au serveur. Vérifiez votre connexion Internet.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          // Gestion des erreurs de validation Laravel
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                return Exception(firstError.first.toString());
              }
              return Exception(firstError.toString());
            }
          }

          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            return Exception(data['message'].toString());
          }
          if (data['error'] != null && data['error'].toString().isNotEmpty) {
            return Exception(data['error'].toString());
          }
        }

        if (statusCode == 401) {
          return Exception('Session expirée. Veuillez vous reconnecter.');
        }
        if (statusCode == 403) {
          return Exception(
              'Accès refusé. Vous n\'avez pas les permissions nécessaires.');
        }
        if (statusCode == 404) {
          return Exception('Ressource introuvable.');
        }
        if (statusCode == 422) {
          return Exception('Données invalides. Vérifiez les champs saisis.');
        }
        if (statusCode == 500) {
          return Exception('Erreur serveur. Réessayez plus tard.');
        }

        return Exception(
            'Erreur ${statusCode ?? 'inconnue'}. Veuillez réessayer.');

      case DioExceptionType.cancel:
        return Exception('Requête annulée.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}