// ============================================
// IMPLÉMENTATION DU REPOSITORY D'AUTHENTIFICATION
// ============================================
// Cette classe implémente l'interface AuthRepository.
// Gère les tokens, le stockage sécurisé et les réponses API.
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../sources/auth_api.dart';
import 'package:flutter/foundation.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthRepositoryImpl({
    AuthApi? authApi,
    FlutterSecureStorage? secureStorage,
  })  : _authApi = authApi ?? AuthApi(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ============================================
  // INSCRIPTION
  // ============================================

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _authApi.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      // ✅ Sauvegarder le token si présent
      if (response['token'] != null) {
        await saveToken(response['token'].toString());
      }

      // ✅ Extraire l'utilisateur de la réponse
      return _handleAuthResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // CONNEXION
  // ============================================

  @override
  Future<User> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await _authApi.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
    return _handleAuthResponse(response);
  }

  // ============================================
  // DÉCONNEXION
  // ============================================

  @override
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } finally {
      await deleteToken();
      await deleteStoredUser();
    }
  }

  // ============================================
  // PROFIL
  // ============================================

  @override
  Future<User> getProfile() async {
    final response = await _authApi.getProfile();
    final data = _extractData(response);
    final user = UserModel.fromJson(data);
    await saveUser(user);
    return user;
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _authApi.updateProfile(data);
    final innerData = _extractData(response);
    final user = UserModel.fromJson(innerData);
    await saveUser(user);
    return user;
  }

  // ============================================
  // MOT DE PASSE
  // ============================================

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _authApi.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _authApi.forgotPassword(email);
  }

  // ============================================
  // STOCKAGE LOCAL
  // ============================================

  @override
  Future<User?> getStoredUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> userMap =
            json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur getStoredUser: $e');
      return null;
    }
  }

  @override
  Future<void> saveUser(User user) async {
    final userModel = UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      phone: user.phone,
      firstName: user.firstName,
      lastName: user.lastName,
      country: user.country,
      city: user.city,
      roles: user.roles,
      totalOrders: user.totalOrders,
      totalSpent: user.totalSpent,
      emailVerified: user.emailVerified,
    );
    await _secureStorage.write(
      key: _userKey,
      value: json.encode(userModel.toJson()),
    );
  }

  @override
  Future<void> deleteStoredUser() async {
    await _secureStorage.delete(key: _userKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================
  // GESTION DES TOKENS
  // ============================================

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Gère la réponse d'authentification (login/register)
  Future<User> _handleAuthResponse(Map<String, dynamic> response) async {
    // ============================================
    // 1. EXTRAIRE LE TOKEN DANS TOUS LES FORMATS
    // ============================================
    String? token;
    String? refreshToken;
    DateTime? expiresAt;

    final data = response['data'];

    // Format 1 : { token: "..." } directement
    if (response['token'] != null) {
      token = response['token'].toString();
    }

    // Format 2 : { data: { token: "..." } }
    if (data is Map<String, dynamic> && data['token'] != null) {
      token = data['token'].toString();
    } else if (data is Map && data['token'] != null) {
      token = data['token'].toString();
    }

    // Format 3 : { data: { access_token: "..." } }
    if (data is Map<String, dynamic> && data['access_token'] != null) {
      token = data['access_token'].toString();
    } else if (data is Map && data['access_token'] != null) {
      token = data['access_token'].toString();
    }

    // Refresh token
    if (data is Map<String, dynamic> && data['refresh_token'] != null) {
      refreshToken = data['refresh_token'].toString();
    }

    // Expiration
    if (data is Map<String, dynamic> && data['expires_at'] != null) {
      expiresAt = DateTime.tryParse(data['expires_at'].toString());
    }

    // Sauvegarder le token
    if (token != null && token.isNotEmpty) {
      await saveToken(token);
      debugPrint('✅ Token sauvegardé: ${token.substring(0, 15)}...');
    } else {
      debugPrint('⚠️ Aucun token trouvé dans la réponse');
    }

    // ============================================
    // 2. EXTRAIRE L'UTILISATEUR
    // ============================================
    Map<String, dynamic> userData = {};

    final user = response['user'];

    if (data is Map<String, dynamic> && data['user'] is Map) {
      userData = Map<String, dynamic>.from(data['user'] as Map);
    } else if (data is Map && data['user'] is Map) {
      userData = Map<String, dynamic>.from(data['user'] as Map);
    } else if (user is Map) {
      userData = Map<String, dynamic>.from(user);
    } else if (data is Map<String, dynamic>) {
      userData = data;
    } else if (data is Map) {
      userData = Map<String, dynamic>.from(data);
    }

    if (userData.isNotEmpty) {
      final userModel = UserModel.fromJson(userData);
      await saveUser(userModel);
      return userModel;
    }

    throw Exception(
      response['message']?.toString() ?? 'Erreur d\'authentification',
    );
  }
  
  /// Extrait les données utilisateur d'une réponse
  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Format de réponse invalide');
  }
}