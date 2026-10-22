// ============================================
// ENTITÉ : SellerStock
// ============================================
// Représente un stock du point de vue VENDEUR.
//
// Responsabilités :
//   - Contenir toutes les infos d'un stock (quantités, seuils, localisation)
//   - Exposer des getters métier (status, needs_restock, etc.)
//   - Contenir le produit et l'entrepôt associés
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

class SellerStock {
  // ============================================
  // IDENTIFIANTS
  // ============================================
  final int id;
  final int productId;
  final int warehouseId;

  // ============================================
  // RELATIONS
  // ============================================
  final SellerStockProduct? product;
  final SellerStockWarehouse? warehouse;

  // ============================================
  // QUANTITÉS
  // ============================================
  final int quantity;
  final int reservedQuantity;
  final int availableQuantity;
  final int minQuantity;
  final int? maxQuantity;

  // ============================================
  // VALEUR (optionnel — peut être null si vendeur)
  // ============================================
  final double? unitCost;
  final String? unitCostFormatted;
  final double? totalValue;
  final String? totalValueFormatted;

  // ============================================
  // LOCALISATION
  // ============================================
  final String? location;
  final String? shelf;
  final String? bin;
  final String fullLocation;

  // ============================================
  // STATUT & ALERTES
  // ============================================
  final String status; // in_stock | low_stock | out_of_stock | overstock
  final String statusLabel;
  final String statusColor;

  // ============================================
  // ACTIONS RECOMMANDÉES
  // ============================================
  final bool needsRestock;
  final int recommendedRestock;
  final double stockPercentage;

  // ============================================
  // DATES
  // ============================================
  final DateTime? lastCountedAt;
  final DateTime? expiryDate;
  final bool isExpiringSoon;

  // ============================================
  // ÉTAT
  // ============================================
  final bool isActive;

  // ============================================
  // HORODATAGE
  // ============================================
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedAtHuman;

  const SellerStock({
    required this.id,
    required this.productId,
    required this.warehouseId,
    this.product,
    this.warehouse,
    required this.quantity,
    this.reservedQuantity = 0,
    required this.availableQuantity,
    this.minQuantity = 5,
    this.maxQuantity,
    this.unitCost,
    this.unitCostFormatted,
    this.totalValue,
    this.totalValueFormatted,
    this.location,
    this.shelf,
    this.bin,
    this.fullLocation = 'Non défini',
    this.status = 'in_stock',
    this.statusLabel = 'En stock',
    this.statusColor = '#10B981',
    required this.needsRestock,
    this.recommendedRestock = 0,
    this.stockPercentage = 0,
    this.lastCountedAt,
    this.expiryDate,
    this.isExpiringSoon = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.updatedAtHuman,
  });

  // ============================================
  // GETTERS STATUT
  // ============================================

  bool get isInStock => status == 'in_stock';
  bool get isLowStock => status == 'low_stock';
  bool get isOutOfStock => status == 'out_of_stock';
  bool get isOverstock => status == 'overstock';

  /// Le stock nécessite-t-il une action urgente ?
  bool get needsAttention => isLowStock || isOutOfStock;

  /// Le stock est-il critique (rupture) ?
  bool get isCritical => isOutOfStock;

  // ============================================
  // GETTERS QUANTITÉS
  // ============================================

  /// Pourcentage utilisé par rapport à la quantité max.
  String get formattedStockPercentage {
    if (stockPercentage <= 0) return '0%';
    return '${stockPercentage.toStringAsFixed(1)}%';
  }

  /// Le stock a-t-il des réservations ?
  bool get hasReserved => reservedQuantity > 0;

  /// Marge restante avant le seuil critique.
  int get marginBeforeCritical => availableQuantity - minQuantity;

  // ============================================
  // GETTERS LOCALISATION
  // ============================================

  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get hasShelf => shelf != null && shelf!.isNotEmpty;
  bool get hasBin => bin != null && bin!.isNotEmpty;
  bool get hasFullLocation => fullLocation != 'Non défini';

  // ============================================
  // GETTERS PRODUIT
  // ============================================

  bool get hasProduct => product != null;
  bool get hasWarehouse => warehouse != null;

  @override
  String toString() {
    return 'SellerStock(id: $id, product: ${product?.name}, '
        'available: $availableQuantity/$minQuantity, status: $statusLabel)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerStockProduct
// ============================================
// Informations produit (partielles).
// ============================================

class SellerStockProduct {
  final int id;
  final String name;
  final String sku;
  final String? imageUrl;
  final double price;
  final String priceFormatted;
  final double? discountPrice;

  const SellerStockProduct({
    required this.id,
    required this.name,
    required this.sku,
    this.imageUrl,
    required this.price,
    required this.priceFormatted,
    this.discountPrice,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasDiscount => discountPrice != null && discountPrice! > 0;

  @override
  String toString() => 'SellerStockProduct(name: $name, sku: $sku)';
}

// ============================================
// SOUS-ENTITÉ : SellerStockWarehouse
// ============================================
// Informations entrepôt (partielles).
// ============================================

class SellerStockWarehouse {
  final int id;
  final String name;
  final String code;
  final String? city;

  const SellerStockWarehouse({
    required this.id,
    required this.name,
    required this.code,
    this.city,
  });

  @override
  String toString() => 'SellerStockWarehouse(name: $name, code: $code)';
}

// ============================================
// ENTITÉ : SellerStockMovement
// ============================================
// Un mouvement de stock (vente, ajustement, retour...).
// ============================================

class SellerStockMovement {
  final int id;
  final String type;
  final String typeLabel;
  final String typeColor;
  final int quantity;
  final int quantityBefore;
  final int quantityAfter;
  final String? note;
  final SellerStockMovementProduct? product;
  final SellerStockMovementWarehouse? warehouse;
  final DateTime? createdAt;
  final String? createdAtHuman;

  const SellerStockMovement({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.typeColor,
    required this.quantity,
    required this.quantityBefore,
    required this.quantityAfter,
    this.note,
    this.product,
    this.warehouse,
    this.createdAt,
    this.createdAtHuman,
  });

  // ============================================
  // GETTERS
  // ============================================

  bool get isPositive => quantity > 0;
  bool get isNegative => quantity < 0;

  /// Signe formaté (ex: "+5" ou "-3").
  String get formattedQuantity {
    final sign = quantity > 0 ? '+' : '';
    return '$sign$quantity';
  }

  bool get hasProduct => product != null;
  bool get hasNote => note != null && note!.isNotEmpty;

  @override
  String toString() {
    return 'SellerStockMovement(type: $typeLabel, qty: $formattedQuantity)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerStockMovementProduct
// ============================================

class SellerStockMovementProduct {
  final int id;
  final String name;
  final String sku;

  const SellerStockMovementProduct({
    required this.id,
    required this.name,
    required this.sku,
  });

  @override
  String toString() => 'SellerStockMovementProduct(name: $name)';
}

// ============================================
// SOUS-ENTITÉ : SellerStockMovementWarehouse
// ============================================

class SellerStockMovementWarehouse {
  final int id;
  final String name;

  const SellerStockMovementWarehouse({
    required this.id,
    required this.name,
  });

  @override
  String toString() => 'SellerStockMovementWarehouse(name: $name)';
}

// ============================================
// ENTITÉ : SellerStockStats
// ============================================
// Statistiques globales des stocks du vendeur.
// ============================================

class SellerStockStats {
  final int total;
  final int inStock;
  final int lowStock;
  final int outOfStock;
  final int needsAttention;
  final int totalQuantity;
  final int totalAvailable;
  final int totalReserved;

  const SellerStockStats({
    this.total = 0,
    this.inStock = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
    this.needsAttention = 0,
    this.totalQuantity = 0,
    this.totalAvailable = 0,
    this.totalReserved = 0,
  });

  const SellerStockStats.empty()
      : total = 0,
        inStock = 0,
        lowStock = 0,
        outOfStock = 0,
        needsAttention = 0,
        totalQuantity = 0,
        totalAvailable = 0,
        totalReserved = 0;

  bool get hasAlerts => needsAttention > 0;
  bool get hasCriticalAlerts => outOfStock > 0;

  @override
  String toString() {
    return 'SellerStockStats(total: $total, '
        'low: $lowStock, out: $outOfStock, available: $totalAvailable)';
  }
}