// Modèle Favorite (Data)
// Gère la sérialisation/désérialisation JSON du favori

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
    required super.addedAt,
    super.priceAlert,
    super.priceAlertThreshold,
    super.collectionName,
    super.note,
  });

  /// Créer depuis JSON
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String?,
      productSku: json['product_sku'] as String? ?? '',
      productPrice: _parseDouble(json['product_price']),
      productDiscountPrice: _parseNullableDouble(json['product_discount_price']),
      isInStock: json['is_in_stock'] as bool? ?? true,
      stock: json['stock'] as int? ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      addedAt: DateTime.tryParse(json['added_at'] as String? ?? '') ?? DateTime.now(),
      priceAlert: json['price_alert'] as bool? ?? false,
      priceAlertThreshold: _parseNullableDouble(json['price_alert_threshold']),
      collectionName: json['collection_name'] as String?,
      note: json['note'] as String?,
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
      'added_at': addedAt.toIso8601String(),
      'price_alert': priceAlert,
      'price_alert_threshold': priceAlertThreshold,
      'collection_name': collectionName,
      'note': note,
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

  /// Parser un double nullable
  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}