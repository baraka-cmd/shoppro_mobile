// ============================================
// MODÈLE FAQ CATEGORY (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/faq_category.dart';

class FaqCategoryModel extends FaqCategory {
  const FaqCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.icon,
    super.description,
    super.sortOrder,
    super.isActive,
    super.faqsCount,
    super.createdAt,
    super.updatedAt,
  });

  /// Créer depuis JSON
  factory FaqCategoryModel.fromJson(Map<String, dynamic> json) {
    return FaqCategoryModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      icon: _parseNullableString(json['icon']),
      description: _parseNullableString(json['description']),
      sortOrder: _parseInt(json['sort_order']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      faqsCount: _parseInt(json['faqs_count']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'sort_order': sortOrder,
      'is_active': isActive,
      'faqs_count': faqsCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static FaqCategoryModel fromEntity(FaqCategory category) {
    return FaqCategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      icon: category.icon,
      description: category.description,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
      faqsCount: category.faqsCount,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}