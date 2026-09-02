// Entité StockMovement (Domaine)
// Représente un mouvement de stock (entrée, sortie, ajustement)

class StockMovement {
  final int id;
  final int productId;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final String type;
  final int quantity;
  final int quantityBefore;
  final int quantityAfter;
  final double? unitPrice;
  final double? totalPrice;
  final String? reference;
  final String? note;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.type,
    this.quantity = 0,
    this.quantityBefore = 0,
    this.quantityAfter = 0,
    this.unitPrice,
    this.totalPrice,
    this.reference,
    this.note,
    required this.createdAt,
  });

  /// Label du type de mouvement
  String get typeLabel {
    switch (type) {
      case 'in':
        return 'Entrée';
      case 'out':
        return 'Sortie';
      case 'adjustment':
        return 'Ajustement';
      case 'transfer':
        return 'Transfert';
      case 'return':
        return 'Retour';
      case 'sale':
        return 'Vente';
      case 'purchase':
        return 'Achat';
      case 'reservation':
        return 'Réservation';
      case 'release':
        return 'Libération';
      default:
        return type;
    }
  }

  /// Icône du type
  String get typeIcon {
    switch (type) {
      case 'in':
      case 'purchase':
        return '📥';
      case 'out':
      case 'sale':
        return '📤';
      case 'adjustment':
        return '🔧';
      case 'transfer':
        return '🔄';
      case 'return':
        return '↩️';
      case 'reservation':
        return '🔒';
      case 'release':
        return '🔓';
      default:
        return '📦';
    }
  }

  /// Couleur du type
  int get typeColor {
    switch (type) {
      case 'in':
      case 'purchase':
      case 'return':
      case 'release':
        return 0xFF27AE60;
      case 'out':
      case 'sale':
        return 0xFFE74C3C;
      case 'adjustment':
        return 0xFFF39C12;
      case 'transfer':
        return 0xFF3498DB;
      case 'reservation':
        return 0xFF9C27B0;
      default:
        return 0xFF7F8C8D;
    }
  }

  /// Le mouvement est-il une entrée ?
  bool get isIncoming => quantity > 0;

  /// Le mouvement est-il une sortie ?
  bool get isOutgoing => quantity < 0;

  /// Quantité absolue
  int get absoluteQuantity => quantity.abs();

  /// Total formaté
  String get formattedTotalPrice {
    if (totalPrice == null) return 'N/A';
    return '${totalPrice!.toStringAsFixed(0)} FCFA';
  }

  /// Date formatée
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
    }
    if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours}h';
    }
    return 'Il y a ${difference.inMinutes}min';
  }

  /// Copier avec modifications
  StockMovement copyWith({
    int? id,
    int? productId,
    String? productName,
    int? warehouseId,
    String? warehouseName,
    String? type,
    int? quantity,
    int? quantityBefore,
    int? quantityAfter,
    double? unitPrice,
    double? totalPrice,
    String? reference,
    String? note,
    DateTime? createdAt,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      quantityBefore: quantityBefore ?? this.quantityBefore,
      quantityAfter: quantityAfter ?? this.quantityAfter,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      reference: reference ?? this.reference,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertir en JSON
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

  /// Créer depuis JSON
  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      warehouseId: json['warehouse_id'] as int? ?? 0,
      warehouseName: json['warehouse_name'] as String? ?? '',
      type: json['type'] as String? ?? 'adjustment',
      quantity: json['quantity'] as int? ?? 0,
      quantityBefore: json['quantity_before'] as int? ?? 0,
      quantityAfter: json['quantity_after'] as int? ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}