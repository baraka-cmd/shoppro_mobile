// ============================================
// ENTITÉ ORDER (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente une commande complète avec :
// - Utilisateur (client)
// - Adresses (livraison + facturation)
// - Articles
// - Timeline et statuts
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

  // ✅ NOUVEAUX CHAMPS
  final OrderUser? user;
  final OrderAddress? shippingAddress;
  final OrderAddress? billingAddress;

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
    this.user,
    this.shippingAddress,
    this.billingAddress,
  });

  // ============================================
  // COMPTEURS
  // ============================================

  int get totalItems => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  bool get hasItems => items.isNotEmpty;

  // ============================================
  // FORMATAGE
  // ============================================

  String get formattedTotal => _formatPrice(total);
  String get formattedSubtotal => _formatPrice(subtotal);
  String get formattedDiscount => _formatPrice(discount + couponDiscount);
  String get formattedShippingFee {
    if (shippingFee == 0) return 'Gratuite';
    return _formatPrice(shippingFee);
  }
  String get formattedTax => _formatPrice(tax);

  // ============================================
  // STATUTS
  // ============================================

  String get statusLabel {
    switch (status) {
      case 'pending': return 'En attente';
      case 'confirmed': return 'Confirmée';
      case 'processing': return 'En préparation';
      case 'shipped': return 'Expédiée';
      case 'delivered': return 'Livrée';
      case 'cancelled': return 'Annulée';
      case 'refunded': return 'Remboursée';
      case 'returned': return 'Retournée';
      default: return status;
    }
  }

  int get statusColorHex {
    switch (status) {
      case 'pending': return 0xFFF4B942;
      case 'confirmed': return 0xFF3B82F6;
      case 'processing': return 0xFF9C27B0;
      case 'shipped': return 0xFF3B82F6;
      case 'delivered': return 0xFF087F5B;
      case 'cancelled': return 0xFFFF6B6B;
      case 'refunded': return 0xFF68756F;
      case 'returned': return 0xFF68756F;
      default: return 0xFF68756F;
    }
  }

  bool get isActive => status == 'pending' || status == 'confirmed' || status == 'processing' || status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => status == 'pending' || status == 'confirmed';
  bool get canReturn => status == 'delivered';
  bool get canReorder => status == 'delivered' || status == 'cancelled';

  // ============================================
  // PAIEMENT
  // ============================================

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case 'pending': return 'En attente';
      case 'paid': return 'Payée';
      case 'failed': return 'Échouée';
      case 'refunded': return 'Remboursée';
      case 'partially_refunded': return 'Partiellement remboursée';
      default: return paymentStatus;
    }
  }

  bool get isPaid => paymentStatus == 'paid';

  // ============================================
  // TIMELINE
  // ============================================

  List<String> get timelineSteps {
    return ['Commande confirmée', 'En préparation', 'Expédiée', 'En livraison', 'Livrée'];
  }

  int get currentTimelineIndex {
    switch (status) {
      case 'pending':
      case 'confirmed': return 0;
      case 'processing': return 1;
      case 'shipped': return 2;
      case 'delivered': return 4;
      case 'cancelled': return -1;
      default: return 0;
    }
  }

  bool get hasEstimatedDelivery => estimatedDeliveryDate != null;

  String get formattedEstimatedDelivery {
    if (estimatedDeliveryDate == null) return 'Non définie';
    return _formatDate(estimatedDeliveryDate!);
  }

  // ============================================
  // DATE
  // ============================================

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()} an(s)';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} mois';
    if (difference.inDays > 0) return '${difference.inDays} jour(s)';
    if (difference.inHours > 0) return '${difference.inHours} heure(s)';
    if (difference.inMinutes > 0) return '${difference.inMinutes} min';
    return 'À l\'instant';
  }

  String get formattedFullDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // ============================================
  // VALIDATION
  // ============================================

  bool get isValid => id > 0 && orderNumber.isNotEmpty && items.isNotEmpty && total >= 0;
  bool get hasPriceError => total < 0;

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
  // COPYWITH
  // ============================================

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
    OrderUser? user,
    OrderAddress? shippingAddress,
    OrderAddress? billingAddress,
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
      user: user ?? this.user,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
    );
  }

  // ============================================
  // JSON
  // ============================================

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
      'user': user?.toJson(),
      'shipping_address': shippingAddress?.toJson(),
      'billing_address': billingAddress?.toJson(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    // ✅ Parser les items (2 formats : liste ou map)
    final rawItems = json['items'];
    List<OrderItem> items = [];
    if (rawItems is List) {
      items = rawItems
          .whereType<Map>()
          .map((itemJson) => OrderItem.fromJson(Map<String, dynamic>.from(itemJson)))
          .toList();
    }

    return Order(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      items: items,
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
      estimatedDeliveryDate: _parseDate(json['estimated_delivery_date']),
      shippedAt: _parseDate(json['shipped_at']),
      deliveredAt: _parseDate(json['delivered_at']),
      couponCode: json['coupon_code'] as String?,
      customerNote: json['customer_note'] as String?,
      adminNote: json['admin_note'] as String?,
      currency: json['currency'] as String? ?? 'FCFA',
      cancelledAt: _parseDate(json['cancelled_at']),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),

      // ✅ NOUVEAU : user + adresses
      user: _parseUser(json['user']),
      shippingAddress: _parseAddress(json['shipping_address']),
      billingAddress: _parseAddress(json['billing_address']),
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static OrderUser? _parseUser(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      try {
        return OrderUser.fromJson(Map<String, dynamic>.from(value));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static OrderAddress? _parseAddress(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      try {
        return OrderAddress.fromJson(Map<String, dynamic>.from(value));
      } catch (e) {
        return null;
      }
    }
    return null;
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

// ============================================
// ENTITÉ : OrderUser
// ============================================
// Représente l'utilisateur (client) d'une commande.
// ============================================

class OrderUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;

  const OrderUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
  });

  /// Nom complet (name est déjà complet côté API)
  String get fullName => name.isNotEmpty ? name : 'Client';

  /// Initiales pour l'avatar (ex: "Jean Kamga" → "JK")
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// A un avatar ?
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  /// A un téléphone ?
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return OrderUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? profile['phone'] as String?,
      avatar: json['avatar'] as String? ?? profile['avatar'] as String?,
    );
  }

  @override
  String toString() {
    return 'OrderUser(id: $id, name: $name, email: $email)';
  }
}

// ============================================
// ENTITÉ : OrderAddress
// ============================================
// Représente une adresse liée à une commande.
// ============================================

class OrderAddress {
  final int id;
  final String fullName;
  final String? phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;

  const OrderAddress({
    required this.id,
    required this.fullName,
    this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
  });

  /// Adresse complète formatée
  String get fullAddress {
    final parts = <String>[];
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (addressLine2 != null && addressLine2!.isNotEmpty) parts.add(addressLine2!);
    if (city.isNotEmpty) parts.add(city);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  /// Adresse courte (ville + pays)
  String get shortAddress => '$city, $country';

  /// A un téléphone ?
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'OrderAddress(id: $id, fullName: $fullName, city: $city)';
  }
}