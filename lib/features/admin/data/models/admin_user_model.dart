// ============================================
// MODEL : AdminUserModel
// ============================================
// Modèle de sérialisation pour les utilisateurs administrés.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (AdminUser).
//
// Responsabilités :
// - Conversion JSON → AdminUser (fromJson)
// - Conversion AdminUser → JSON (toJson)
// - Conversion AdminUser → AdminUserModel (fromEntity)
// - Conversion AdminUserModel → AdminUser (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_user.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [AdminUser].
///
/// Cette classe étend [AdminUser] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
class AdminUserModel extends AdminUser {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    super.firstName,
    super.lastName,
    super.phone,
    super.birthDate,
    super.gender,
    super.country,
    super.city,
    super.address,
    super.language,
    super.currency,
    super.roles,
    super.permissions,
    super.status,
    super.isActive,
    super.isVerified,
    super.totalOrders,
    super.totalSpent,
    super.favoritesCount,
    super.reviewsCount,
    super.lastLoginAt,
    super.lastActivityAt,
    super.newsletterSubscribed,
    super.smsNotifications,
    super.pushNotifications,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
  factory AdminUserModel.fromEntity(AdminUser entity) {
    return AdminUserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatar,
      emailVerifiedAt: entity.emailVerifiedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      birthDate: entity.birthDate,
      gender: entity.gender,
      country: entity.country,
      city: entity.city,
      address: entity.address,
      language: entity.language,
      currency: entity.currency,
      roles: entity.roles,
      permissions: entity.permissions,
      status: entity.status,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
      totalOrders: entity.totalOrders,
      totalSpent: entity.totalSpent,
      favoritesCount: entity.favoritesCount,
      reviewsCount: entity.reviewsCount,
      lastLoginAt: entity.lastLoginAt,
      lastActivityAt: entity.lastActivityAt,
      newsletterSubscribed: entity.newsletterSubscribed,
      smsNotifications: entity.smsNotifications,
      pushNotifications: entity.pushNotifications,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées.
  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    // Parse du profil si présent
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    // Parse des rôles
    final roles = _parseRoles(json['roles']);

    // Parse des permissions
    final permissions = _parsePermissions(json['permissions']);

    // Parse des statistiques
    final stats = json['stats'] as Map<String, dynamic>? ?? {};

    return AdminUserModel(
      // Informations de base
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),

      // Profil
      firstName: profile['first_name'] as String?,
      lastName: profile['last_name'] as String?,
      phone: profile['phone'] as String?,
      birthDate: profile['birth_date'] != null
          ? DateTime.tryParse(profile['birth_date'] as String)
          : null,
      gender: profile['gender'] as String?,
      country: profile['country'] as String?,
      city: profile['city'] as String?,
      address: profile['address'] as String?,
      language: profile['language'] as String? ?? 'fr',
      currency: profile['currency'] as String? ?? 'FCFA',

      // Rôles et permissions
      roles: roles,
      permissions: permissions,

      // Statut
      status: AdminUserStatus.fromCode(json['status'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? (json['email_verified_at'] != null),

      // Statistiques
      totalOrders: (stats['total_orders'] as num?)?.toInt() ?? (json['total_orders'] as num?)?.toInt() ?? 0,
      totalSpent: (stats['total_spent'] as num?)?.toDouble() ?? (json['total_spent'] as num?)?.toDouble() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,

      // Activité
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.tryParse(json['last_activity_at'] as String)
          : null,

      // Préférences de notification
      newsletterSubscribed: profile['newsletter_subscribed'] as bool? ?? true,
      smsNotifications: profile['sms_notifications'] as bool? ?? true,
      pushNotifications: profile['push_notifications'] as bool? ?? true,
    );
  }

  // ============================================
  // CONVERSION : MODÈLE → JSON
  // ============================================

  /// Convertit le modèle en Map JSON.
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'country': country,
      'city': city,
      'address': address,
      'language': language,
      'currency': currency,
      'roles': roles.map((r) => r.code).toList(),
      'permissions': permissions,
      'status': status.code,
      'is_active': isActive,
      'is_verified': isVerified,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'favorites_count': favoritesCount,
      'reviews_count': reviewsCount,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'newsletter_subscribed': newsletterSubscribed,
      'sms_notifications': smsNotifications,
      'push_notifications': pushNotifications,
    };
  }

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
  AdminUser toEntity() {
    return AdminUser(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      birthDate: birthDate,
      gender: gender,
      country: country,
      city: city,
      address: address,
      language: language,
      currency: currency,
      roles: roles,
      permissions: permissions,
      status: status,
      isActive: isActive,
      isVerified: isVerified,
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      favoritesCount: favoritesCount,
      reviewsCount: reviewsCount,
      lastLoginAt: lastLoginAt,
      lastActivityAt: lastActivityAt,
      newsletterSubscribed: newsletterSubscribed,
      smsNotifications: smsNotifications,
      pushNotifications: pushNotifications,
    );
  }

  // ============================================
  // HELPERS PRIVÉS DE PARSING
  // ============================================

  /// Parse les rôles depuis le JSON.
  ///
  /// Gère les formats :
  /// - Liste de strings : ['admin', 'seller']
  /// - Liste de maps : [{'name': 'admin'}, ...]
  /// - Liste d'objets avec code : [{'code': 'admin'}, ...]
  static List<AdminUserRole> _parseRoles(dynamic data) {
    if (data == null) return const [AdminUserRole.client];
    if (data is! List) return const [AdminUserRole.client];
    if (data.isEmpty) return const [AdminUserRole.client];

    final roles = <AdminUserRole>[];

    for (final item in data) {
      if (item is String) {
        roles.add(AdminUserRole.fromCode(item));
      } else if (item is Map) {
        final name = item['name'] as String? ?? item['code'] as String?;
        if (name != null) {
          roles.add(AdminUserRole.fromCode(name));
        }
      }
    }

    return roles.isEmpty ? const [AdminUserRole.client] : roles;
  }

  /// Parse les permissions depuis le JSON.
  ///
  /// Gère les formats :
  /// - Liste de strings : ['create_product', 'delete_user']
  /// - Liste de maps : [{'name': 'create_product'}, ...]
  static List<String> _parsePermissions(dynamic data) {
    if (data == null) return const [];
    if (data is! List) return const [];

    final permissions = <String>[];

    for (final item in data) {
      if (item is String) {
        permissions.add(item);
      } else if (item is Map) {
        final name = item['name'] as String?;
        if (name != null) {
          permissions.add(name);
        }
      }
    }

    return permissions;
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
  @override
  AdminUserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? country,
    String? city,
    String? address,
    String? language,
    String? currency,
    List<AdminUserRole>? roles,
    List<String>? permissions,
    AdminUserStatus? status,
    bool? isActive,
    bool? isVerified,
    int? totalOrders,
    double? totalSpent,
    int? favoritesCount,
    int? reviewsCount,
    DateTime? lastLoginAt,
    DateTime? lastActivityAt,
    bool? newsletterSubscribed,
    bool? smsNotifications,
    bool? pushNotifications,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      newsletterSubscribed: newsletterSubscribed ?? this.newsletterSubscribed,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminUserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => Object.hash(id, email);

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminUserModel(id: $id, name: $fullName, email: $email, '
        'roles: $rolesCount, status: ${status.displayName}, '
        'orders: $totalOrders, spent: $totalSpentFormatted)';
  }
}