// ============================================
// MODÈLE CART (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_item_model.dart';

class CartModel extends Cart {
  const CartModel({
    super.items,
    super.couponCode,
    super.couponDiscount,
    super.shippingFee,
    super.taxRate,
    super.currency,
  });

  /// Créer depuis JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: _parseItems(json['items']),
      couponCode: _parseNullableString(json['coupon_code']),
      couponDiscount: _parseDouble(json['coupon_discount']),
      shippingFee: _parseDouble(json['shipping_fee'], defaultValue: 2000),
      taxRate: _parseDouble(json['tax_rate']),
      currency: _parseString(json['currency'], defaultValue: 'FCFA'),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items
          .whereType<CartItemModel>()
          .map((item) => item.toJson())
          .toList(),
      'coupon_code': couponCode,
      'coupon_discount': couponDiscount,
      'shipping_fee': shippingFee,
      'tax_rate': taxRate,
      'currency': currency,
    };
  }

  /// Copier depuis l'entité
  static CartModel fromEntity(Cart cart) {
    return CartModel(
      items: cart.items
          .map((item) => CartItemModel.fromEntity(item))
          .toList(),
      couponCode: cart.couponCode,
      couponDiscount: cart.couponDiscount,
      shippingFee: cart.shippingFee,
      taxRate: cart.taxRate,
      currency: cart.currency,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static List<CartItem> _parseItems(dynamic itemsJson) {
    if (itemsJson is! List) return [];

    return itemsJson
        .whereType<Map<String, dynamic>>()
        .map((itemJson) => CartItemModel.fromJson(itemJson))
        .toList();
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
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
}