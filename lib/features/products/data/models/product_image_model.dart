// ============================================
// MODÈLE PRODUCT IMAGE (DATA)
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec support des angles pour l'effet 360°.
// ============================================

import '../../domain/entities/product_image.dart';

class ProductImageModel extends ProductImage {
  const ProductImageModel({
    required super.id,
    required super.url,
    super.thumbnail,
    super.isPrimary,
    super.position,
    super.angle,
    super.caption,
    super.width,
    super.height,
    super.type,
  });

  /// Créer un ProductImageModel depuis JSON
  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: _parseInt(json['id']),
      url: _parseString(json['url']),
      thumbnail: _parseNullableString(json['thumbnail']),
      isPrimary: _parseBool(json['is_primary']),
      position: _parseInt(json['position']),
      angle: _parseNullableString(json['angle']),
      caption: _parseNullableString(json['caption']),
      width: _parseNullableInt(json['width']),
      height: _parseNullableInt(json['height']),
      type: _parseString(json['type'], defaultValue: 'image'),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail': thumbnail,
      'is_primary': isPrimary,
      'position': position,
      'angle': angle,
      'caption': caption,
      'width': width,
      'height': height,
      'type': type,
    };
  }

  /// Copier depuis l'entité
  static ProductImageModel fromEntity(ProductImage image) {
    return ProductImageModel(
      id: image.id,
      url: image.url,
      thumbnail: image.thumbnail,
      isPrimary: image.isPrimary,
      position: image.position,
      angle: image.angle,
      caption: image.caption,
      width: image.width,
      height: image.height,
      type: image.type,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    final string = value.toString().trim();
    return string.isEmpty ? defaultValue : string;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}