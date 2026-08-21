// Modèle Cart (Data)
// Gère la sérialisation/désérialisation JSON du panier complet

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
      couponCode: json['coupon_code'] as String?,
      couponDiscount: _parseDouble(json['coupon_discount']),
      shippingFee: _parseDouble(json['shipping_fee']),
      taxRate: _parseDouble(json['tax_rate']),
      currency: json['currency'] as String? ?? 'FCFA',
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => (item as CartItemModel).toJson()).toList(),
      'coupon_code': couponCode,
      'coupon_discount': couponDiscount,
      'shipping_fee': shippingFee,
      'tax_rate': taxRate,
      'currency': currency,
    };
  }

  /// Parser les items
  static List<CartItem> _parseItems(dynamic itemsJson) {
    if (itemsJson == null || itemsJson is! List) {
      return [];
    }

    final items = <CartItem>[];

    for (final itemJson in itemsJson) {
      if (itemJson is Map<String, dynamic>) {
        items.add(CartItemModel.fromJson(itemJson));
      }
    }

    return items;
  }

  /// Parser un double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}