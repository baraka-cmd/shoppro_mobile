// Service API des marques
// Contient toutes les requêtes HTTP vers le backend Laravel

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/brand_model.dart';

class BrandApi {
  final Dio _dio = ApiClient().dio;

  /// Récupérer la liste des marques
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _dio.get(ApiConstants.brands);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => BrandModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'une marque
  Future<BrandModel> getBrandDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.brandDetails}$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return BrandModel.fromJson(response.data['data']);
      }

      throw Exception('Marque introuvable');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les produits d'une marque
  Future<Map<String, dynamic>> getBrandProducts({
    required int brandId,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.brandProducts}$brandId',
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

  /// Récupérer les marques en vedette
  Future<List<BrandModel>> getFeaturedBrands() async {
    try {
      final brands = await getBrands();
      return brands.where((brand) => brand.isFeatured).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les marques avec des produits
  Future<List<BrandModel>> getBrandsWithProducts() async {
    try {
      final brands = await getBrands();
      return brands.where((brand) => brand.hasProducts).toList();
    } catch (e) {
      rethrow;
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