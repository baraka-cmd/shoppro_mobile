// Entité OrderItem (Domaine)
// Représente un élément dans une commande

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

  /// Prix effectif (avec réduction)
  double get effectivePrice => discountPrice ?? unitPrice;

  /// Sous-total de cet élément
  double get subtotal => effectivePrice * quantity;

  /// Prix formaté
  String get formattedPrice => _formatPrice(effectivePrice);

  /// Sous-total formaté
  String get formattedSubtotal => _formatPrice(subtotal);

  /// L'article a-t-il une réduction ?
  bool get hasDiscount => discountPrice != null && discountPrice! < unitPrice;

  /// Pourcentage de réduction
  int? get discountPercentage {
    if (!hasDiscount) return null;
    return ((unitPrice - discountPrice!) / unitPrice * 100).round();
  }

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

  /// Statut de l'article formaté
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

  /// Couleur du statut
  int get statusColor {
    switch (itemStatus) {
      case 'pending':
        return 0xFFF39C12;
      case 'shipped':
        return 0xFF3498DB;
      case 'delivered':
        return 0xFF27AE60;
      case 'cancelled':
        return 0xFFE74C3C;
      case 'returned':
        return 0xFF7F8C8D;
      default:
        return 0xFF7F8C8D;
    }
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
    return '$buffer FCFA';
  }

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
}