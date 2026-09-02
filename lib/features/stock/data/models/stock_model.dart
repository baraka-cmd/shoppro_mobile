// Modèle Stock (Data)
// Gère la sérialisation/désérialisation JSON du stock

import '../../domain/entities/stock.dart';

class StockModel extends Stock {
  const StockModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImage,
    required super.productSku,
    required super.warehouseId,
    required super.warehouseName,
    super.quantity,
    super.reservedQuantity,
    super.availableQuantity,
    super.minQuantity,
    super.maxQuantity,
    super.unitCost,
    super.totalValue,
    super.lastCountedAt,
    super.isActive,
  });

  /// Créer depuis JSON
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
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
      unitCost: _parseNullableDouble(json['unit_cost']),
      totalValue: _parseNullableDouble(json['total_value']),
      lastCountedAt: DateTime.tryParse(json['last_counted_at'] as String? ?? ''),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convertir en JSON
  @override
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

  /// Parser un double nullable
  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }
}