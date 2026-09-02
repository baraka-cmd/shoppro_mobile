// ============================================
// API SOURCE : AdminCategoryApi
// ============================================
// Source de données pour les catégories admin.
// Utilise les endpoints /categories et /admin/categories.
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class AdminCategoryApi {
  final Dio _dio;

  AdminCategoryApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// Récupère toutes les catégories.
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère une catégorie par ID.
  Future<Map<String, dynamic>> getCategoryById(int id) async {
    try {
      final response = await _dio.get('/categories/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Crée une catégorie.
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/categories', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour une catégorie.
  Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/categories/$id', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime une catégorie.
  Future<Map<String, dynamic>> deleteCategory(int id) async {
    try {
      final response = await _dio.delete('/admin/categories/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les statistiques des catégories.
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get('/admin/stats/categories');
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
        return Exception('Non autorisé.');
      case 403:
        return Exception('Accès refusé.');
      case 404:
        return Exception('Catégorie introuvable.');
      case 500:
        return Exception('Erreur serveur.');
      default:
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}