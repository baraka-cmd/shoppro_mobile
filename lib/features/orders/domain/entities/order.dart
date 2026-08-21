// Entité Order (Domaine)
// Représente une commande complète

import 'order_item.dart';

class Order {
  final int id;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double couponDiscount;
  final double shippingFee;
  final double tax;
  final double total;
  final String status;
  final String paymentStatus;
  final String? shippingMethod;
  final String? trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? couponCode;
  final String? customerNote;
  final String? adminNote;
  final String currency;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    this.subtotal = 0,
    this.discount = 0,
    this.couponDiscount = 0,
    this.shippingFee = 0,
    this.tax = 0,
    required this.total,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.shippingMethod,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.shippedAt,
    this.deliveredAt,
    this.couponCode,
    this.customerNote,
    this.adminNote,
    this.currency = 'FCFA',
    this.cancelledAt,
    this.cancellationReason,
    required this.createdAt,
  });

  /// Nombre total d'articles
  int get totalItems => items.length;

  /// Quantité totale
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Total formaté
  String get formattedTotal => _formatPrice(total);

  /// Sous-total formaté
  String get formattedSubtotal => _formatPrice(subtotal);

  /// Livraison formatée
  String get formattedShippingFee {
    if (shippingFee == 0) return 'Gratuite';
    return _formatPrice(shippingFee);
  }

  /// Statut formaté
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'processing':
        return 'En préparation';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      case 'refunded':
        return 'Remboursée';
      case 'returned':
        return 'Retournée';
      default:
        return status;
    }
  }

  /// Couleur du statut
  int get statusColor {
    switch (status) {
      case 'pending':
        return 0xFFF39C12;
      case 'confirmed':
        return 0xFF3498DB;
      case 'processing':
        return 0xFF9C27B0;
      case 'shipped':
        return 0xFF3498DB;
      case 'delivered':
        return 0xFF27AE60;
      case 'cancelled':
        return 0xFFE74C3C;
      case 'refunded':
        return 0xFF7F8C8D;
      case 'returned':
        return 0xFF7F8C8D;
      default:
        return 0xFF7F8C8D;
    }
  }

  /// Statut de paiement formaté
  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'pending':
        return 'En attente';
      case 'paid':
        return 'Payée';
      case 'failed':
        return 'Échouée';
      case 'refunded':
        return 'Remboursée';
      case 'partially_refunded':
        return 'Partiellement remboursée';
      default:
        return paymentStatus;
    }
  }

  /// La commande peut-elle être annulée ?
  bool get canCancel {
    return status == 'pending' || status == 'confirmed';
  }

  /// La commande peut-elle être retournée ?
  bool get canReturn {
    return status == 'delivered';
  }

  /// Date formatée
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} an(s)';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mois';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} jour(s)';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} heure(s)';
    }
    return 'À l\'instant';
  }

  /// Formater un prix
  String _formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer $currency';
  }

  /// Copier avec modifications
  Order copyWith({
    int? id,
    String? orderNumber,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? couponDiscount,
    double? shippingFee,
    double? tax,
    double? total,
    String? status,
    String? paymentStatus,
    String? shippingMethod,
    String? trackingNumber,
    DateTime? estimatedDeliveryDate,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? couponCode,
    String? customerNote,
    String? adminNote,
    String? currency,
    DateTime? cancelledAt,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      couponCode: couponCode ?? this.couponCode,
      customerNote: customerNote ?? this.customerNote,
      adminNote: adminNote ?? this.adminNote,
      currency: currency ?? this.currency,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertir en JSON
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

  /// Créer depuis JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((itemJson) => OrderItem.fromJson(itemJson))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      couponDiscount: (json['coupon_discount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
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
}