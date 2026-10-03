// ============================================
// MODÈLE ORDER (DATA) - VERSION PREMIUM
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste de :
// - Items
// - User (client)
// - Shipping address
// - Billing address
// ============================================

import 'package:flutter/foundation.dart';

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
    super.user,
    super.shippingAddress,
    super.billingAddress,
  });

  // ============================================
  // FROM JSON
  // ============================================

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // ✅ Parser les items
    final items = _parseItems(json['items']);

    // ✅ Parser l'utilisateur
    final user = _parseUser(json['user']);

    // ✅ Parser l'adresse de livraison
    final shippingAddress = _parseAddress(json['shipping_address']);

    // ✅ Parser l'adresse de facturation
    final billingAddress = _parseAddress(json['billing_address']);

    // ⚠️ DEBUG (à retirer plus tard)
    debugPrint('═══════════════════════════════════════');
    debugPrint('📦 Parsing Order #${json['id']}');
    debugPrint('👤 User : ${user?.name ?? 'NULL'}');
    debugPrint('📍 Shipping : ${shippingAddress?.city ?? 'NULL'}');
    debugPrint('🏢 Billing : ${billingAddress?.city ?? 'NULL'}');
    debugPrint('📦 Items : ${items.length}');
    debugPrint('═══════════════════════════════════════');

    return OrderModel(
      id: _parseInt(json['id']),
      orderNumber: _parseString(json['order_number']),
      items: items,
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      couponDiscount: _parseDouble(json['coupon_discount']),
      shippingFee: _parseDouble(json['shipping_fee']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      status: _parseString(json['status'], defaultValue: 'pending'),
      paymentStatus:
          _parseString(json['payment_status'], defaultValue: 'pending'),
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

      // ✅ NOUVEAU : user + adresses
      user: user,
      shippingAddress: shippingAddress,
      billingAddress: billingAddress,
    );
  }

  // ============================================
  // TO JSON
  // ============================================

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

      // ✅ NOUVEAU
      'user': user?.toJson(),
      'shipping_address': shippingAddress?.toJson(),
      'billing_address': billingAddress?.toJson(),
    };
  }

  // ============================================
  // FROM ENTITY
  // ============================================

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
      user: order.user,
      shippingAddress: order.shippingAddress,
      billingAddress: order.billingAddress,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  /// Parser la liste des items.
  static List<OrderItem> _parseItems(dynamic itemsJson) {
    if (itemsJson is! List) return [];

    return itemsJson
        .whereType<Map>()
        .map((itemJson) => OrderItemModel.fromJson(
              Map<String, dynamic>.from(itemJson),
            ))
        .toList();
  }

  /// Parser l'utilisateur.
  static OrderUser? _parseUser(dynamic userJson) {
    if (userJson == null) return null;
    if (userJson is! Map) return null;

    try {
      return OrderUser.fromJson(Map<String, dynamic>.from(userJson));
    } catch (e) {
      debugPrint('❌ Erreur parse user: $e');
      return null;
    }
  }

  /// Parser une adresse (livraison ou facturation).
  static OrderAddress? _parseAddress(dynamic addressJson) {
    if (addressJson == null) return null;
    if (addressJson is! Map) return null;

    try {
      return OrderAddress.fromJson(
        Map<String, dynamic>.from(addressJson),
      );
    } catch (e) {
      debugPrint('❌ Erreur parse address: $e');
      return null;
    }
  }

  // ============================================
  // HELPERS DE CONVERSION
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