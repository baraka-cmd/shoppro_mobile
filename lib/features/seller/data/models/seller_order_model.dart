// ============================================
// MODEL : SellerOrderModel
// ============================================
// Sérialisation JSON pour SellerOrder.
//
// Responsabilités :
//   - Parser la réponse API /seller/orders
//   - Gérer les valeurs null (parsing défensif)
//   - Convertir types (num → double/int)
//   - Fournir des fallbacks sûrs
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Entity
import '../../domain/entities/seller_order.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerOrderModel extends SellerOrder {
  const SellerOrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.statusLabel,
    required super.paymentStatus,
    required super.paymentStatusLabel,
    super.currency,
    super.createdAt,
    super.createdAtHuman,
    super.updatedAt,
    super.customer,
    super.shippingAddress,
    super.items,
    required super.totals,
    required super.actionsSummary,
    super.customerNote,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerOrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <SellerOrderItem>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(SellerOrderItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return SellerOrderModel(
      id: _parseInt(json['id']),
      orderNumber: _parseString(json['order_number'], 'CMD-XXXX'),
      status: _parseString(json['status'], 'pending'),
      statusLabel: _parseString(json['status_label'], 'En attente'),
      paymentStatus: _parseString(json['payment_status'], 'pending'),
      paymentStatusLabel: _parseString(json['payment_status_label'], 'En attente'),
      currency: _parseString(json['currency'], 'FCFA'),
      createdAt: _parseDate(json['created_at']),
      createdAtHuman: _parseNullableString(json['created_at_human']),
      updatedAt: _parseDate(json['updated_at']),
      customer: json['customer'] is Map
          ? SellerOrderCustomerModel.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map),
            )
          : null,
      shippingAddress: json['shipping_address'] is Map
          ? SellerOrderAddressModel.fromJson(
              Map<String, dynamic>.from(json['shipping_address'] as Map),
            )
          : null,
      items: items,
      totals: json['seller_totals'] is Map
          ? SellerOrderTotalsModel.fromJson(
              Map<String, dynamic>.from(json['seller_totals'] as Map),
            )
          : const SellerOrderTotals.empty(),
      actionsSummary: json['actions_summary'] is Map
          ? SellerOrderActionsSummaryModel.fromJson(
              Map<String, dynamic>.from(json['actions_summary'] as Map),
            )
          : const SellerOrderActionsSummary.empty(),
      customerNote: _parseNullableString(json['customer_note']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'status_label': statusLabel,
      'payment_status': paymentStatus,
      'payment_status_label': paymentStatusLabel,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'created_at_human': createdAtHuman,
      'updated_at': updatedAt?.toIso8601String(),
      'customer': customer != null
          ? SellerOrderCustomerModel.fromEntity(customer!).toJson()
          : null,
      'shipping_address': shippingAddress != null
          ? SellerOrderAddressModel.fromEntity(shippingAddress!).toJson()
          : null,
      'items': items
          .map((i) => SellerOrderItemModel.fromEntity(i).toJson())
          .toList(),
      'seller_totals': SellerOrderTotalsModel.fromEntity(totals).toJson(),
      'actions_summary':
          SellerOrderActionsSummaryModel.fromEntity(actionsSummary).toJson(),
      'customer_note': customerNote,
    };
  }

  // ============================================
  // fromEntity (conversion)
  // ============================================

  factory SellerOrderModel.fromEntity(SellerOrder entity) {
    return SellerOrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      status: entity.status,
      statusLabel: entity.statusLabel,
      paymentStatus: entity.paymentStatus,
      paymentStatusLabel: entity.paymentStatusLabel,
      currency: entity.currency,
      createdAt: entity.createdAt,
      createdAtHuman: entity.createdAtHuman,
      updatedAt: entity.updatedAt,
      customer: entity.customer,
      shippingAddress: entity.shippingAddress,
      items: entity.items,
      totals: entity.totals,
      actionsSummary: entity.actionsSummary,
      customerNote: entity.customerNote,
    );
  }
}

// ============================================
// MODEL : SellerOrderCustomerModel
// ============================================

class SellerOrderCustomerModel extends SellerOrderCustomer {
  const SellerOrderCustomerModel({
    required super.name,
    super.city,
    super.country,
  });

  factory SellerOrderCustomerModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderCustomerModel(
      name: _parseString(json['name'], 'Client'),
      city: _parseNullableString(json['city']),
      country: _parseNullableString(json['country']),
    );
  }

  factory SellerOrderCustomerModel.fromEntity(SellerOrderCustomer e) {
    return SellerOrderCustomerModel(
      name: e.name,
      city: e.city,
      country: e.country,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'city': city,
      'country': country,
    };
  }
}

// ============================================
// MODEL : SellerOrderAddressModel
// ============================================

class SellerOrderAddressModel extends SellerOrderAddress {
  const SellerOrderAddressModel({
    required super.fullName,
    required super.phone,
    required super.addressLine1,
    super.addressLine2,
    required super.city,
    super.state,
    super.postalCode,
    required super.country,
    super.deliveryInstructions,
  });

  factory SellerOrderAddressModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderAddressModel(
      fullName: _parseString(json['full_name']),
      phone: _parseString(json['phone']),
      addressLine1: _parseString(json['address_line1']),
      addressLine2: _parseNullableString(json['address_line2']),
      city: _parseString(json['city']),
      state: _parseNullableString(json['state']),
      postalCode: _parseNullableString(json['postal_code']),
      country: _parseString(json['country']),
      deliveryInstructions: _parseNullableString(json['delivery_instructions']),
    );
  }

  factory SellerOrderAddressModel.fromEntity(SellerOrderAddress e) {
    return SellerOrderAddressModel(
      fullName: e.fullName,
      phone: e.phone,
      addressLine1: e.addressLine1,
      addressLine2: e.addressLine2,
      city: e.city,
      state: e.state,
      postalCode: e.postalCode,
      country: e.country,
      deliveryInstructions: e.deliveryInstructions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'delivery_instructions': deliveryInstructions,
    };
  }
}

// ============================================
// MODEL : SellerOrderItemModel
// ============================================

class SellerOrderItemModel extends SellerOrderItem {
  const SellerOrderItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImageUrl,
    required super.productSku,
    required super.quantity,
    required super.unitPrice,
    required super.unitPriceFormatted,
    super.discountPrice,
    required super.totalPrice,
    required super.totalPriceFormatted,
    super.variantName,
    super.variantColor,
    super.variantSize,
    required super.sellerStatus,
    required super.sellerStatusLabel,
    required super.sellerStatusColor,
    super.canAccept,
    super.canPrepare,
    super.canShip,
    super.canCancel,
    super.acceptedAt,
    super.shippedAt,
  });

  factory SellerOrderItemModel.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] is Map
        ? Map<String, dynamic>.from(json['variant'] as Map)
        : null;

    return SellerOrderItemModel(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      productName: _parseString(json['product_name'], 'Produit'),
      productImageUrl: _parseNullableString(json['product_image_url']),
      productSku: _parseString(json['product_sku']),
      quantity: _parseInt(json['quantity'], defaultValue: 1),
      unitPrice: _parseDouble(json['unit_price']),
      unitPriceFormatted: _parseString(json['unit_price_formatted'], '0 FCFA'),
      discountPrice: json['discount_price'] != null
          ? _parseDouble(json['discount_price'])
          : null,
      totalPrice: _parseDouble(json['total_price']),
      totalPriceFormatted: _parseString(json['total_price_formatted'], '0 FCFA'),
      variantName: variant != null ? _parseNullableString(variant['name']) : null,
      variantColor: variant != null ? _parseNullableString(variant['color']) : null,
      variantSize: variant != null ? _parseNullableString(variant['size']) : null,
      sellerStatus: _parseString(json['seller_status'], 'to_accept'),
      sellerStatusLabel: _parseString(json['seller_status_label'], 'À accepter'),
      sellerStatusColor: _parseString(json['seller_status_color'], '#F59E0B'),
      canAccept: _parseBool(json['can_accept']),
      canPrepare: _parseBool(json['can_prepare']),
      canShip: _parseBool(json['can_ship']),
      canCancel: _parseBool(json['can_cancel']),
      acceptedAt: _parseDate(json['accepted_at']),
      shippedAt: _parseDate(json['shipped_at']),
    );
  }

  factory SellerOrderItemModel.fromEntity(SellerOrderItem e) {
    return SellerOrderItemModel(
      id: e.id,
      productId: e.productId,
      productName: e.productName,
      productImageUrl: e.productImageUrl,
      productSku: e.productSku,
      quantity: e.quantity,
      unitPrice: e.unitPrice,
      unitPriceFormatted: e.unitPriceFormatted,
      discountPrice: e.discountPrice,
      totalPrice: e.totalPrice,
      totalPriceFormatted: e.totalPriceFormatted,
      variantName: e.variantName,
      variantColor: e.variantColor,
      variantSize: e.variantSize,
      sellerStatus: e.sellerStatus,
      sellerStatusLabel: e.sellerStatusLabel,
      sellerStatusColor: e.sellerStatusColor,
      canAccept: e.canAccept,
      canPrepare: e.canPrepare,
      canShip: e.canShip,
      canCancel: e.canCancel,
      acceptedAt: e.acceptedAt,
      shippedAt: e.shippedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'product_sku': productSku,
      'quantity': quantity,
      'unit_price': unitPrice,
      'unit_price_formatted': unitPriceFormatted,
      'discount_price': discountPrice,
      'total_price': totalPrice,
      'total_price_formatted': totalPriceFormatted,
      'variant': hasVariant
          ? {'name': variantName, 'color': variantColor, 'size': variantSize}
          : null,
      'seller_status': sellerStatus,
      'seller_status_label': sellerStatusLabel,
      'seller_status_color': sellerStatusColor,
      'can_accept': canAccept,
      'can_prepare': canPrepare,
      'can_ship': canShip,
      'can_cancel': canCancel,
      'accepted_at': acceptedAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
    };
  }
}

// ============================================
// MODEL : SellerOrderTotalsModel
// ============================================

class SellerOrderTotalsModel extends SellerOrderTotals {
  const SellerOrderTotalsModel({
    required super.subtotal,
    required super.subtotalFormatted,
    required super.commissionRate,
    required super.commission,
    required super.commissionFormatted,
    required super.netAmount,
    required super.netAmountFormatted,
    required super.itemsCount,
    required super.quantityTotal,
  });

  factory SellerOrderTotalsModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderTotalsModel(
      subtotal: _parseDouble(json['subtotal']),
      subtotalFormatted: _parseString(json['subtotal_formatted'], '0 FCFA'),
      commissionRate: _parseDouble(json['commission_rate']),
      commission: _parseDouble(json['commission']),
      commissionFormatted: _parseString(json['commission_formatted'], '0 FCFA'),
      netAmount: _parseDouble(json['net_amount']),
      netAmountFormatted: _parseString(json['net_amount_formatted'], '0 FCFA'),
      itemsCount: _parseInt(json['items_count']),
      quantityTotal: _parseInt(json['quantity_total']),
    );
  }

  factory SellerOrderTotalsModel.fromEntity(SellerOrderTotals e) {
    return SellerOrderTotalsModel(
      subtotal: e.subtotal,
      subtotalFormatted: e.subtotalFormatted,
      commissionRate: e.commissionRate,
      commission: e.commission,
      commissionFormatted: e.commissionFormatted,
      netAmount: e.netAmount,
      netAmountFormatted: e.netAmountFormatted,
      itemsCount: e.itemsCount,
      quantityTotal: e.quantityTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'subtotal_formatted': subtotalFormatted,
      'commission_rate': commissionRate,
      'commission': commission,
      'commission_formatted': commissionFormatted,
      'net_amount': netAmount,
      'net_amount_formatted': netAmountFormatted,
      'items_count': itemsCount,
      'quantity_total': quantityTotal,
    };
  }
}

// ============================================
// MODEL : SellerOrderActionsSummaryModel
// ============================================

class SellerOrderActionsSummaryModel extends SellerOrderActionsSummary {
  const SellerOrderActionsSummaryModel({
    super.hasItemsToAccept,
    super.hasItemsToPrepare,
    super.hasItemsToShip,
    super.hasItemsToCancel,
    super.isFullyShipped,
    super.isFullyDelivered,
  });

  factory SellerOrderActionsSummaryModel.fromJson(Map<String, dynamic> json) {
    return SellerOrderActionsSummaryModel(
      hasItemsToAccept: _parseBool(json['has_items_to_accept']),
      hasItemsToPrepare: _parseBool(json['has_items_to_prepare']),
      hasItemsToShip: _parseBool(json['has_items_to_ship']),
      hasItemsToCancel: _parseBool(json['has_items_to_cancel']),
      isFullyShipped: _parseBool(json['is_fully_shipped']),
      isFullyDelivered: _parseBool(json['is_fully_delivered']),
    );
  }

  factory SellerOrderActionsSummaryModel.fromEntity(
    SellerOrderActionsSummary e,
  ) {
    return SellerOrderActionsSummaryModel(
      hasItemsToAccept: e.hasItemsToAccept,
      hasItemsToPrepare: e.hasItemsToPrepare,
      hasItemsToShip: e.hasItemsToShip,
      hasItemsToCancel: e.hasItemsToCancel,
      isFullyShipped: e.isFullyShipped,
      isFullyDelivered: e.isFullyDelivered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_items_to_accept': hasItemsToAccept,
      'has_items_to_prepare': hasItemsToPrepare,
      'has_items_to_ship': hasItemsToShip,
      'has_items_to_cancel': hasItemsToCancel,
      'is_fully_shipped': isFullyShipped,
      'is_fully_delivered': isFullyDelivered,
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