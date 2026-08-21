// Modèle Brand (Data)
// Gère la sérialisation/désérialisation JSON de la marque

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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      
      // Images
      logo: json['logo'] as String?,
      banner: json['banner'] as String?,
      
      // Contact
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      
      // Origine
      country: json['country'] as String?,
      
      // Statistiques
      productsCount: json['products_count'] as int? ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      
      // Statut
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      
      // Dates
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
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

  /// Parser un double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}