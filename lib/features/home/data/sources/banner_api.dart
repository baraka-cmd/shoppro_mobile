// ============================================
// SERVICE API DES BANNIÈRES
// ============================================
// Contient les requêtes HTTP vers le backend Laravel.
// Inclut le CRUD complet (GET, POST, PUT, DELETE).
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/banner_model.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class BannerApi {
  final Dio _dio = ApiClient().dio;

  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer les bannières actives
  Future<List<BannerModel>> getBanners({String? position}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/banners',
        queryParameters: position != null ? {'position': position} : null,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => BannerModel.fromJson(json))
            .where((banner) => banner.isValid)
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les bannières par position
  Future<List<BannerModel>> getBannersByPosition(String position) async {
    return await getBanners(position: position);
  }

  /// Récupérer une bannière par ID
  Future<BannerModel?> getBannerById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/banners/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BannerModel.fromJson(
          Map<String, dynamic>.from(response.data['data']),
        );
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRÉATION
  // ============================================

  /// Créer une nouvelle bannière
  Future<Map<String, dynamic>> createBanner(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/admin/banners',
        data: data,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MISE À JOUR
  // ============================================

  /// Mettre à jour une bannière existante
  Future<Map<String, dynamic>> updateBanner(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.baseUrl}/admin/banners/$id',
        data: data,
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une bannière
  Future<Map<String, dynamic>> deleteBanner(int id) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.baseUrl}/admin/banners/$id',
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Parse la réponse HTTP en Map<String, dynamic>
  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  /// Gérer les erreurs Dio
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Délai de connexion dépassé');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}');

      default:
        return Exception('Une erreur est survenue');
    }
  }
}