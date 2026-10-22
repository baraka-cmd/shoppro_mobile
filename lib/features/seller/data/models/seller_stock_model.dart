// ============================================
// MODEL : SellerStockModel
// ============================================
// Sérialisation JSON pour SellerStock + sous-entités.
//
// Responsabilités :
//   - Parser la réponse API /seller/stocks
//   - Gérer les valeurs null (parsing défensif)
//   - Convertir types (num → double/int)
//   - Fournir des fallbacks sûrs
// ============================================

import '../../domain/entities/seller_stock.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerStockModel extends SellerStock {
  const SellerStockModel({
    required super.id,
    required super.productId,
    required super.warehouseId,
    super.product,
    super.warehouse,
    required super.quantity,
    super.reservedQuantity,
    required super.availableQuantity,
    super.minQuantity,
    super.maxQuantity,
    super.unitCost,
    super.unitCostFormatted,
    super.totalValue,
    super.totalValueFormatted,
    super.location,
    super.shelf,
    super.bin,
    super.fullLocation,
    super.status,
    super.statusLabel,
    super.statusColor,
    required super.needsRestock,
    super.recommendedRestock,
    super.stockPercentage,
    super.lastCountedAt,
    super.expiryDate,
    super.isExpiringSoon,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    super.updatedAtHuman,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerStockModel.fromJson(Map<String, dynamic> json) {
    return SellerStockModel(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      warehouseId: _parseInt(json['warehouse_id']),
      product: json['product'] is Map
          ? SellerStockProductModel.fromJson(
              Map<String, dynamic>.from(json['product'] as Map),
            )
          : null,
      warehouse: json['warehouse'] is Map
          ? SellerStockWarehouseModel.fromJson(
              Map<String, dynamic>.from(json['warehouse'] as Map),
            )
          : null,
      quantity: _parseInt(json['quantity']),
      reservedQuantity: _parseInt(json['reserved_quantity']),
      availableQuantity: _parseInt(json['available_quantity']),
      minQuantity: _parseInt(json['min_quantity'], defaultValue: 5),
      maxQuantity: json['max_quantity'] != null
          ? _parseInt(json['max_quantity'])
          : null,
      unitCost: json['unit_cost'] != null
          ? _parseDouble(json['unit_cost'])
          : null,
      unitCostFormatted: _parseNullableString(json['unit_cost_formatted']),
      totalValue: json['total_value'] != null
          ? _parseDouble(json['total_value'])
          : null,
      totalValueFormatted: _parseNullableString(json['total_value_formatted']),
      location: _parseNullableString(json['location']),
      shelf: _parseNullableString(json['shelf']),
      bin: _parseNullableString(json['bin']),
      fullLocation: _parseString(json['full_location'], 'Non défini'),
      status: _parseString(json['status'], 'in_stock'),
      statusLabel: _parseString(json['status_label'], 'En stock'),
      statusColor: _parseString(json['status_color'], '#10B981'),
      needsRestock: _parseBool(json['needs_restock']),
      recommendedRestock: _parseInt(json['recommended_restock']),
      stockPercentage: _parseDouble(json['stock_percentage']),
      lastCountedAt: _parseDate(json['last_counted_at']),
      expiryDate: _parseDate(json['expiry_date']),
      isExpiringSoon: _parseBool(json['is_expiring_soon']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      updatedAtHuman: _parseNullableString(json['updated_at_human']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'warehouse_id': warehouseId,
      'product': product != null
          ? SellerStockProductModel.fromEntity(product!).toJson()
          : null,
      'warehouse': warehouse != null
          ? SellerStockWarehouseModel.fromEntity(warehouse!).toJson()
          : null,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'available_quantity': availableQuantity,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'unit_cost': unitCost,
      'unit_cost_formatted': unitCostFormatted,
      'total_value': totalValue,
      'total_value_formatted': totalValueFormatted,
      'location': location,
      'shelf': shelf,
      'bin': bin,
      'full_location': fullLocation,
      'status': status,
      'status_label': statusLabel,
      'status_color': statusColor,
      'needs_restock': needsRestock,
      'recommended_restock': recommendedRestock,
      'stock_percentage': stockPercentage,
      'last_counted_at': lastCountedAt?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'is_expiring_soon': isExpiringSoon,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'updated_at_human': updatedAtHuman,
    };
  }

  // ============================================
  // fromEntity
  // ============================================

  factory SellerStockModel.fromEntity(SellerStock entity) {
    return SellerStockModel(
      id: entity.id,
      productId: entity.productId,
      warehouseId: entity.warehouseId,
      product: entity.product,
      warehouse: entity.warehouse,
      quantity: entity.quantity,
      reservedQuantity: entity.reservedQuantity,
      availableQuantity: entity.availableQuantity,
      minQuantity: entity.minQuantity,
      maxQuantity: entity.maxQuantity,
      unitCost: entity.unitCost,
      unitCostFormatted: entity.unitCostFormatted,
      totalValue: entity.totalValue,
      totalValueFormatted: entity.totalValueFormatted,
      location: entity.location,
      shelf: entity.shelf,
      bin: entity.bin,
      fullLocation: entity.fullLocation,
      status: entity.status,
      statusLabel: entity.statusLabel,
      statusColor: entity.statusColor,
      needsRestock: entity.needsRestock,
      recommendedRestock: entity.recommendedRestock,
      stockPercentage: entity.stockPercentage,
      lastCountedAt: entity.lastCountedAt,
      expiryDate: entity.expiryDate,
      isExpiringSoon: entity.isExpiringSoon,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      updatedAtHuman: entity.updatedAtHuman,
    );
  }
}

// ============================================
// MODEL : SellerStockProductModel
// ============================================

class SellerStockProductModel extends SellerStockProduct {
  const SellerStockProductModel({
    required super.id,
    required super.name,
    required super.sku,
    super.imageUrl,
    required super.price,
    required super.priceFormatted,
    super.discountPrice,
  });

  factory SellerStockProductModel.fromJson(Map<String, dynamic> json) {
    return SellerStockProductModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Produit'),
      sku: _parseString(json['sku']),
      imageUrl: _parseNullableString(json['image_url']),
      price: _parseDouble(json['price']),
      priceFormatted: _parseString(json['price_formatted'], '0 FCFA'),
      discountPrice: json['discount_price'] != null
          ? _parseDouble(json['discount_price'])
          : null,
    );
  }

  factory SellerStockProductModel.fromEntity(SellerStockProduct e) {
    return SellerStockProductModel(
      id: e.id,
      name: e.name,
      sku: e.sku,
      imageUrl: e.imageUrl,
      price: e.price,
      priceFormatted: e.priceFormatted,
      discountPrice: e.discountPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'image_url': imageUrl,
      'price': price,
      'price_formatted': priceFormatted,
      'discount_price': discountPrice,
    };
  }
}

// ============================================
// MODEL : SellerStockWarehouseModel
// ============================================

class SellerStockWarehouseModel extends SellerStockWarehouse {
  const SellerStockWarehouseModel({
    required super.id,
    required super.name,
    required super.code,
    super.city,
  });

  factory SellerStockWarehouseModel.fromJson(Map<String, dynamic> json) {
    return SellerStockWarehouseModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Entrepôt'),
      code: _parseString(json['code']),
      city: _parseNullableString(json['city']),
    );
  }

  factory SellerStockWarehouseModel.fromEntity(SellerStockWarehouse e) {
    return SellerStockWarehouseModel(
      id: e.id,
      name: e.name,
      code: e.code,
      city: e.city,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
    };
  }
}

// ============================================
// MODEL : SellerStockMovementModel
// ============================================

class SellerStockMovementModel extends SellerStockMovement {
  const SellerStockMovementModel({
    required super.id,
    required super.type,
    required super.typeLabel,
    required super.typeColor,
    required super.quantity,
    required super.quantityBefore,
    required super.quantityAfter,
    super.note,
    super.product,
    super.warehouse,
    super.createdAt,
    super.createdAtHuman,
  });

  factory SellerStockMovementModel.fromJson(Map<String, dynamic> json) {
    return SellerStockMovementModel(
      id: _parseInt(json['id']),
      type: _parseString(json['type'], 'adjustment'),
      typeLabel: _parseString(json['type_label'], 'Ajustement'),
      typeColor: _parseString(json['type_color'], '#F59E0B'),
      quantity: _parseInt(json['quantity']),
      quantityBefore: _parseInt(json['quantity_before']),
      quantityAfter: _parseInt(json['quantity_after']),
      note: _parseNullableString(json['note']),
      product: json['product'] is Map
          ? SellerStockMovementProductModel.fromJson(
              Map<String, dynamic>.from(json['product'] as Map),
            )
          : null,
      warehouse: json['warehouse'] is Map
          ? SellerStockMovementWarehouseModel.fromJson(
              Map<String, dynamic>.from(json['warehouse'] as Map),
            )
          : null,
      createdAt: _parseDate(json['created_at']),
      createdAtHuman: _parseNullableString(json['created_at_human']),
    );
  }

  factory SellerStockMovementModel.fromEntity(SellerStockMovement e) {
    return SellerStockMovementModel(
      id: e.id,
      type: e.type,
      typeLabel: e.typeLabel,
      typeColor: e.typeColor,
      quantity: e.quantity,
      quantityBefore: e.quantityBefore,
      quantityAfter: e.quantityAfter,
      note: e.note,
      product: e.product,
      warehouse: e.warehouse,
      createdAt: e.createdAt,
      createdAtHuman: e.createdAtHuman,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'type_label': typeLabel,
      'type_color': typeColor,
      'quantity': quantity,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'note': note,
      'product': product != null
          ? SellerStockMovementProductModel.fromEntity(product!).toJson()
          : null,
      'warehouse': warehouse != null
          ? SellerStockMovementWarehouseModel.fromEntity(warehouse!).toJson()
          : null,
      'created_at': createdAt?.toIso8601String(),
      'created_at_human': createdAtHuman,
    };
  }
}

// ============================================
// MODEL : SellerStockMovementProductModel
// ============================================

class SellerStockMovementProductModel extends SellerStockMovementProduct {
  const SellerStockMovementProductModel({
    required super.id,
    required super.name,
    required super.sku,
  });

  factory SellerStockMovementProductModel.fromJson(Map<String, dynamic> json) {
    return SellerStockMovementProductModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Produit'),
      sku: _parseString(json['sku']),
    );
  }

  factory SellerStockMovementProductModel.fromEntity(
    SellerStockMovementProduct e,
  ) {
    return SellerStockMovementProductModel(
      id: e.id,
      name: e.name,
      sku: e.sku,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
    };
  }
}

// ============================================
// MODEL : SellerStockMovementWarehouseModel
// ============================================

class SellerStockMovementWarehouseModel extends SellerStockMovementWarehouse {
  const SellerStockMovementWarehouseModel({
    required super.id,
    required super.name,
  });

  factory SellerStockMovementWarehouseModel.fromJson(Map<String, dynamic> json) {
    return SellerStockMovementWarehouseModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Entrepôt'),
    );
  }

  factory SellerStockMovementWarehouseModel.fromEntity(
    SellerStockMovementWarehouse e,
  ) {
    return SellerStockMovementWarehouseModel(
      id: e.id,
      name: e.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// ============================================
// MODEL : SellerStockStatsModel
// ============================================

class SellerStockStatsModel extends SellerStockStats {
  const SellerStockStatsModel({
    super.total,
    super.inStock,
    super.lowStock,
    super.outOfStock,
    super.needsAttention,
    super.totalQuantity,
    super.totalAvailable,
    super.totalReserved,
  });

  factory SellerStockStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerStockStatsModel(
      total: _parseInt(json['total']),
      inStock: _parseInt(json['in_stock']),
      lowStock: _parseInt(json['low_stock']),
      outOfStock: _parseInt(json['out_of_stock']),
      needsAttention: _parseInt(json['needs_attention']),
      totalQuantity: _parseInt(json['total_quantity']),
      totalAvailable: _parseInt(json['total_available']),
      totalReserved: _parseInt(json['total_reserved']),
    );
  }

  factory SellerStockStatsModel.fromEntity(SellerStockStats e) {
    return SellerStockStatsModel(
      total: e.total,
      inStock: e.inStock,
      lowStock: e.lowStock,
      outOfStock: e.outOfStock,
      needsAttention: e.needsAttention,
      totalQuantity: e.totalQuantity,
      totalAvailable: e.totalAvailable,
      totalReserved: e.totalReserved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'in_stock': inStock,
      'low_stock': lowStock,
      'out_of_stock': outOfStock,
      'needs_attention': needsAttention,
      'total_quantity': totalQuantity,
      'total_available': totalAvailable,
      'total_reserved': totalReserved,
    };
  }
}

// ============================================
// HELPERS DE PARSING
// ============================================

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'yes';
  }
  return defaultValue;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}