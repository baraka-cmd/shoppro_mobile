// ============================================
// MODÈLE LEGAL DOCUMENT (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/legal_document.dart';

class LegalDocumentModel extends LegalDocument {
  const LegalDocumentModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.type,
    required super.content,
    super.version,
    super.publishedAt,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  /// Créer depuis JSON
  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: _parseInt(json['id']),
      title: _parseString(json['title']),
      slug: _parseString(json['slug']),
      type: _parseString(json['type'], defaultValue: 'other'),
      content: _parseString(json['content']),
      version: _parseString(json['version'], defaultValue: '1.0.0'),
      publishedAt: _parseDate(json['published_at']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'type': type,
      'content': content,
      'version': version,
      'published_at': publishedAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static LegalDocumentModel fromEntity(LegalDocument document) {
    return LegalDocumentModel(
      id: document.id,
      title: document.title,
      slug: document.slug,
      type: document.type,
      content: document.content,
      version: document.version,
      publishedAt: document.publishedAt,
      isActive: document.isActive,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
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

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    final string = value.toString().trim();
    return string.isEmpty ? defaultValue : string;
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