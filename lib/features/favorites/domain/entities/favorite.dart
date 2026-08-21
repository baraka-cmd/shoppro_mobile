// Entité Favorite (Domaine)
// Représente un produit dans la liste de souhaits

class Favorite {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final String productSku;
  final double productPrice;
  final double? productDiscountPrice;
  final bool isInStock;
  final int stock;
  final double averageRating;
  final DateTime addedAt;
  final bool priceAlert;
  final double? priceAlertThreshold;
  final String? collectionName;
  final String? note;

  const Favorite({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.productSku,
    required this.productPrice,
    this.productDiscountPrice,
    this.isInStock = true,
    this.stock = 0,
    this.averageRating = 0,
    required this.addedAt,
    this.priceAlert = false,
    this.priceAlertThreshold,
    this.collectionName,
    this.note,
  });

  /// Prix effectif (avec réduction)
  double get effectivePrice => productDiscountPrice ?? productPrice;

  /// Prix formaté
  String get formattedPrice => _formatPrice(effectivePrice);

  /// Ancien prix formaté
  String get formattedOriginalPrice => _formatPrice(productPrice);

  /// Le produit a-t-il une réduction ?
  bool get hasDiscount =>
      productDiscountPrice != null && productDiscountPrice! < productPrice;

  /// Pourcentage de réduction
  int? get discountPercentage {
    if (!hasDiscount) return null;
    return ((productPrice - productDiscountPrice!) / productPrice * 100).round();
  }

  /// Date d'ajout formatée
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(addedAt);

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
    return '$buffer FCFA';
  }

  /// Copier avec modifications
  Favorite copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productImage,
    String? productSku,
    double? productPrice,
    double? productDiscountPrice,
    bool? isInStock,
    int? stock,
    double? averageRating,
    DateTime? addedAt,
    bool? priceAlert,
    double? priceAlertThreshold,
    String? collectionName,
    String? note,
  }) {
    return Favorite(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productSku: productSku ?? this.productSku,
      productPrice: productPrice ?? this.productPrice,
      productDiscountPrice: productDiscountPrice ?? this.productDiscountPrice,
      isInStock: isInStock ?? this.isInStock,
      stock: stock ?? this.stock,
      averageRating: averageRating ?? this.averageRating,
      addedAt: addedAt ?? this.addedAt,
      priceAlert: priceAlert ?? this.priceAlert,
      priceAlertThreshold: priceAlertThreshold ?? this.priceAlertThreshold,
      collectionName: collectionName ?? this.collectionName,
      note: note ?? this.note,
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
      'product_price': productPrice,
      'product_discount_price': productDiscountPrice,
      'is_in_stock': isInStock,
      'stock': stock,
      'average_rating': averageRating,
      'added_at': addedAt.toIso8601String(),
      'price_alert': priceAlert,
      'price_alert_threshold': priceAlertThreshold,
      'collection_name': collectionName,
      'note': note,
    };
  }

  /// Créer depuis JSON
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String?,
      productSku: json['product_sku'] as String? ?? '',
      productPrice: (json['product_price'] as num?)?.toDouble() ?? 0,
      productDiscountPrice: (json['product_discount_price'] as num?)?.toDouble(),
      isInStock: json['is_in_stock'] as bool? ?? true,
      stock: json['stock'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      addedAt: DateTime.tryParse(json['added_at'] as String? ?? '') ?? DateTime.now(),
      priceAlert: json['price_alert'] as bool? ?? false,
      priceAlertThreshold: (json['price_alert_threshold'] as num?)?.toDouble(),
      collectionName: json['collection_name'] as String?,
      note: json['note'] as String?,
    );
  }
}