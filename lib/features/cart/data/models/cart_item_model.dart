// Modèle CartItem (Data)
// Gère la sérialisation/désérialisation JSON de l'élément du panier

import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.name,
    super.imageUrl,
    required super.sku,
    required super.unitPrice,
    super.discountPrice,
    super.quantity,
    super.maxQuantity,
    super.stock,
    super.isSavedForLater,
    super.variantName,
    super.variantColor,
    super.variantSize,
  });

  /// Créer depuis JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      sku: json['sku'] as String? ?? '',
      unitPrice: _parseDouble(json['unit_price']),
      discountPrice: _parseNullableDouble(json['discount_price']),
      quantity: json['quantity'] as int? ?? 1,
      maxQuantity: json['max_quantity'] as int? ?? 99,
      stock: json['stock'] as int? ?? 0,
      isSavedForLater: json['is_saved_for_later'] as bool? ?? false,
      variantName: json['variant_name'] as String?,
      variantColor: json['variant_color'] as String?,
      variantSize: json['variant_size'] as String?,
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'sku': sku,
      'unit_price': unitPrice,
      'discount_price': discountPrice,
      'quantity': quantity,
      'max_quantity': maxQuantity,
      'stock': stock,
      'is_saved_for_later': isSavedForLater,
      'variant_name': variantName,
      'variant_color': variantColor,
      'variant_size': variantSize,
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