// ============================================
// MODÈLE FAVORITE (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  const FavoriteModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImage,
    required super.productSku,
    required super.productPrice,
    super.productDiscountPrice,
    super.isInStock,
    super.stock,
    super.averageRating,
    super.reviewsCount,
    required super.addedAt,
    super.priceAlert,
    super.priceAlertThreshold,
    super.collectionName,
    super.note,
  });

  /// Créer depuis JSON
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      productName: _parseString(json['product_name']),
      productImage: _parseNullableString(json['product_image']),
      productSku: _parseString(json['product_sku']),
      productPrice: _parseDouble(json['product_price']),
      productDiscountPrice: _parseNullableDouble(json['product_discount_price']),
      isInStock: _parseBool(json['is_in_stock'], defaultValue: true),
      stock: _parseInt(json['stock']),
      averageRating: _parseDouble(json['average_rating']),
      reviewsCount: _parseInt(json['reviews_count']),
      addedAt: _parseDate(json['added_at']),
      priceAlert: _parseBool(json['price_alert']),
      priceAlertThreshold: _parseNullableDouble(json['price_alert_threshold']),
      collectionName: _parseNullableString(json['collection_name']),
      note: _parseNullableString(json['note']),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'product_sku': productSku,
      'product_price': productPrice,
      'product_discount_price': productDiscountPrice,
      'is_in_stock': isInStock,
      'stock': stock,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'added_at': addedAt.toIso8601String(),
      'price_alert': priceAlert,
      'price_alert_threshold': priceAlertThreshold,
      'collection_name': collectionName,
      'note': note,
    };
  }

  /// Copier depuis l'entité
  static FavoriteModel fromEntity(Favorite favorite) {
    return FavoriteModel(
      id: favorite.id,
      productId: favorite.productId,
      productName: favorite.productName,
      productImage: favorite.productImage,
      productSku: favorite.productSku,
      productPrice: favorite.productPrice,
      productDiscountPrice: favorite.productDiscountPrice,
      isInStock: favorite.isInStock,
      stock: favorite.stock,
      averageRating: favorite.averageRating,
      reviewsCount: favorite.reviewsCount,
      addedAt: favorite.addedAt,
      priceAlert: favorite.priceAlert,
      priceAlertThreshold: favorite.priceAlertThreshold,
      collectionName: favorite.collectionName,
      note: favorite.note,
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

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
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

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}