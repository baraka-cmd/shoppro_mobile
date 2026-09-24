// ============================================
// SERVICE API LÉGAL - VERSION PREMIUM
// ============================================
// Contient les requêtes HTTP pour les
// documents légaux. Design ShopPro.
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/legal_document_model.dart';

class LegalApi {
  final Dio _dio = ApiClient().dio;

  // ============================================
  // DOCUMENTS LÉGAUX
  // ============================================

  /// Récupérer tous les documents légaux
  Future<List<LegalDocumentModel>> getLegalDocuments() async {
    try {
      final response = await _dio.get('/legal/documents');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => LegalDocumentModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un document par son slug
  Future<LegalDocumentModel?> getDocumentBySlug(String slug) async {
    try {
      final response = await _dio.get('/legal/documents/$slug');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return LegalDocumentModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer un document par son type
  Future<LegalDocumentModel?> getDocumentByType(String type) async {
    try {
      final response = await _dio.get('/legal/documents/type/$type');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return LegalDocumentModel.fromJson(data);
        }
      }

      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupérer les conditions d'utilisation
  Future<LegalDocumentModel?> getTermsConditions() async {
    return await getDocumentByType('terms_conditions');
  }

  /// Récupérer la politique de confidentialité
  Future<LegalDocumentModel?> getPrivacyPolicy() async {
    return await getDocumentByType('privacy_policy');
  }

  /// Récupérer la politique de remboursement
  Future<LegalDocumentModel?> getRefundPolicy() async {
    return await getDocumentByType('refund_policy');
  }

  /// Récupérer la politique de livraison
  Future<LegalDocumentModel?> getShippingPolicy() async {
    return await getDocumentByType('shipping_policy');
  }

  /// Récupérer la page À propos
  Future<LegalDocumentModel?> getAbout() async {
    return await getDocumentByType('about');
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
        return Exception('Impossible de se connecter au serveur.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        if (statusCode == 404) {
          return Exception('Document introuvable.');
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}