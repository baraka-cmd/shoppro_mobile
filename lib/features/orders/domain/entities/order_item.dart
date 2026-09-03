// ============================================
// ENTITÉ ORDER ITEM (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente un élément dans une commande avec
// variantes, retours et formatage. Design ShopPro.
// ============================================

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final String productSku;
  final double unitPrice;
  final double? discountPrice;
  final int quantity;
  final String? variantName;
  final String? variantColor;
  final String? variantSize;
  final String itemStatus;
  final bool isReturned;
  final DateTime? returnDate;
  final String? returnReason;
  final bool isRefunded;
  final double? refundAmount;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.productSku,
    required this.unitPrice,
    this.discountPrice,
    this.quantity = 1,
    this.variantName,
    this.variantColor,
    this.variantSize,
    this.itemStatus = 'pending',
    this.isReturned = false,
    this.returnDate,
    this.returnReason,
    this.isRefunded = false,
    this.refundAmount,
  });

  // ============================================
  // PRIX
  // ============================================

  /// Prix effectif (avec réduction)
  double get effectivePrice => discountPrice ?? unitPrice;

  /// Sous-total de cet élément
  double get subtotal => effectivePrice * quantity;

  /// Prix formaté
  String get formattedPrice => _formatPrice(effectivePrice);

  /// Prix unitaire original formaté
  String get formattedUnitPrice => _formatPrice(unitPrice);

  /// Sous-total formaté
  String get formattedSubtotal => _formatPrice(subtotal);

  /// L'article a-t-il une réduction ?
  bool get hasDiscount => discountPrice != null && discountPrice! < unitPrice;

  /// Pourcentage de réduction
  int? get discountPercentage {
    if (!hasDiscount) return null;
    return ((unitPrice - discountPrice!) / unitPrice * 100).round();
  }

  /// Économies réalisées
  double get savings {
    if (!hasDiscount) return 0;
    return (unitPrice - discountPrice!) * quantity;
  }

  /// Économies formatées
  String get formattedSavings => _formatPrice(savings);

  // ============================================
  // NOM ET VARIANTES
  // ============================================

  /// Nom complet avec variante
  String get fullName {
    if (variantName != null && variantName!.isNotEmpty) {
      return variantName!;
    }
    if (variantColor != null || variantSize != null) {
      final parts = <String>[];
      if (variantColor != null) parts.add(variantColor!);
      if (variantSize != null) parts.add(variantSize!);
      return '$productName (${parts.join(' - ')})';
    }
    return productName;
  }

  /// Label des variantes
  String get variantLabel {
    final parts = <String>[];
    if (variantColor != null) parts.add(variantColor!);
    if (variantSize != null) parts.add(variantSize!);
    return parts.join(' • ');
  }

  /// L'article a-t-il des variantes ?
  bool get hasVariant => variantColor != null || variantSize != null;

  // ============================================
  // STATUT
  // ============================================

  /// Statut formaté
  String get statusLabel {
    switch (itemStatus) {
      case 'pending':
        return 'En attente';
      case 'shipped':
        return 'Expédié';
      case 'delivered':
        return 'Livré';
      case 'cancelled':
        return 'Annulé';
      case 'returned':
        return 'Retourné';
      default:
        return itemStatus;
    }
  }

  /// Couleur du statut (hex)
  int get statusColorHex {
    switch (itemStatus) {
      case 'pending':
        return 0xFFF4B942; // Gold
      case 'shipped':
        return 0xFF3B82F6; // Bleu
      case 'delivered':
        return 0xFF087F5B; // Emerald
      case 'cancelled':
        return 0xFFFF6B6B; // Coral
      case 'returned':
        return 0xFF68756F; // Gris
      default:
        return 0xFF68756F;
    }
  }

  /// L'article est-il livré ?
  bool get isDelivered => itemStatus == 'delivered';

  /// L'article est-il annulé ?
  bool get isCancelled => itemStatus == 'cancelled';

  /// L'article peut-il être retourné ?
  bool get canReturn => itemStatus == 'delivered' && !isReturned && !isRefunded;

  // ============================================
  // VALIDATION
  // ============================================

  /// L'article a-t-il des données valides ?
  bool get isValid {
    return id > 0 &&
        productId > 0 &&
        productName.isNotEmpty &&
        unitPrice >= 0 &&
        quantity > 0;
  }

  // ============================================
  // FORMATAGE
  // ============================================

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
    return '$buffer FCFA';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  OrderItem copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productImage,
    String? productSku,
    double? unitPrice,
    double? discountPrice,
    int? quantity,
    String? variantName,
    String? variantColor,
    String? variantSize,
    String? itemStatus,
    bool? isReturned,
    DateTime? returnDate,
    String? returnReason,
    bool? isRefunded,
    double? refundAmount,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productSku: productSku ?? this.productSku,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      variantName: variantName ?? this.variantName,
      variantColor: variantColor ?? this.variantColor,
      variantSize: variantSize ?? this.variantSize,
      itemStatus: itemStatus ?? this.itemStatus,
      isReturned: isReturned ?? this.isReturned,
      returnDate: returnDate ?? this.returnDate,
      returnReason: returnReason ?? this.returnReason,
      isRefunded: isRefunded ?? this.isRefunded,
      refundAmount: refundAmount ?? this.refundAmount,
    );
  }

  /// Convertir en JSON
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

  /// Créer depuis JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String?,
      productSku: json['product_sku'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      variantName: json['variant_name'] as String?,
      variantColor: json['variant_color'] as String?,
      variantSize: json['variant_size'] as String?,
      itemStatus: json['item_status'] as String? ?? 'pending',
      isReturned: json['is_returned'] as bool? ?? false,
      returnDate: DateTime.tryParse(json['return_date'] as String? ?? ''),
      returnReason: json['return_reason'] as String?,
      isRefunded: json['is_refunded'] as bool? ?? false,
      refundAmount: (json['refund_amount'] as num?)?.toDouble(),
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'OrderItem(id: $id, product: $productName, '
        'quantity: $quantity, subtotal: $formattedSubtotal, '
        'status: $statusLabel)';
  }
}