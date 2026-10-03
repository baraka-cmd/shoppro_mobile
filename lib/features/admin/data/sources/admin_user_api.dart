// ============================================
// API SOURCE : AdminUserApi (COMPLET)
// ============================================
// Source de données distante pour la gestion des utilisateurs.
// - CRUD classique (JSON)
// - CRUD avec upload d'avatar (FormData/multipart)
// - Gestion des rôles et statuts
// - Statistiques
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter/foundation.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class AdminUserApi {
  final Dio _dio;

  AdminUserApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int perPage = 20,
    String? searchQuery,
    String? role,
    String? status,
    String? sortBy,
    String? sortDirection,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
          if (role != null && role.isNotEmpty) 'role': role,
          if (status != null && status.isNotEmpty) 'status': status,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortDirection != null) 'sort_direction': sortDirection,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/users/search',
        queryParameters: {'q': query, 'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUsersByRole(
    String role, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users/by-role/$role',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUsersByStatus(
    String status, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users/by-status/$status',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getRecentUsers({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/admin/users/recent',
        queryParameters: {'limit': limit},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // DÉTAILS
  // ============================================

  Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final response = await _dio.get('/admin/users/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('/admin/users/by-email/$email');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRUD (JSON classique)
  // ============================================

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/users', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/users/$id', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> restoreUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/restore');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> forceDeleteUser(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id/force');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // 🆕 CRUD AVEC UPLOAD D'AVATAR (FormData)
  // ============================================

  /// Crée un nouvel utilisateur avec avatar (multipart/form-data).
  ///
  /// Endpoint : POST /admin/users
  Future<Map<String, dynamic>> createUserMultipart(FormData formData) async {
  try {
    // ⚠️ DEBUG
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔍 DEBUG CREATE USER (multipart)');
    debugPrint('📌 Endpoint : POST /admin/users');
    debugPrint('📌 Champs : ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
    debugPrint('📌 Fichiers : ${formData.files.map((e) => e.key).join(', ')}');
    debugPrint('═══════════════════════════════════════');

    final response = await _dio.post(
      '/admin/users',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    debugPrint('✅ Réponse HTTP : ${response.statusCode}');
    debugPrint('📦 Data : ${response.data}');

    return _parseResponse(response);
  } on DioException catch (e) {
    debugPrint('═══════════════════════════════════════');
    debugPrint('❌ ÉCHEC CREATE USER');
    debugPrint('📌 Status : ${e.response?.statusCode}');
    debugPrint('📌 Message : ${e.message}');
    debugPrint('📌 Data réponse : ${e.response?.data}');
    debugPrint('📌 Headers : ${e.response?.headers.map}');
    debugPrint('═══════════════════════════════════════');
    throw _handleError(e);
  }
}

  /// Met à jour un utilisateur avec avatar (multipart/form-data).
  ///
  /// ⚠️ On utilise POST + `_method=PUT` car Laravel ne gère pas
  ///    bien PUT avec multipart/form-data.
  ///
  /// Endpoint : POST /admin/users/{id} (spoof PUT)
  Future<Map<String, dynamic>> updateUserMultipart(
    int id,
    FormData formData,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/users/$id',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload l'avatar d'un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/avatar
  Future<Map<String, dynamic>> uploadAvatar(
    int id,
    FormData formData,
  ) async {
    try {
      final response = await _dio.post(
        '/admin/users/$id/avatar',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime l'avatar d'un utilisateur.
  ///
  /// Endpoint : DELETE /admin/users/{id}/avatar
  Future<Map<String, dynamic>> deleteAvatar(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id/avatar');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  Future<Map<String, dynamic>> changeUserRole(int userId, String role) async {
    try {
      final response = await _dio.put(
        '/admin/users/$userId/role',
        data: {'role': role},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addRoleToUser(int userId, String role) async {
    try {
      final response = await _dio.post(
        '/admin/users/$userId/roles',
        data: {'role': role},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> removeRoleFromUser(int userId, String role) async {
    try {
      final response = await _dio.delete('/admin/users/$userId/roles/$role');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DU STATUT
  // ============================================

  Future<Map<String, dynamic>> activateUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/activate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deactivateUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/deactivate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> banUser(int id, {String? reason}) async {
    try {
      final response = await _dio.post(
        '/admin/users/$id/ban',
        data: {'reason': reason},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> suspendUser(int id, {int days = 7}) async {
    try {
      final response = await _dio.post(
        '/admin/users/$id/suspend',
        data: {'duration_days': days},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> unsuspendUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/unsuspend');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  Future<Map<String, dynamic>> getTotalUsersCount() async {
    try {
      final response = await _dio.get('/admin/users/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUsersCountByRole() async {
    try {
      final response = await _dio.get('/admin/users/stats/by-role');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUsersCountByStatus() async {
    try {
      final response = await _dio.get('/admin/users/stats/by-status');
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
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès refusé.');
      case 404:
        return Exception('Utilisateur introuvable.');
      case 422:
        final data = e.response?.data;
        if (data is Map && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return Exception(firstError.first.toString());
            }
            return Exception(firstError.toString());
          }
        }
        return Exception('Erreur de validation.');
      case 500:
  // ⚠️ Extraire le vrai message d'erreur de Laravel
  final data = e.response?.data;
  if (data is Map) {
    final message = data['message']?.toString();
    final exception = data['exception']?.toString();
    final file = data['file']?.toString();
    final line = data['line']?.toString();

    if (message != null) {
      debugPrint('🔍 500 - Message : $message');
      if (exception != null) debugPrint('🔍 500 - Exception : $exception');
      if (file != null) debugPrint('🔍 500 - File : $file:$line');

      return Exception('$message${exception != null ? ' ($exception)' : ''}');
    }
  }
  return Exception('Erreur serveur (500).');
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return Exception('Délai de connexion dépassé.');
        }
        if (e.type == DioExceptionType.connectionError) {
          return Exception('Impossible de se connecter au serveur.');
        }
        return Exception('Erreur réseau: ${e.message}');
    }
  }
}