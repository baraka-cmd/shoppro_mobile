// Entité CartItem (Domaine)
// Représente un élément dans le panier d'achat

class CartItem {
  final int id;
  final int productId;
  final String name;
  final String? imageUrl;
  final String sku;
  final double unitPrice;
  final double? discountPrice;
  final int quantity;
  final int maxQuantity;
  final int stock;
  final bool isSavedForLater;
  final String? variantName;
  final String? variantColor;
  final String? variantSize;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.sku,
    required this.unitPrice,
    this.discountPrice,
    this.quantity = 1,
    this.maxQuantity = 99,
    this.stock = 0,
    this.isSavedForLater = false,
    this.variantName,
    this.variantColor,
    this.variantSize,
  });

  /// Prix effectif (avec réduction si applicable)
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

  /// L'article est-il en stock ?
  bool get isInStock => stock > 0;

  /// Stock faible ?
  bool get isLowStock => stock > 0 && stock <= 5;

  /// Peut-on incrémenter ?
  bool get canIncrement => quantity < maxQuantity && quantity < stock;

  /// Peut-on décrémenter ?
  bool get canDecrement => quantity > 1;

  /// Nom complet avec variante
  String get fullName {
    if (variantName != null && variantName!.isNotEmpty) {
      return variantName!;
    }
    if (variantColor != null || variantSize != null) {
      final parts = <String>[];
      if (variantColor != null) parts.add(variantColor!);
      if (variantSize != null) parts.add(variantSize!);
      return '$name (${parts.join(' - ')})';
    }
    return name;
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
  CartItem copyWith({
    int? id,
    int? productId,
    String? name,
    String? imageUrl,
    String? sku,
    double? unitPrice,
    double? discountPrice,
    int? quantity,
    int? maxQuantity,
    int? stock,
    bool? isSavedForLater,
    String? variantName,
    String? variantColor,
    String? variantSize,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      sku: sku ?? this.sku,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      stock: stock ?? this.stock,
      isSavedForLater: isSavedForLater ?? this.isSavedForLater,
      variantName: variantName ?? this.variantName,
      variantColor: variantColor ?? this.variantColor,
      variantSize: variantSize ?? this.variantSize,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'sku': sku,
      'unit_price': unitPrice,
      'discount_price': discountPrice,
      'quantity': quantity,
      'max_quantity': maxQuantity,
      'stock': stock,
      'is_saved_for_later': isSavedForLater,
      'variant_name': variantName,
      'variant_color': variantColor,
      'variant_size': variantSize,
    };
  }

  /// Créer depuis JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      sku: json['sku'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      maxQuantity: json['max_quantity'] as int? ?? 99,
      stock: json['stock'] as int? ?? 0,
      isSavedForLater: json['is_saved_for_later'] as bool? ?? false,
      variantName: json['variant_name'] as String?,
      variantColor: json['variant_color'] as String?,
      variantSize: json['variant_size'] as String?,
    );
  }
}