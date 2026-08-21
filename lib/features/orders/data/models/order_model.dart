// Modèle Order (Data)
// Gère la sérialisation/désérialisation JSON de la commande

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
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      items: _parseItems(json['items']),
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      couponDiscount: _parseDouble(json['coupon_discount']),
      shippingFee: _parseDouble(json['shipping_fee']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      shippingMethod: json['shipping_method'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      estimatedDeliveryDate: DateTime.tryParse(json['estimated_delivery_date'] as String? ?? ''),
      shippedAt: DateTime.tryParse(json['shipped_at'] as String? ?? ''),
      deliveredAt: DateTime.tryParse(json['delivered_at'] as String? ?? ''),
      couponCode: json['coupon_code'] as String?,
      customerNote: json['customer_note'] as String?,
      adminNote: json['admin_note'] as String?,
      currency: json['currency'] as String? ?? 'FCFA',
      cancelledAt: DateTime.tryParse(json['cancelled_at'] as String? ?? ''),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
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

  /// Parser les items
  static List<OrderItem> _parseItems(dynamic itemsJson) {
    if (itemsJson == null || itemsJson is! List) {
      return [];
    }

    final items = <OrderItem>[];

    for (final itemJson in itemsJson) {
      if (itemJson is Map<String, dynamic>) {
        items.add(OrderItemModel.fromJson(itemJson));
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