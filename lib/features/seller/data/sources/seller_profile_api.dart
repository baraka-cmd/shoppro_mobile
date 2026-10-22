// ============================================
// API SOURCE : SellerProfileApi
// ============================================
// Gère les appels HTTP pour le profil boutique vendeur.
//
// Responsabilités :
//   - Récupérer le profil (show)
//   - Mettre à jour les infos (update)
//   - Uploader le logo (multipart)
//   - Uploader la bannière (multipart)
//   - Soumettre le KYC (multipart)
//
// Sécurité :
//   - Token injecté automatiquement par ApiClient (Dio interceptor)
//   - Gestion des codes HTTP : 200, 401, 403, 404, 409, 422, 500
//   - Uploads avec validation MIME côté backend
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Dio
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// Model
import '../models/seller_profile_model.dart';

// ============================================
// EXCEPTIONS PERSONNALISÉES
// ============================================

class SellerProfileForbiddenException implements Exception {
  final String message;
  final String? code;

  SellerProfileForbiddenException(this.message, {this.code});

  @override
  String toString() => message;
}

class SellerProfileUnauthorizedException implements Exception {
  final String message;

  SellerProfileUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class SellerProfileNotFoundException implements Exception {
  final String message;

  SellerProfileNotFoundException(this.message);

  @override
  String toString() => message;
}

class SellerProfileConflictException implements Exception {
  final String message;

  SellerProfileConflictException(this.message);

  @override
  String toString() => message;
}

class SellerProfileValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  SellerProfileValidationException(this.message, {this.errors = const {}});

  @override
  String toString() => message;

  String? getFirstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty
        ? fieldErrors.first
        : null;
  }
}

class SellerProfileServerException implements Exception {
  final String message;

  SellerProfileServerException(this.message);

  @override
  String toString() => message;
}

class SellerProfileNetworkException implements Exception {
  final String message;

  SellerProfileNetworkException(this.message);

  @override
  String toString() => message;
}

// ============================================
// API CLIENT
// ============================================

class SellerProfileApi {
  final Dio _dio;

  SellerProfileApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // SHOW — RÉCUPÉRER LE PROFIL
  // ============================================

  /// GET /seller/profile
  ///
  /// Récupère le profil du vendeur connecté.
  Future<SellerProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/seller/profile');
      return _parseSingleProfileResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProfileApi.getProfile: $e');
      throw SellerProfileServerException(
        'Impossible de récupérer le profil boutique.',
      );
    }
  }

  // ============================================
  // UPDATE — METTRE À JOUR LES INFOS
  // ============================================

  /// PUT /seller/profile
  ///
  /// Met à jour les informations modifiables du profil :
  ///   - shop_name
  ///   - description
  ///   - phone
  ///   - email
  ///   - address
  ///   - city
  ///   - country
  ///
  /// [data] : Map des champs à mettre à jour (PATCH partiel supporté).
  Future<SellerProfileModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/seller/profile', data: data);
      return _parseSingleProfileResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProfileApi.updateProfile: $e');
      throw SellerProfileServerException(
        'Impossible de mettre à jour le profil.',
      );
    }
  }

  // ============================================
  // UPLOAD LOGO
  // ============================================

  /// POST /seller/profile/logo
  ///
  /// Upload du logo de la boutique (multipart).
  ///
  /// [imagePath] : chemin local de l'image (max 2 Mo, formats JPEG/PNG/WEBP).
  Future<SellerProfileModel> uploadLogo(String imagePath) async {
    try {
      final fileName = _extractFileName(imagePath);

      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/seller/profile/logo',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _parseSingleProfileResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProfileApi.uploadLogo: $e');
      throw SellerProfileServerException(
        'Impossible d\'uploader le logo.',
      );
    }
  }

  // ============================================
  // UPLOAD BANNER
  // ============================================

  /// POST /seller/profile/banner
  ///
  /// Upload de la bannière de la boutique (multipart).
  ///
  /// [imagePath] : chemin local de l'image (max 5 Mo, formats JPEG/PNG/WEBP).
  Future<SellerProfileModel> uploadBanner(String imagePath) async {
    try {
      final fileName = _extractFileName(imagePath);

      final formData = FormData.fromMap({
        'banner': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/seller/profile/banner',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _parseSingleProfileResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProfileApi.uploadBanner: $e');
      throw SellerProfileServerException(
        'Impossible d\'uploader la bannière.',
      );
    }
  }

  // ============================================
  // SUBMIT KYC
  // ============================================

  /// POST /seller/profile/submit-kyc
  ///
  /// Soumet les documents KYC pour vérification (multipart).
  ///
  /// [idType]           : 'cni' | 'passport' | 'license' | 'residence'
  /// [idNumber]         : numéro du document
  /// [idDocumentPath]   : chemin local de la photo du document
  /// [businessLicensePath] : (optionnel) registre de commerce
  /// [selfiePath]       : (optionnel) selfie du vendeur
  /// [kycNotes]         : (optionnel) notes additionnelles
  Future<SellerProfileModel> submitKyc({
    required String idType,
    required String idNumber,
    required String idDocumentPath,
    String? businessLicensePath,
    String? selfiePath,
    String? kycNotes,
  }) async {
    try {
      final Map<String, dynamic> map = {
        'id_type': idType,
        'id_number': idNumber,
        'id_document': await MultipartFile.fromFile(
          idDocumentPath,
          filename: _extractFileName(idDocumentPath),
        ),
      };

      if (businessLicensePath != null && businessLicensePath.isNotEmpty) {
        map['business_license'] = await MultipartFile.fromFile(
          businessLicensePath,
          filename: _extractFileName(businessLicensePath),
        );
      }

      if (selfiePath != null && selfiePath.isNotEmpty) {
        map['selfie'] = await MultipartFile.fromFile(
          selfiePath,
          filename: _extractFileName(selfiePath),
        );
      }

      if (kycNotes != null && kycNotes.isNotEmpty) {
        map['kyc_notes'] = kycNotes;
      }

      final formData = FormData.fromMap(map);

      final response = await _dio.post(
        '/seller/profile/submit-kyc',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _parseSingleProfileResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      debugPrint('❌ SellerProfileApi.submitKyc: $e');
      throw SellerProfileServerException(
        'Impossible de soumettre le KYC.',
      );
    }
  }

  // ============================================
  // PARSING
  // ============================================

  SellerProfileModel _parseSingleProfileResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw SellerProfileServerException('Format de réponse invalide.');
    }

    if (body['success'] != true) {
      throw SellerProfileServerException(
        body['message']?.toString() ?? 'Erreur inconnue.',
      );
    }

    final data = body['data'];

    if (data is! Map) {
      throw SellerProfileServerException('Données du profil manquantes.');
    }

    return SellerProfileModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Extrait le nom du fichier depuis un chemin local.
  String _extractFileName(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.isNotEmpty ? parts.last : 'file.jpg';
  }

  Future<void> dismissOnboarding() async {
    await _dio.post('/seller/profile/dismiss-onboarding');
  }

  // ============================================
  // GESTION DES ERREURS
  // ============================================

  Exception _handleError(DioException e) {
    debugPrint('❌ SellerProfileApi DioException: '
        '${e.type} - ${e.response?.statusCode} - ${e.message}');

    // Erreur réseau
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return SellerProfileNetworkException(
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
        return SellerProfileUnauthorizedException(
          message.isNotEmpty
              ? message
              : 'Session expirée. Veuillez vous reconnecter.',
        );

      case 403:
        String? code;
        if (body is Map && body['code'] != null) {
          code = body['code'].toString();
        }
        return SellerProfileForbiddenException(message, code: code);

      case 404:
        return SellerProfileNotFoundException(
          message.isNotEmpty ? message : 'Profil vendeur introuvable.',
        );

      case 409:
        return SellerProfileConflictException(message);

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
        return SellerProfileValidationException(message, errors: errors);

      case 500:
      case 502:
      case 503:
        return SellerProfileServerException(
          message.isNotEmpty
              ? message
              : 'Le serveur rencontre un problème. Réessayez plus tard.',
        );

      default:
        return SellerProfileServerException(message);
    }
  }
}