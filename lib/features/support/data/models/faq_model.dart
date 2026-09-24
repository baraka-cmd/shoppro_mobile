// ============================================
// MODÈLE FAQ (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/faq.dart';

class FaqModel extends Faq {
  const FaqModel({
    required super.id,
    super.faqCategoryId,
    required super.question,
    required super.answer,
    required super.slug,
    super.isActive,
    super.isPopular,
    super.sortOrder,
    super.viewsCount,
    super.helpfulCount,
    super.createdAt,
    super.updatedAt,
  });

  /// Créer depuis JSON
  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: _parseInt(json['id']),
      faqCategoryId: _parseNullableInt(json['faq_category_id']),
      question: _parseString(json['question']),
      answer: _parseString(json['answer']),
      slug: _parseString(json['slug']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      isPopular: _parseBool(json['is_popular']),
      sortOrder: _parseInt(json['sort_order']),
      viewsCount: _parseInt(json['views_count']),
      helpfulCount: _parseInt(json['helpful_count']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faq_category_id': faqCategoryId,
      'question': question,
      'answer': answer,
      'slug': slug,
      'is_active': isActive,
      'is_popular': isPopular,
      'sort_order': sortOrder,
      'views_count': viewsCount,
      'helpful_count': helpfulCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static FaqModel fromEntity(Faq faq) {
    return FaqModel(
      id: faq.id,
      faqCategoryId: faq.faqCategoryId,
      question: faq.question,
      answer: faq.answer,
      slug: faq.slug,
      isActive: faq.isActive,
      isPopular: faq.isPopular,
      sortOrder: faq.sortOrder,
      viewsCount: faq.viewsCount,
      helpfulCount: faq.helpfulCount,
      createdAt: faq.createdAt,
      updatedAt: faq.updatedAt,
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

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
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