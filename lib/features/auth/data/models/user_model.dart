// ============================================
// MODÈLE USER (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.address,
    super.firstName,
    super.lastName,
    super.country,
    super.city,
    super.language,
    super.currency,
    super.roles,
    super.totalOrders,
    super.totalSpent,
    super.emailVerified,
    super.isActive,
    super.isBanned,
    super.isSuspended,
    super.isVerified,
  });

  /// Créer un UserModel depuis JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final stats = json['stats'];

    return UserModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      email: _parseString(json['email']),
      avatar: _parseNullableString(json['avatar']),
      phone: _parseNullableString(profile?['phone']),
      address: _parseNullableString(profile?['address']),
      firstName: _parseNullableString(profile?['first_name']),
      lastName: _parseNullableString(profile?['last_name']),
      country: _parseNullableString(profile?['country']),
      city: _parseNullableString(profile?['city']),
      language: _parseNullableString(profile?['language']),
      currency: _parseNullableString(profile?['currency']),
      roles: (json['roles'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((role) => _parseString(role['name']))
              .where((name) => name.isNotEmpty)
              .toList() ??
          [],
      totalOrders: _parseInt(stats?['total_orders']),
      totalSpent: _parseDouble(stats?['total_spent']),
      emailVerified: json['email_verified_at'] != null,
      isActive: _parseBool(json['is_active'], defaultValue: true),
      isBanned: _parseBool(json['is_banned']),
      isSuspended: _parseBool(json['is_suspended']),
      isVerified: _parseBool(json['is_verified']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    return {
      'id': json['id'],
      'name': json['name'],
      'email': json['email'],
      'avatar': json['avatar'],
      'profile': {
        'phone': json['phone'],
        'address': json['address'],
        'first_name': json['first_name'],
        'last_name': json['last_name'],
        'country': json['country'],
        'city': json['city'],
        'language': json['language'],
        'currency': json['currency'],
      },
      'roles': (json['roles'] as List)
          .map((role) => {'name': role})
          .toList(),
      'stats': {
        'total_orders': json['total_orders'],
        'total_spent': json['total_spent'],
      },
      'email_verified_at': json['email_verified'] ? DateTime.now().toIso8601String() : null,
      'is_active': json['is_active'],
      'is_banned': json['is_banned'],
      'is_suspended': json['is_suspended'],
      'is_verified': json['is_verified'],
    };
  }

  /// Copier depuis l'entité
  static UserModel fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      phone: user.phone,
      address: user.address,
      firstName: user.firstName,
      lastName: user.lastName,
      country: user.country,
      city: user.city,
      language: user.language,
      currency: user.currency,
      roles: user.roles,
      totalOrders: user.totalOrders,
      totalSpent: user.totalSpent,
      emailVerified: user.emailVerified,
      isActive: user.isActive,
      isBanned: user.isBanned,
      isSuspended: user.isSuspended,
      isVerified: user.isVerified,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }
}