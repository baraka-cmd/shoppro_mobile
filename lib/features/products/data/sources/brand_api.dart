// ============================================
// SERVICE API DES MARQUES
// ============================================
// Contient toutes les requêtes HTTP vers le backend Laravel.
// Gestion robuste des erreurs avec messages clairs.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/brand.dart';
import '../models/brand_model.dart';

class BrandApi {
  final Dio _dio = ApiClient().dio;

  /// Récupérer la liste des marques
  Future<List<BrandModel>> getBrands({
    bool includeInactive = false,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.brands,
        queryParameters: {
          'include_inactive': includeInactive ? '1' : '0',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => BrandModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les détails d'une marque
  Future<BrandModel> getBrandDetails(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.brands}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return BrandModel.fromJson(data);
        }
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

  /// Créer une marque (admin)
  Future<BrandModel> createBrand(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminBrands,
        data: data,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData is Map<String, dynamic>) {
          return BrandModel.fromJson(responseData);
        }
      }

      throw Exception('Impossible de créer la marque');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Modifier une marque (admin)
  Future<BrandModel> updateBrand(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.adminBrands}/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final responseData = response.data['data'];
        if (responseData is Map<String, dynamic>) {
          return BrandModel.fromJson(responseData);
        }
      }

      throw Exception('Impossible de modifier la marque');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprimer une marque (admin)
  Future<void> deleteBrand(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.adminBrands}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Impossible de supprimer la marque');
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