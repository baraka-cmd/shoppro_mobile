// ============================================
// API SOURCE : AdminBrandApi
// ============================================
// Source de données pour les marques admin.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class AdminBrandApi {
  final Dio _dio;

  AdminBrandApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<Map<String, dynamic>> getBrands() async {
    try {
      final response = await _dio.get('/brands');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBrandById(int id) async {
    try {
      final response = await _dio.get('/brands/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createBrand(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/brands', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateBrand(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/brands/$id', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteBrand(int id) async {
    try {
      final response = await _dio.delete('/admin/brands/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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
        return Exception('Marque introuvable.');
      case 500:
        return Exception('Erreur serveur.');
      default:
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}