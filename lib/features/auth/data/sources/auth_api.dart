// Service API d'authentification
// 
// Contient toutes les requêtes HTTP vers le backend Laravel.

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class AuthApi {
  final Dio _dio = ApiClient().dio;

  // Inscription d'un utilisateur
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
          'phone': phone,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Connexion d'un utilisateur
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

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Récupérer le profil
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mettre à jour le profil
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.updateProfile, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Changer le mot de passe
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

  // Mot de passe oublié
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

  // Gérer les erreurs Dio
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
        
        if (data is Map<String, dynamic> && data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          
          if (firstError is List && firstError.isNotEmpty) {
            return Exception(firstError.first.toString());
          }
        }
        
        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }
        
        return Exception('Erreur ${statusCode ?? 'inconnue'}. Veuillez réessayer.');
      
      default:
        return Exception('Une erreur est survenue. Veuillez réessayer.');
    }
  }
}

