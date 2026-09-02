// ============================================
// API SOURCE : AdminUserApi
// ============================================
// Source de données distante pour la gestion des utilisateurs.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant les utilisateurs administrés.
//
// Responsabilités :
// - Appels API CRUD avec Dio
// - Gestion des filtres et pagination
// - Gestion des erreurs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Packages externes
import 'package:dio/dio.dart';

// Core
import '../../../../core/network/api_client.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Source de données API pour la gestion des utilisateurs.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminUserApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminUserApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LISTE ET RECHERCHE
  // ============================================

  /// Récupère la liste paginée des utilisateurs.
  ///
  /// Endpoint : GET /admin/users
  ///
  /// Paramètres :
  /// - [page] : Numéro de page
  /// - [perPage] : Nombre d'éléments par page
  /// - [searchQuery] : Recherche par nom ou email
  /// - [role] : Filtrer par rôle
  /// - [status] : Filtrer par statut
  /// - [sortBy] : Champ de tri
  /// - [sortDirection] : Direction du tri
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

  /// Recherche des utilisateurs.
  ///
  /// Endpoint : GET /admin/users/search
  Future<Map<String, dynamic>> searchUsers(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/users/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les utilisateurs par rôle.
  ///
  /// Endpoint : GET /admin/users/by-role
  Future<Map<String, dynamic>> getUsersByRole(
    String role, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users/by-role/$role',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les utilisateurs par statut.
  ///
  /// Endpoint : GET /admin/users/by-status
  Future<Map<String, dynamic>> getUsersByStatus(
    String status, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/users/by-status/$status',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les utilisateurs récents.
  ///
  /// Endpoint : GET /admin/users/recent
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

  /// Récupère les détails d'un utilisateur.
  ///
  /// Endpoint : GET /admin/users/{id}
  Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final response = await _dio.get('/admin/users/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les détails d'un utilisateur par email.
  ///
  /// Endpoint : GET /admin/users/by-email/{email}
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('/admin/users/by-email/$email');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRUD
  // ============================================

  /// Crée un nouvel utilisateur.
  ///
  /// Endpoint : POST /admin/users
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/users', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour un utilisateur.
  ///
  /// Endpoint : PUT /admin/users/{id}
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/users/$id', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime un utilisateur (soft delete).
  ///
  /// Endpoint : DELETE /admin/users/{id}
  Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Restaure un utilisateur supprimé.
  ///
  /// Endpoint : POST /admin/users/{id}/restore
  Future<Map<String, dynamic>> restoreUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/restore');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime définitivement un utilisateur.
  ///
  /// Endpoint : DELETE /admin/users/{id}/force
  Future<Map<String, dynamic>> forceDeleteUser(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id/force');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // GESTION DES RÔLES
  // ============================================

  /// Change le rôle d'un utilisateur.
  ///
  /// Endpoint : PUT /admin/users/{id}/role
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

  /// Ajoute un rôle à un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/roles
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

  /// Retire un rôle à un utilisateur.
  ///
  /// Endpoint : DELETE /admin/users/{id}/roles/{role}
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

  /// Active un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/activate
  Future<Map<String, dynamic>> activateUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/activate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Désactive un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/deactivate
  Future<Map<String, dynamic>> deactivateUser(int id) async {
    try {
      final response = await _dio.post('/admin/users/$id/deactivate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Bannit un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/ban
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

  /// Suspend un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/suspend
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

  /// Lève la suspension d'un utilisateur.
  ///
  /// Endpoint : POST /admin/users/{id}/unsuspend
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

  /// Récupère le nombre total d'utilisateurs.
  ///
  /// Endpoint : GET /admin/users/stats/count
  Future<Map<String, dynamic>> getTotalUsersCount() async {
    try {
      final response = await _dio.get('/admin/users/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre d'utilisateurs par rôle.
  ///
  /// Endpoint : GET /admin/users/stats/by-role
  Future<Map<String, dynamic>> getUsersCountByRole() async {
    try {
      final response = await _dio.get('/admin/users/stats/by-role');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre d'utilisateurs par statut.
  ///
  /// Endpoint : GET /admin/users/stats/by-status
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

  /// Parse la réponse HTTP.
  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  /// Gère les erreurs Dio avec messages clairs.
  Exception _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('Non autorisé. Veuillez vous reconnecter.');
      case 403:
        return Exception('Accès refusé.');
      case 404:
        return Exception('Utilisateur introuvable.');
      case 422:
        final errors = e.response?.data?['errors'];
        return Exception('Erreur de validation: $errors');
      case 500:
        return Exception('Erreur serveur.');
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