// ============================================
// MODÈLE ORDER ITEM (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

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
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      productName: _parseString(json['product_name']),
      productImage: _parseNullableString(json['product_image']),
      productSku: _parseString(json['product_sku']),
      unitPrice: _parseDouble(json['unit_price']),
      discountPrice: _parseNullableDouble(json['discount_price']),
      quantity: _parseInt(json['quantity'], defaultValue: 1),
      variantName: _parseNullableString(json['variant_name']),
      variantColor: _parseNullableString(json['variant_color']),
      variantSize: _parseNullableString(json['variant_size']),
      itemStatus: _parseString(json['item_status'], defaultValue: 'pending'),
      isReturned: _parseBool(json['is_returned']),
      returnDate: _parseDate(json['return_date']),
      returnReason: _parseNullableString(json['return_reason']),
      isRefunded: _parseBool(json['is_refunded']),
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

  /// Copier depuis l'entité
  static OrderItemModel fromEntity(OrderItem item) {
    return OrderItemModel(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      productImage: item.productImage,
      productSku: item.productSku,
      unitPrice: item.unitPrice,
      discountPrice: item.discountPrice,
      quantity: item.quantity,
      variantName: item.variantName,
      variantColor: item.variantColor,
      variantSize: item.variantSize,
      itemStatus: item.itemStatus,
      isReturned: item.isReturned,
      returnDate: item.returnDate,
      returnReason: item.returnReason,
      isRefunded: item.isRefunded,
      refundAmount: item.refundAmount,
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}