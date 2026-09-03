// ============================================
// ENTITÉ ORDER (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une commande complète avec timeline,
// statuts intelligents et formatage FCFA.
// Design ShopPro.
// ============================================

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

  // ============================================
  // COMPTEURS
  // ============================================

  /// Nombre total d'articles
  int get totalItems => items.length;

  /// Quantité totale
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// La commande a-t-elle des articles ?
  bool get hasItems => items.isNotEmpty;

  // ============================================
  // FORMATAGE
  // ============================================

  /// Total formaté
  String get formattedTotal => _formatPrice(total);

  /// Sous-total formaté
  String get formattedSubtotal => _formatPrice(subtotal);

  /// Remise formatée
  String get formattedDiscount => _formatPrice(discount + couponDiscount);

  /// Livraison formatée
  String get formattedShippingFee {
    if (shippingFee == 0) return 'Gratuite';
    return _formatPrice(shippingFee);
  }

  /// Taxes formatées
  String get formattedTax => _formatPrice(tax);

  // ============================================
  // STATUTS
  // ============================================

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

  /// Couleur du statut (hex)
  int get statusColorHex {
    switch (status) {
      case 'pending':
        return 0xFFF4B942; // Gold
      case 'confirmed':
        return 0xFF3B82F6; // Bleu
      case 'processing':
        return 0xFF9C27B0; // Violet
      case 'shipped':
        return 0xFF3B82F6; // Bleu
      case 'delivered':
        return 0xFF087F5B; // Emerald
      case 'cancelled':
        return 0xFFFF6B6B; // Coral
      case 'refunded':
        return 0xFF68756F; // Gris
      case 'returned':
        return 0xFF68756F; // Gris
      default:
        return 0xFF68756F;
    }
  }

  /// La commande est-elle active (en cours) ?
  bool get isActive {
    return status == 'pending' ||
        status == 'confirmed' ||
        status == 'processing' ||
        status == 'shipped';
  }

  /// La commande est-elle livrée ?
  bool get isDelivered => status == 'delivered';

  /// La commande est-elle annulée ?
  bool get isCancelled => status == 'cancelled';

  /// La commande peut-elle être annulée ?
  bool get canCancel {
    return status == 'pending' || status == 'confirmed';
  }

  /// La commande peut-elle être retournée ?
  bool get canReturn {
    return status == 'delivered';
  }

  /// La commande peut-elle être répétée ?
  bool get canReorder {
    return status == 'delivered' || status == 'cancelled';
  }

  // ============================================
  // PAIEMENT
  // ============================================

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

  /// Le paiement est-il effectué ?
  bool get isPaid => paymentStatus == 'paid';

  // ============================================
  // TIMELINE
  // ============================================

  /// Étapes de la timeline
  List<String> get timelineSteps {
    return [
      'Commande confirmée',
      'En préparation',
      'Expédiée',
      'En livraison',
      'Livrée',
    ];
  }

  /// Index de l'étape actuelle
  int get currentTimelineIndex {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return 0;
      case 'processing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 4;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  /// La livraison est-elle estimée ?
  bool get hasEstimatedDelivery => estimatedDeliveryDate != null;

  /// Date de livraison estimée formatée
  String get formattedEstimatedDelivery {
    if (estimatedDeliveryDate == null) return 'Non définie';
    return _formatDate(estimatedDeliveryDate!);
  }

  // ============================================
  // DATE
  // ============================================

  /// Date formatée relative
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
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    }
    return 'À l\'instant';
  }

  /// Date complète formatée
  String get formattedFullDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// La commande a-t-elle des données valides ?
  bool get isValid {
    return id > 0 &&
        orderNumber.isNotEmpty &&
        items.isNotEmpty &&
        total >= 0;
  }

  /// La commande a-t-elle un prix incohérent ?
  bool get hasPriceError {
    return total < 0;
  }

  // ============================================
  // FORMATAGE INTERNE
  // ============================================

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================
  // MÉTHODES
  // ============================================

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

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'Order(id: $id, number: $orderNumber, '
        'items: $totalItems, total: $formattedTotal, '
        'status: $statusLabel, payment: $paymentStatusLabel)';
  }
}