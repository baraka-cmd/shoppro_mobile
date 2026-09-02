// ============================================
// MODÈLE CART ITEM (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

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
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      name: _parseString(json['name']),
      imageUrl: _parseNullableString(json['image_url']),
      sku: _parseString(json['sku']),
      unitPrice: _parseDouble(json['unit_price']),
      discountPrice: _parseNullableDouble(json['discount_price']),
      quantity: _parseInt(json['quantity'], defaultValue: 1),
      maxQuantity: _parseInt(json['max_quantity'], defaultValue: 99),
      stock: _parseInt(json['stock']),
      isSavedForLater: _parseBool(json['is_saved_for_later']),
      variantName: _parseNullableString(json['variant_name']),
      variantColor: _parseNullableString(json['variant_color']),
      variantSize: _parseNullableString(json['variant_size']),
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

  /// Copier depuis l'entité
  static CartItemModel fromEntity(CartItem item) {
    return CartItemModel(
      id: item.id,
      productId: item.productId,
      name: item.name,
      imageUrl: item.imageUrl,
      sku: item.sku,
      unitPrice: item.unitPrice,
      discountPrice: item.discountPrice,
      quantity: item.quantity,
      maxQuantity: item.maxQuantity,
      stock: item.stock,
      isSavedForLater: item.isSavedForLater,
      variantName: item.variantName,
      variantColor: item.variantColor,
      variantSize: item.variantSize,
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

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}