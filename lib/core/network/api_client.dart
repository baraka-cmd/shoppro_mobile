// Client HTTP (Dio) avec gestion complète des tokens
// Ajoute automatiquement le token, gère les erreurs 401 et le refresh token

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../services/token_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio dio;
  final TokenService _tokenService = TokenService();

  // Callback pour gérer la déconnexion automatique
  VoidCallback? onUnauthorized;

  /// Initialiser le client HTTP
  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: ApiConstants.connectionTimeout),
        receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(seconds: ApiConstants.sendTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Ajouter les intercepteurs
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _handleRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          await _handleError(error, handler);
        },
      ),
    );
  }

  /// Gérer la requête (ajouter le token)
  Future<void> _handleRequest(RequestOptions options) async {
    // Vérifier si le token est valide
    final isTokenValid = await _tokenService.isTokenValid();

    if (isTokenValid) {
      final authHeader = await _tokenService.getAuthorizationHeader();
      if (authHeader != null) {
        options.headers['Authorization'] = authHeader;
      }
    }
  }

  /// Gérer les erreurs (401, etc.)
  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Gérer les erreurs 401 (non autorisé)
    if (error.response?.statusCode == 401) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Réessayer la requête avec le nouveau token
        try {
          final response = await dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: await _getHeadersWithToken(),
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );
          return handler.resolve(response);
        } catch (e) {
          // Échec de la nouvelle tentative
          await _handleUnauthorized();
        }
      } else {
        // Impossible de rafraîchir le token
        await _handleUnauthorized();
      }
    }

    // Gérer les erreurs réseau
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      debugPrint('Timeout error: ${error.message}');
    }

    if (error.type == DioExceptionType.connectionError) {
      debugPrint('Connection error: ${error.message}');
    }

    return handler.next(error);
  }

  /// Récupérer les headers avec le token
  Future<Map<String, dynamic>> _getHeadersWithToken() async {
    final headers = <String, dynamic>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final authHeader = await _tokenService.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }

    return headers;
  }

  /// Rafraîchir le token expiré
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Appeler l'endpoint de refresh (à créer dans Laravel)
      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final newToken = data['token'] as String?;

        if (newToken != null) {
          await _tokenService.saveAccessToken(newToken);

          // Sauvegarder aussi la date d'expiration si fournie
          if (data['expires_at'] != null) {
            final expiresAt = DateTime.tryParse(data['expires_at']);
            if (expiresAt != null) {
              await _tokenService.saveExpiryDate(expiresAt);
            }
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return false;
    }
  }

  /// Gérer la déconnexion (token invalide)
  Future<void> _handleUnauthorized() async {
    // Supprimer tous les tokens
    await _tokenService.clearAll();

    // Appeler le callback de déconnexion
    if (onUnauthorized != null) {
      onUnauthorized!();
    }
  }

  /// Définir le callback de déconnexion
  void setOnUnauthorized(VoidCallback callback) {
    onUnauthorized = callback;
  }

  // ============================================
  // MÉTHODES UTILITAIRES
  // ============================================

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    return await _tokenService.isTokenValid();
  }

  /// Sauvegarder un nouveau token après connexion
  Future<void> saveToken({
    required String accessToken,
    String? refreshToken,
    Duration? expiryDuration,
  }) async {
    await _tokenService.saveCompleteToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiryDuration: expiryDuration,
    );
  }

  /// Déconnexion (supprimer les tokens)
  Future<void> logout() async {
    await _tokenService.clearAll();
  }

  /// Récupérer le token actuel
  Future<String?> getToken() async {
    return await _tokenService.getAccessToken();
  }

  /// Récupérer le header d'autorisation
  Future<String?> getAuthorizationHeader() async {
    return await _tokenService.getAuthorizationHeader();
  }
}