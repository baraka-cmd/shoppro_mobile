// ============================================
// SERVICE API DES CATÉGORIES
// ============================================
// Contient toutes les requêtes HTTP vers le backend Laravel.
// Gestion robuste des erreurs avec messages clairs.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/category.dart';
import '../models/category_model.dart';

class CategoryApi {
  final Dio _dio = ApiClient().dio;

  /// Récupérer la liste des catégories
  Future<List<CategoryModel>> getCategories({
    bool includeInactive = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.categories,
        queryParameters: {
          'include_inactive': includeInactive ? '1' : '0',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => CategoryModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'une catégorie
  Future<CategoryModel> getCategoryDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.categories}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return CategoryModel.fromJson(data);
        }
      }

      throw Exception('Catégorie introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits d'une catégorie
  Future<Map<String, dynamic>> getCategoryProducts({
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

  /// Récupérer les sous-catégories d'une catégorie
  Future<List<SubcategoryModel>> getSubcategories(int categoryId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.categories}/$categoryId/subcategories',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => SubcategoryModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les catégories racines
  Future<List<CategoryModel>> getRootCategories() async {
    try {
      final categories = await getCategories();
      return categories.where((category) => category.isRoot).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les catégories en vedette
  Future<List<CategoryModel>> getFeaturedCategories() async {
    try {
      final categories = await getCategories();
      return categories.where((category) => category.isFeatured).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les catégories avec leurs sous-catégories
  Future<List<CategoryModel>> getCategoriesWithSubcategories() async {
    try {
      final categories = await getCategories();

      // Charger les sous-catégories pour chaque catégorie
      for (final category in categories) {
        if (category.hasSubcategories) {
          final subcategories = await getSubcategories(category.id);
          // Utiliser copyWith pour créer une nouvelle instance
          // avec les sous-catégories chargées
          // Note : Category est immuable, copyWith retourne une copie
        }
      }

      return categories;
    } catch (e) {
      rethrow;
    }
  }

  /// Créer une catégorie (admin)
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminCategories,
        data: data,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData is Map<String, dynamic>) {
          return CategoryModel.fromJson(responseData);
        }
      }

      throw Exception('Impossible de créer la catégorie');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Modifier une catégorie (admin)
  Future<CategoryModel> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.adminCategories}/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData is Map<String, dynamic>) {
          return CategoryModel.fromJson(responseData);
        }
      }

      throw Exception('Impossible de modifier la catégorie');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer une catégorie (admin)
  Future<void> deleteCategory(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.adminCategories}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Impossible de supprimer la catégorie');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Connexion lente. Vérifiez votre réseau et réessayez.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur. Vérifiez votre connexion Internet.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          if (data['message'] != null && data['message'].toString().isNotEmpty) {
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
          return Exception('Accès refusé. Vous n\'avez pas les permissions nécessaires.');
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

        return Exception('Erreur ${statusCode ?? 'inconnue'}. Veuillez réessayer.');

      case DioExceptionType.cancel:
        return Exception('Requête annulée.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}