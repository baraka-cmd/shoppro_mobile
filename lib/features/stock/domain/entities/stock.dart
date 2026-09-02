// Entité Stock (Domaine)
// Représente le stock d'un produit

class Stock {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final String productSku;
  final int warehouseId;
  final String warehouseName;
  final int quantity;
  final int reservedQuantity;
  final int availableQuantity;
  final int minQuantity;
  final int? maxQuantity;
  final double? unitCost;
  final double? totalValue;
  final DateTime? lastCountedAt;
  final bool isActive;

  const Stock({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.productSku,
    required this.warehouseId,
    required this.warehouseName,
    this.quantity = 0,
    this.reservedQuantity = 0,
    this.availableQuantity = 0,
    this.minQuantity = 5,
    this.maxQuantity,
    this.unitCost,
    this.totalValue,
    this.lastCountedAt,
    this.isActive = true,
  });

  /// Statut du stock
  String get status {
    if (availableQuantity <= 0) return 'out_of_stock';
    if (availableQuantity <= minQuantity) return 'low_stock';
    return 'in_stock';
  }

  /// Label du statut
  String get statusLabel {
    switch (status) {
      case 'out_of_stock':
        return 'Rupture de stock';
      case 'low_stock':
        return 'Stock faible';
      case 'in_stock':
        return 'En stock';
      default:
        return status;
    }
  }

  /// Couleur du statut
  int get statusColor {
    switch (status) {
      case 'out_of_stock':
        return 0xFFE74C3C;
      case 'low_stock':
        return 0xFFF39C12;
      case 'in_stock':
        return 0xFF27AE60;
      default:
        return 0xFF7F8C8D;
    }
  }

  /// Pourcentage de stock
  double get stockPercentage {
    final max = maxQuantity ?? quantity;
    if (max <= 0) return 0;
    return (availableQuantity / max).clamp(0.0, 1.0);
  }

  /// Le stock est-il faible ?
  bool get isLowStock => status == 'low_stock';

  /// Le stock est-il épuisé ?
  bool get isOutOfStock => status == 'out_of_stock';

  /// Valeur totale formatée
  String get formattedTotalValue {
    if (totalValue == null) return 'N/A';
    return '${totalValue!.toStringAsFixed(0)} FCFA';
  }

  /// Copier avec modifications
  Stock copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productImage,
    String? productSku,
    int? warehouseId,
    String? warehouseName,
    int? quantity,
    int? reservedQuantity,
    int? availableQuantity,
    int? minQuantity,
    int? maxQuantity,
    double? unitCost,
    double? totalValue,
    DateTime? lastCountedAt,
    bool? isActive,
  }) {
    return Stock(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productSku: productSku ?? this.productSku,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      quantity: quantity ?? this.quantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      unitCost: unitCost ?? this.unitCost,
      totalValue: totalValue ?? this.totalValue,
      lastCountedAt: lastCountedAt ?? this.lastCountedAt,
      isActive: isActive ?? this.isActive,
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
      'warehouse_id': warehouseId,
      'warehouse_name': warehouseName,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'available_quantity': availableQuantity,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'unit_cost': unitCost,
      'total_value': totalValue,
      'last_counted_at': lastCountedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Créer depuis JSON
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String?,
      productSku: json['product_sku'] as String? ?? '',
      warehouseId: json['warehouse_id'] as int? ?? 0,
      warehouseName: json['warehouse_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      reservedQuantity: json['reserved_quantity'] as int? ?? 0,
      availableQuantity: json['available_quantity'] as int? ?? 0,
      minQuantity: json['min_quantity'] as int? ?? 5,
      maxQuantity: json['max_quantity'] as int?,
      unitCost: (json['unit_cost'] as num?)?.toDouble(),
      totalValue: (json['total_value'] as num?)?.toDouble(),
      lastCountedAt: DateTime.tryParse(json['last_counted_at'] as String? ?? ''),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}