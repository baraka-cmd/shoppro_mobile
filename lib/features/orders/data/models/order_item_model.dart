// Modèle OrderItem (Data)
// Gère la sérialisation/désérialisation JSON de l'élément de commande

import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImage,
    required super.productSku,
    required super.unitPrice,
    super.discountPrice,
    super.quantity,
    super.variantName,
    super.variantColor,
    super.variantSize,
    super.itemStatus,
    super.isReturned,
    super.returnDate,
    super.returnReason,
    super.isRefunded,
    super.refundAmount,
  });

  /// Créer depuis JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String?,
      productSku: json['product_sku'] as String? ?? '',
      unitPrice: _parseDouble(json['unit_price']),
      discountPrice: _parseNullableDouble(json['discount_price']),
      quantity: json['quantity'] as int? ?? 1,
      variantName: json['variant_name'] as String?,
      variantColor: json['variant_color'] as String?,
      variantSize: json['variant_size'] as String?,
      itemStatus: json['item_status'] as String? ?? 'pending',
      isReturned: json['is_returned'] as bool? ?? false,
      returnDate: DateTime.tryParse(json['return_date'] as String? ?? ''),
      returnReason: json['return_reason'] as String?,
      isRefunded: json['is_refunded'] as bool? ?? false,
      refundAmount: _parseNullableDouble(json['refund_amount']),
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
      'unit_price': unitPrice,
      'discount_price': discountPrice,
      'quantity': quantity,
      'variant_name': variantName,
      'variant_color': variantColor,
      'variant_size': variantSize,
      'item_status': itemStatus,
      'is_returned': isReturned,
      'return_date': returnDate?.toIso8601String(),
      'return_reason': returnReason,
      'is_refunded': isRefunded,
      'refund_amount': refundAmount,
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