// ============================================
// MODEL : AdminSettingModel
// ============================================
// Modèle de sérialisation pour les paramètres de configuration.
// Cette classe est dans la couche DATA et gère la conversion
// JSON ↔ Entité (AdminSetting).
//
// Responsabilités :
// - Conversion JSON → AdminSetting (fromJson)
// - Conversion AdminSetting → JSON (toJson)
// - Conversion AdminSetting → AdminSettingModel (fromEntity)
// - Conversion AdminSettingModel → AdminSetting (toEntity)
// ============================================

// ============================================
// IMPORTS
// ============================================

// Dart
import 'dart:convert';

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_setting.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Modèle de données pour [AdminSetting].
///
/// Cette classe étend [AdminSetting] et ajoute les méthodes
/// de sérialisation JSON nécessaires pour l'API.
class AdminSettingModel extends AdminSetting {
  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminSettingModel({
    required super.id,
    required super.key,
    required super.value,
    required super.group,
    required super.type,
    super.description,
    super.isPublic,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  // ============================================
  // CONVERSION : ENTITÉ → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une entité.
  factory AdminSettingModel.fromEntity(AdminSetting entity) {
    return AdminSettingModel(
      id: entity.id,
      key: entity.key,
      value: entity.value,
      group: entity.group,
      type: entity.type,
      description: entity.description,
      isPublic: entity.isPublic,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ============================================
  // CONVERSION : JSON → MODÈLE
  // ============================================

  /// Crée un modèle à partir d'une Map JSON.
  ///
  /// Gère toutes les conversions de types sécurisées.
  factory AdminSettingModel.fromJson(Map<String, dynamic> json) {
    // Parse de la valeur selon le type
    final type = AdminSettingType.fromCode(json['type'] as String?);
    final rawValue = json['value'];
    final value = _parseValue(rawValue, type);

    return AdminSettingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      key: json['key'] as String? ?? '',
      value: value,
      group: AdminSettingGroup.fromCode(json['group'] as String?),
      type: type,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
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
      'key': key,
      'value': _serializeValue(value, type),
      'group': group.code,
      'type': type.code,
      'description': description,
      'is_public': isPublic,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ============================================
  // CONVERSION : MODÈLE → ENTITÉ
  // ============================================

  /// Convertit le modèle en entité pure.
  AdminSetting toEntity() {
    return AdminSetting(
      id: id,
      key: key,
      value: value,
      group: group,
      type: type,
      description: description,
      isPublic: isPublic,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ============================================
  // HELPERS DE PARSING DE VALEUR
  // ============================================

  /// Parse une valeur brute selon le type du paramètre.
  ///
  /// Gère les cas :
  /// - booléen : true/false → "true"/"false"
  /// - entier : 42 → "42"
  /// - décimal : 3.14 → "3.14"
  /// - JSON : {'key': 'value'} → '{"key":"value"}'
  /// - tableau : [1, 2, 3] → '[1,2,3]'
  /// - String : "texte" → "texte"
  static String _parseValue(dynamic rawValue, AdminSettingType type) {
    if (rawValue == null) return '';

    switch (type) {
      case AdminSettingType.boolean:
        return rawValue.toString();
      case AdminSettingType.integer:
        return rawValue.toString();
      case AdminSettingType.float:
        return rawValue.toString();
      case AdminSettingType.json:
        if (rawValue is Map) {
          return jsonEncode(rawValue);
        }
        return rawValue.toString();
      case AdminSettingType.array:
        if (rawValue is List) {
          return jsonEncode(rawValue);
        }
        return rawValue.toString();
      case AdminSettingType.file:
        return rawValue.toString();
      case AdminSettingType.string:
      default:
        return rawValue.toString();
    }
  }

  /// Sérialise une valeur selon le type du paramètre.
  ///
  /// Inverse de [_parseValue].
  static dynamic _serializeValue(String value, AdminSettingType type) {
    switch (type) {
      case AdminSettingType.boolean:
        return value.toLowerCase() == 'true' || value == '1';
      case AdminSettingType.integer:
        return int.tryParse(value) ?? 0;
      case AdminSettingType.float:
        return double.tryParse(value) ?? 0;
      case AdminSettingType.json:
        try {
          return jsonDecode(value);
        } catch (_) {
          return value;
        }
      case AdminSettingType.array:
        try {
          return jsonDecode(value);
        } catch (_) {
          return value;
        }
      case AdminSettingType.file:
      case AdminSettingType.string:
      default:
        return value;
    }
  }

  // ============================================
  // HELPERS DE CRÉATION
  // ============================================

  /// Crée un paramètre de type String.
  factory AdminSettingModel.createString({
    required String key,
    required String value,
    required AdminSettingGroup group,
    String? description,
    bool isPublic = false,
  }) {
    return AdminSettingModel(
      id: 0,
      key: key,
      value: value,
      group: group,
      type: AdminSettingType.string,
      description: description,
      isPublic: isPublic,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crée un paramètre de type booléen.
  factory AdminSettingModel.createBoolean({
    required String key,
    required bool value,
    required AdminSettingGroup group,
    String? description,
    bool isPublic = false,
  }) {
    return AdminSettingModel(
      id: 0,
      key: key,
      value: value.toString(),
      group: group,
      type: AdminSettingType.boolean,
      description: description,
      isPublic: isPublic,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crée un paramètre de type entier.
  factory AdminSettingModel.createInteger({
    required String key,
    required int value,
    required AdminSettingGroup group,
    String? description,
    bool isPublic = false,
  }) {
    return AdminSettingModel(
      id: 0,
      key: key,
      value: value.toString(),
      group: group,
      type: AdminSettingType.integer,
      description: description,
      isPublic: isPublic,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Crée un paramètre de type décimal.
  factory AdminSettingModel.createDouble({
    required String key,
    required double value,
    required AdminSettingGroup group,
    String? description,
    bool isPublic = false,
  }) {
    return AdminSettingModel(
      id: 0,
      key: key,
      value: value.toString(),
      group: group,
      type: AdminSettingType.float,
      description: description,
      isPublic: isPublic,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Vérifie si la clé est valide.
  bool get hasValidKey => key.trim().isNotEmpty;

  /// Vérifie si la valeur est valide pour le type.
  bool get hasValidValue {
    switch (type) {
      case AdminSettingType.boolean:
        return value.toLowerCase() == 'true' || value.toLowerCase() == 'false' || value == '1' || value == '0';
      case AdminSettingType.integer:
        return int.tryParse(value) != null;
      case AdminSettingType.float:
        return double.tryParse(value) != null;
      case AdminSettingType.json:
        try {
          jsonDecode(value);
          return true;
        } catch (_) {
          return false;
        }
      case AdminSettingType.array:
        try {
          final decoded = jsonDecode(value);
          return decoded is List;
        } catch (_) {
          return false;
        }
      case AdminSettingType.file:
      case AdminSettingType.string:
      default:
        return true;
    }
  }

  /// Vérifie si le paramètre est complet et valide.
  bool get isValid => hasValidKey && hasValidValue && isActive;

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés.
  @override
  AdminSettingModel copyWith({
    int? id,
    String? key,
    String? value,
    AdminSettingGroup? group,
    AdminSettingType? type,
    String? description,
    bool? isPublic,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminSettingModel(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      group: group ?? this.group,
      type: type ?? this.type,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminSettingModel && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminSettingModel(id: $id, key: $key, value: $displayValue, '
        'group: ${group.displayName}, type: ${type.displayName}, valid: $isValid)';
  }
}