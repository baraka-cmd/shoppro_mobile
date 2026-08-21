// Service API des catégories
// Contient toutes les requêtes HTTP vers le backend Laravel

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryApi {
  final Dio _dio = ApiClient().dio;

  /// Récupérer la liste des catégories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'une catégorie
  Future<CategoryModel> getCategoryDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.categoryDetails}$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return CategoryModel.fromJson(response.data['data']);
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
        '${ApiConstants.categoryProducts}$categoryId',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les sous-catégories d'une catégorie
  Future<List<SubcategoryModel>> getSubcategories(int categoryId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.categorySubcategories}$categoryId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => SubcategoryModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les catégories avec leurs sous-catégories
  Future<List<CategoryModel>> getCategoriesWithSubcategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        final categories = data
            .whereType<Map<String, dynamic>>()
            .map((json) => CategoryModel.fromJson(json))
            .toList();

        // Charger les sous-catégories pour chaque catégorie
        for (final category in categories) {
          final subcategories = await getSubcategories(category.id);
          // Note : Category est immuable, on ne peut pas modifier directement
          // Utiliser copyWith pour ajouter les sous-catégories si nécessaire
        }

        return categories;
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Gérer les erreurs Dio
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Délai de connexion dépassé. Veuillez réessayer.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}. Veuillez réessayer.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}