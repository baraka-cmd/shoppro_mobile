// ============================================
// MODÈLE BRAND (DATA)
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec validation robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/brand.dart';

class BrandModel extends Brand {
  const BrandModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.logo,
    super.banner,
    super.website,
    super.email,
    super.phone,
    super.country,
    super.productsCount,
    super.averageRating,
    super.isActive,
    super.isFeatured,
    super.createdAt,
  });

  /// Créer un BrandModel depuis JSON
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      description: _parseNullableString(json['description']),

      // Images
      logo: _parseNullableString(json['logo']),
      banner: _parseNullableString(json['banner']),

      // Contact
      website: _parseNullableString(json['website']),
      email: _parseNullableString(json['email']),
      phone: _parseNullableString(json['phone']),

      // Origine
      country: _parseNullableString(json['country']),

      // Statistiques
      productsCount: _parseInt(json['products_count']),
      averageRating: _parseDouble(json['average_rating']),

      // Statut
      isActive: _parseBool(json['is_active'], defaultValue: true),
      isFeatured: _parseBool(json['is_featured'], defaultValue: false),

      // Dates
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logo': logo,
      'banner': banner,
      'website': website,
      'email': email,
      'phone': phone,
      'country': country,
      'products_count': productsCount,
      'average_rating': averageRating,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static BrandModel fromEntity(Brand brand) {
    return BrandModel(
      id: brand.id,
      name: brand.name,
      slug: brand.slug,
      description: brand.description,
      logo: brand.logo,
      banner: brand.banner,
      website: brand.website,
      email: brand.email,
      phone: brand.phone,
      country: brand.country,
      productsCount: brand.productsCount,
      averageRating: brand.averageRating,
      isActive: brand.isActive,
      isFeatured: brand.isFeatured,
      createdAt: brand.createdAt,
    );
  }

  // ============================================
  // HELPERS DE PARSING SÉCURISÉS
  // ============================================

  /// Parser un entier avec défaut 0
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Parser un double avec défaut 0
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Parser un booléen avec défaut
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  /// Parser une chaîne avec défaut vide
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  /// Parser une chaîne nullable
  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  /// Parser une date
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}