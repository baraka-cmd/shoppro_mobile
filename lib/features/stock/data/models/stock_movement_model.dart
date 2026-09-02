// Modèle StockMovement (Data)
// Gère la sérialisation/désérialisation JSON du mouvement de stock

import '../../domain/entities/stock_movement.dart';

class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.warehouseId,
    required super.warehouseName,
    required super.type,
    super.quantity,
    super.quantityBefore,
    super.quantityAfter,
    super.unitPrice,
    super.totalPrice,
    super.reference,
    super.note,
    required super.createdAt,
  });

  /// Créer depuis JSON
  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      warehouseId: json['warehouse_id'] as int? ?? 0,
      warehouseName: json['warehouse_name'] as String? ?? '',
      type: json['type'] as String? ?? 'adjustment',
      quantity: json['quantity'] as int? ?? 0,
      quantityBefore: json['quantity_before'] as int? ?? 0,
      quantityAfter: json['quantity_after'] as int? ?? 0,
      unitPrice: _parseNullableDouble(json['unit_price']),
      totalPrice: _parseNullableDouble(json['total_price']),
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'warehouse_id': warehouseId,
      'warehouse_name': warehouseName,
      'type': type,
      'quantity': quantity,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'reference': reference,
      'note': note,
      'created_at': createdAt.toIso8601String(),
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