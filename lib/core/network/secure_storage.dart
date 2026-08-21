// Service de stockage sécurisé complet
// Wrapper autour de FlutterSecureStorage avec fonctionnalités avancées

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // ============================================
  // SAUVEGARDE
  // ============================================

  /// Sauvegarder une valeur simple
  Future<void> write({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  /// Sauvegarder un objet en JSON
  Future<void> writeJson({
    required String key,
    required Map<String, dynamic> data,
  }) async {
    await _storage.write(key: key, value: json.encode(data));
  }

  /// Sauvegarder un booléen
  Future<void> writeBool({
    required String key,
    required bool value,
  }) async {
    await _storage.write(key: key, value: value.toString());
  }

  /// Sauvegarder un entier
  Future<void> writeInt({
    required String key,
    required int value,
  }) async {
    await _storage.write(key: key, value: value.toString());
  }

  /// Sauvegarder le token d'accès
  Future<void> saveToken(String token) async {
    await write(key: tokenKey, value: token);
  }

  /// Sauvegarder le refresh token
  Future<void> saveRefreshToken(String token) async {
    await write(key: refreshTokenKey, value: token);
  }

  /// Sauvegarder l'utilisateur
  Future<void> saveUser(String userJson) async {
    await write(key: userKey, value: userJson);
  }

  /// Sauvegarder l'état onboarding
  Future<void> saveOnboardingCompleted(bool completed) async {
    await writeBool(key: onboardingKey, value: completed);
  }

  /// Sauvegarder le thème
  Future<void> saveTheme(String theme) async {
    await write(key: themeKey, value: theme);
  }

  /// Sauvegarder la langue
  Future<void> saveLanguage(String language) async {
    await write(key: languageKey, value: language);
  }

  // ============================================
  // RÉCUPÉRATION
  // ============================================

  /// Lire une valeur simple
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  /// Lire un objet JSON
  Future<Map<String, dynamic>?> readJson({required String key}) async {
    final value = await _storage.read(key: key);
    if (value != null && value.isNotEmpty) {
      try {
        return json.decode(value) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Lire un booléen
  Future<bool?> readBool({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Lire un entier
  Future<int?> readInt({required String key}) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Récupérer le token
  Future<String?> getToken() async {
    return await read(key: tokenKey);
  }

  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await read(key: refreshTokenKey);
  }

  /// Récupérer l'utilisateur
  Future<String?> getUser() async {
    return await read(key: userKey);
  }

  /// Récupérer l'utilisateur en JSON
  Future<Map<String, dynamic>?> getUserJson() async {
    return await readJson(key: userKey);
  }

  /// Vérifier si l'onboarding est complété
  Future<bool> isOnboardingCompleted() async {
    final value = await readBool(key: onboardingKey);
    return value ?? false;
  }

  /// Récupérer le thème
  Future<String?> getTheme() async {
    return await read(key: themeKey);
  }

  /// Récupérer la langue
  Future<String?> getLanguage() async {
    return await read(key: languageKey);
  }

  // ============================================
  // VÉRIFICATION
  // ============================================

  /// Vérifier si une clé existe
  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  /// Vérifier si un token existe
  Future<bool> hasToken() async {
    return await containsKey(key: tokenKey);
  }

  /// Vérifier si l'utilisateur est stocké
  Future<bool> hasUser() async {
    return await containsKey(key: userKey);
  }

  /// Vérifier si l'onboarding a été vu
  Future<bool> hasOnboarding() async {
    return await containsKey(key: onboardingKey);
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une clé
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Supprimer le token
  Future<void> deleteToken() async {
    await delete(key: tokenKey);
  }

  /// Supprimer le refresh token
  Future<void> deleteRefreshToken() async {
    await delete(key: refreshTokenKey);
  }

  /// Supprimer l'utilisateur
  Future<void> deleteUser() async {
    await delete(key: userKey);
  }

  /// Supprimer l'état onboarding
  Future<void> deleteOnboarding() async {
    await delete(key: onboardingKey);
  }

  /// Supprimer le thème
  Future<void> deleteTheme() async {
    await delete(key: themeKey);
  }

  /// Supprimer la langue
  Future<void> deleteLanguage() async {
    await delete(key: languageKey);
  }

  // ============================================
  // SUPPRESSION COMPLÈTE
  // ============================================

  /// Effacer toutes les données d'authentification
  Future<void> clearAuth() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUser();
  }

  /// Effacer toutes les préférences
  Future<void> clearPreferences() async {
    await deleteOnboarding();
    await deleteTheme();
    await deleteLanguage();
  }

  /// Effacer TOUT (déconnexion + préférences)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Récupérer toutes les clés stockées
  Future<List<String>> getAllKeys() async {
    return await _storage.readAll().then((map) => map.keys.toList());
  }

  /// Récupérer toutes les valeurs
  Future<Map<String, String>> getAllValues() async {
    return await _storage.readAll();
  }

  /// Afficher le contenu du stockage (pour débogage)
  Future<void> debugPrintAll() async {
    final allValues = await _storage.readAll();
    allValues.forEach((key, value) {
      final maskedValue = value.length > 20 ? '${value.substring(0, 20)}...' : value;
      debugPrint('$key: $maskedValue');
    });
  }
}