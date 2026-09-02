// ============================================
// API SOURCE : AdminSettingApi
// ============================================
// Source de données distante pour la gestion des paramètres.
// Cette classe gère tous les appels HTTP vers l'API Laravel
// concernant la configuration de l'application.
//
// Responsabilités :
// - Appels API de lecture/écriture avec Dio
// - Gestion des groupes de paramètres
// - Mise à jour en masse
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

/// Source de données API pour la gestion des paramètres.
///
/// Utilise le client Dio configuré dans [ApiClient]
/// pour effectuer les requêtes HTTP vers l'API Laravel.
class AdminSettingApi {
  // ============================================
  // DÉPENDANCES
  // ============================================

  /// Client HTTP Dio
  final Dio _dio;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminSettingApi({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ============================================
  // LECTURE
  // ============================================

  /// Récupère tous les paramètres.
  ///
  /// Endpoint : GET /admin/settings
  ///
  /// Paramètres :
  /// - [group] : Filtrer par groupe
  /// - [isPublic] : Filtrer par visibilité
  /// - [isActive] : Filtrer par statut
  Future<Map<String, dynamic>> getSettings({
    String? group,
    bool? isPublic,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.get(
        '/admin/settings',
        queryParameters: {
          if (group != null && group.isNotEmpty) 'group': group,
          if (isPublic != null) 'is_public': isPublic,
          if (isActive != null) 'is_active': isActive,
        },
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère tous les paramètres groupés.
  ///
  /// Endpoint : GET /admin/settings/grouped
  Future<Map<String, dynamic>> getGroupedSettings() async {
    try {
      final response = await _dio.get('/admin/settings/grouped');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère un paramètre par sa clé.
  ///
  /// Endpoint : GET /admin/settings/{key}
  Future<Map<String, dynamic>> getSettingByKey(String key) async {
    try {
      final response = await _dio.get('/admin/settings/$key');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les paramètres d'un groupe.
  ///
  /// Endpoint : GET /admin/settings/group/{group}
  Future<Map<String, dynamic>> getSettingsByGroup(String group) async {
    try {
      final response = await _dio.get('/admin/settings/group/$group');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les paramètres publics.
  ///
  /// Endpoint : GET /admin/settings/public
  Future<Map<String, dynamic>> getPublicSettings() async {
    try {
      final response = await _dio.get('/admin/settings/public');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // MISE À JOUR
  // ============================================

  /// Met à jour un paramètre.
  ///
  /// Endpoint : PUT /admin/settings/{key}
  Future<Map<String, dynamic>> updateSetting(String key, String value) async {
    try {
      final response = await _dio.put(
        '/admin/settings/$key',
        data: {'value': value},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour plusieurs paramètres en même temps.
  ///
  /// Endpoint : PUT /admin/settings/bulk-update
  ///
  /// Format des données :
  /// ```dart
  /// {
  ///   'settings': [
  ///     {'key': 'app_name', 'value': 'ShopPro'},
  ///     {'key': 'currency', 'value': 'FCFA'},
  ///   ]
  /// }
  /// ```
  Future<Map<String, dynamic>> bulkUpdateSettings(List<Map<String, dynamic>> settings) async {
    try {
      final response = await _dio.put(
        '/admin/settings/bulk-update',
        data: {'settings': settings},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour tous les paramètres d'un groupe.
  ///
  /// Endpoint : PUT /admin/settings/group/{group}
  Future<Map<String, dynamic>> updateGroupSettings(
    String group,
    List<Map<String, dynamic>> settings,
  ) async {
    try {
      final response = await _dio.put(
        '/admin/settings/group/$group',
        data: {'settings': settings},
      );
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CRÉATION ET SUPPRESSION
  // ============================================

  /// Crée un nouveau paramètre.
  ///
  /// Endpoint : POST /admin/settings
  Future<Map<String, dynamic>> createSetting(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/settings', data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Supprime un paramètre.
  ///
  /// Endpoint : DELETE /admin/settings/{key}
  Future<Map<String, dynamic>> deleteSetting(String key) async {
    try {
      final response = await _dio.delete('/admin/settings/$key');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Active un paramètre.
  ///
  /// Endpoint : POST /admin/settings/{key}/activate
  Future<Map<String, dynamic>> activateSetting(String key) async {
    try {
      final response = await _dio.post('/admin/settings/$key/activate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Désactive un paramètre.
  ///
  /// Endpoint : POST /admin/settings/{key}/deactivate
  Future<Map<String, dynamic>> deactivateSetting(String key) async {
    try {
      final response = await _dio.post('/admin/settings/$key/deactivate');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Vérifie si une clé existe.
  ///
  /// Endpoint : GET /admin/settings/check-key/{key}
  Future<Map<String, dynamic>> keyExists(String key) async {
    try {
      final response = await _dio.get('/admin/settings/check-key/$key');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  /// Récupère le nombre total de paramètres.
  ///
  /// Endpoint : GET /admin/settings/stats/count
  Future<Map<String, dynamic>> getTotalSettingsCount() async {
    try {
      final response = await _dio.get('/admin/settings/stats/count');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre de paramètres par groupe.
  ///
  /// Endpoint : GET /admin/settings/stats/by-group
  Future<Map<String, dynamic>> getSettingsCountByGroup() async {
    try {
      final response = await _dio.get('/admin/settings/stats/by-group');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ============================================
  // CACHE
  // ============================================

  /// Rafraîchit le cache des paramètres.
  ///
  /// Endpoint : POST /admin/settings/cache/refresh
  Future<Map<String, dynamic>> refreshCache() async {
    try {
      final response = await _dio.post('/admin/settings/cache/refresh');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Efface le cache des paramètres.
  ///
  /// Endpoint : POST /admin/settings/cache/clear
  Future<Map<String, dynamic>> clearCache() async {
    try {
      final response = await _dio.post('/admin/settings/cache/clear');
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
        return Exception('Paramètre introuvable.');
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