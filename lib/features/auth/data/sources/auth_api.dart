// ============================================
// SERVICE API D'AUTHENTIFICATION
// ============================================
// Contient toutes les requêtes HTTP vers le backend Laravel.
// Conversion robuste des réponses en Map<String, dynamic>.
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class AuthApi {
  final Dio _dio = ApiClient().dio;

  // ============================================
  // INSCRIPTION
  // ============================================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      // ✅ Conversion robuste de la réponse
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CONNEXION
  // ============================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
      );

      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DÉCONNEXION
  // ============================================

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // PROFIL
  // ============================================

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.updateProfile, data: data);
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MOT DE PASSE
  // ============================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Convertit n'importe quelle réponse en Map<String, dynamic>
  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data == null) {
      return {};
    }

    // Si c'est une String (JSON), essayer de parser
    if (data is String) {
      return {'message': data};
    }

    // Dernier recours
    return {'data': data};
  }

  /// Gérer les erreurs Dio avec messages clairs
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Délai de connexion dépassé. Veuillez réessayer.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur. Vérifiez votre connexion.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        // Erreurs de validation Laravel (422)
        if (data is Map && data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return Exception(firstError.first.toString());
            }
          }
        }

        // Message d'erreur standard
        if (data is Map && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        // Réponse non-Map
        if (data is String && data.isNotEmpty) {
          return Exception(data);
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'}. Veuillez réessayer.');

      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}