// ============================================
// MODÈLE ORDER (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et valeurs par défaut.
// ============================================

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.items,
    super.subtotal,
    super.discount,
    super.couponDiscount,
    super.shippingFee,
    super.tax,
    required super.total,
    super.status,
    super.paymentStatus,
    super.shippingMethod,
    super.trackingNumber,
    super.estimatedDeliveryDate,
    super.shippedAt,
    super.deliveredAt,
    super.couponCode,
    super.customerNote,
    super.adminNote,
    super.currency,
    super.cancelledAt,
    super.cancellationReason,
    required super.createdAt,
  });

  /// Créer depuis JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: _parseInt(json['id']),
      orderNumber: _parseString(json['order_number']),
      items: _parseItems(json['items']),
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      couponDiscount: _parseDouble(json['coupon_discount']),
      shippingFee: _parseDouble(json['shipping_fee']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: _parseString(json['status'], defaultValue: 'pending'),
      paymentStatus: _parseString(json['payment_status'], defaultValue: 'pending'),
      shippingMethod: _parseNullableString(json['shipping_method']),
      trackingNumber: _parseNullableString(json['tracking_number']),
      estimatedDeliveryDate: _parseDate(json['estimated_delivery_date']),
      shippedAt: _parseDate(json['shipped_at']),
      deliveredAt: _parseDate(json['delivered_at']),
      couponCode: _parseNullableString(json['coupon_code']),
      customerNote: _parseNullableString(json['customer_note']),
      adminNote: _parseNullableString(json['admin_note']),
      currency: _parseString(json['currency'], defaultValue: 'FCFA'),
      cancelledAt: _parseDate(json['cancelled_at']),
      cancellationReason: _parseNullableString(json['cancellation_reason']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'items': items
          .whereType<OrderItemModel>()
          .map((item) => item.toJson())
          .toList(),
      'subtotal': subtotal,
      'discount': discount,
      'coupon_discount': couponDiscount,
      'shipping_fee': shippingFee,
      'tax': tax,
      'total': total,
      'status': status,
      'payment_status': paymentStatus,
      'shipping_method': shippingMethod,
      'tracking_number': trackingNumber,
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'coupon_code': couponCode,
      'customer_note': customerNote,
      'admin_note': adminNote,
      'currency': currency,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static OrderModel fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      items: order.items
          .map((item) => OrderItemModel.fromEntity(item))
          .toList(),
      subtotal: order.subtotal,
      discount: order.discount,
      couponDiscount: order.couponDiscount,
      shippingFee: order.shippingFee,
      tax: order.tax,
      total: order.total,
      status: order.status,
      paymentStatus: order.paymentStatus,
      shippingMethod: order.shippingMethod,
      trackingNumber: order.trackingNumber,
      estimatedDeliveryDate: order.estimatedDeliveryDate,
      shippedAt: order.shippedAt,
      deliveredAt: order.deliveredAt,
      couponCode: order.couponCode,
      customerNote: order.customerNote,
      adminNote: order.adminNote,
      currency: order.currency,
      cancelledAt: order.cancelledAt,
      cancellationReason: order.cancellationReason,
      createdAt: order.createdAt,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static List<OrderItem> _parseItems(dynamic itemsJson) {
    if (itemsJson is! List) return [];

    return itemsJson
        .whereType<Map<String, dynamic>>()
        .map((itemJson) => OrderItemModel.fromJson(itemJson))
        .toList();
  }

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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}