// Service de gestion des tokens d'authentification
// Gère la sauvegarde, la récupération, la vérification et la suppression des tokens

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenData {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final DateTime? issuedAt;

  const TokenData({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.issuedAt,
  });

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt?.toIso8601String(),
      'issued_at': issuedAt?.toIso8601String(),
    };
  }

  // Créer depuis JSON
  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      issuedAt: json['issued_at'] != null
          ? DateTime.tryParse(json['issued_at'] as String)
          : null,
    );
  }
}

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Clés de stockage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryKey = 'token_expiry';
  static const String _issuedAtKey = 'token_issued_at';
  static const String _tokenDataKey = 'token_data';

  // ============================================
  // SAUVEGARDE
  // ============================================

  /// Sauvegarder le token d'accès
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Sauvegarder le refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Sauvegarder la date d'expiration
  Future<void> saveExpiryDate(DateTime date) async {
    await _storage.write(key: _expiryKey, value: date.toIso8601String());
  }

  /// Sauvegarder la date d'émission
  Future<void> saveIssuedAt(DateTime date) async {
    await _storage.write(key: _issuedAtKey, value: date.toIso8601String());
  }

  /// Sauvegarder toutes les données du token
  Future<void> saveTokenData(TokenData tokenData) async {
    await _storage.write(
      key: _tokenDataKey,
      value: json.encode(tokenData.toJson()),
    );
  }

  /// Sauvegarder un token complet avec expiration
  Future<void> saveCompleteToken({
    required String accessToken,
    String? refreshToken,
    Duration? expiryDuration,
  }) async {
    final now = DateTime.now();
    final expiresAt = expiryDuration != null ? now.add(expiryDuration) : null;

    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    if (expiresAt != null) {
      await saveExpiryDate(expiresAt);
    }
    await saveIssuedAt(now);

    await saveTokenData(TokenData(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      issuedAt: now,
    ));
  }

  // ============================================
  // RÉCUPÉRATION
  // ============================================

  /// Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Récupérer la date d'expiration
  Future<DateTime?> getExpiryDate() async {
    final dateStr = await _storage.read(key: _expiryKey);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  /// Récupérer la date d'émission
  Future<DateTime?> getIssuedAt() async {
    final dateStr = await _storage.read(key: _issuedAtKey);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  /// Récupérer toutes les données du token
  Future<TokenData?> getTokenData() async {
    final dataStr = await _storage.read(key: _tokenDataKey);
    if (dataStr != null && dataStr.isNotEmpty) {
      try {
        final Map<String, dynamic> decodeData = jsonDecode(dataStr);
        return TokenData.fromJson(decodeData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Récupérer le header d'autorisation complet
  Future<String?> getAuthorizationHeader() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      return 'Bearer $token';
    }
    return null;
  }

  // ============================================
  // VÉRIFICATION
  // ============================================

  /// Vérifier si un token existe
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Vérifier si le token est expiré
  Future<bool> isTokenExpired() async {
    final expiryDate = await getExpiryDate();
    if (expiryDate == null) {
      // Pas de date d'expiration = considérer comme valide
      return false;
    }
    return DateTime.now().isAfter(expiryDate);
  }

  /// Vérifier si le token est valide (existe et non expiré)
  Future<bool> isTokenValid() async {
    if (!await hasToken()) {
      return false;
    }
    return !await isTokenExpired();
  }

  /// Vérifier si le token expire bientôt (dans les X prochaines minutes)
  Future<bool> isTokenExpiringSoon({int minutes = 5}) async {
    final expiryDate = await getExpiryDate();
    if (expiryDate == null) {
      return false;
    }
    final soon = DateTime.now().add(Duration(minutes: minutes));
    return soon.isAfter(expiryDate) && expiryDate.isAfter(DateTime.now());
  }

  /// Récupérer le temps restant avant expiration
  Future<Duration?> getRemainingTime() async {
    final expiryDate = await getExpiryDate();
    if (expiryDate == null) {
      return null;
    }
    final remaining = expiryDate.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Récupérer le temps écoulé depuis l'émission
  Future<Duration?> getElapsedTime() async {
    final issuedAt = await getIssuedAt();
    if (issuedAt == null) {
      return null;
    }
    return DateTime.now().difference(issuedAt);
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer le token d'accès
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Supprimer le refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Supprimer la date d'expiration
  Future<void> deleteExpiryDate() async {
    await _storage.delete(key: _expiryKey);
  }

  /// Supprimer la date d'émission
  Future<void> deleteIssuedAt() async {
    await _storage.delete(key: _issuedAtKey);
  }

  /// Supprimer toutes les données du token
  Future<void> deleteTokenData() async {
    await _storage.delete(key: _tokenDataKey);
  }

  /// Supprimer tout (déconnexion complète)
  Future<void> clearAll() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteExpiryDate();
    await deleteIssuedAt();
    await deleteTokenData();
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Décoder un JWT pour extraire les claims
  Map<String, dynamic>? decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Extraire la date d'expiration d'un JWT
  DateTime? getJwtExpiryDate(String token) {
    final claims = decodeJwt(token);
    if (claims != null && claims.containsKey('exp')) {
      final exp = claims['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
    }
    return null;
  }

  /// Vérifier si un JWT est expiré
  bool isJwtExpired(String token) {
    final expiryDate = getJwtExpiryDate(token);
    if (expiryDate == null) {
      return false;
    }
    return DateTime.now().isAfter(expiryDate);
  }

  /// Extraire l'email d'un JWT
  String? getJwtEmail(String token) {
    final claims = decodeJwt(token);
    if (claims != null && claims.containsKey('email')) {
      return claims['email'] as String?;
    }
    return null;
  }

  /// Extraire le rôle d'un JWT
  String? getJwtRole(String token) {
    final claims = decodeJwt(token);
    if (claims != null && claims.containsKey('role')) {
      return claims['role'] as String?;
    }
    return null;
  }

  /// Extraire l'ID utilisateur d'un JWT
  int? getJwtUserId(String token) {
    final claims = decodeJwt(token);
    if (claims != null && claims.containsKey('sub')) {
      return int.tryParse(claims['sub'].toString());
    }
    return null;
  }
}