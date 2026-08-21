// Implémentation du repository d'authentification
// 
// Cette classe implémente l'interface AuthRepository.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';           // ✅ CORRIGÉ (../models au lieu de ../../domain/models)
import '../sources/auth_api.dart';            // ✅ CORRIGÉ (../sources au lieu de ../../domain/sources)

// Reste du code inchangé...

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

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _authApi.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
    );
    return _handleAuthResponse(response);
  }

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

  @override
  Future<void> logout() async {
    try {
      await _authApi.logout();
    } finally {
      await deleteToken();
      await deleteStoredUser();
    }
  }

  @override
  Future<User> getProfile() async {
    final response = await _authApi.getProfile();
    if (response['success'] == true && response['data'] != null) {
      final user = UserModel.fromJson(response['data']);
      await saveUser(user);
      return user;
    }
    throw Exception('Impossible de récupérer le profil');
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _authApi.updateProfile(data);
    if (response['success'] == true && response['data'] != null) {
      final user = UserModel.fromJson(response['data']);
      await saveUser(user);
      return user;
    }
    throw Exception('Impossible de mettre à jour le profil');
  }

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

  @override
  Future<User?> getStoredUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> userMap = json.decode(userJson);
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
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

  Future<User> _handleAuthResponse(Map<String, dynamic> response) async {
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      if (data['token'] != null) {
        await saveToken(data['token'].toString());
      }
      if (data['user'] != null) {
        final user = UserModel.fromJson(data['user']);
        await saveUser(user);
        return user;
      }
    }
    throw Exception(response['message']?.toString() ?? 'Erreur d\'authentification');
  }
}