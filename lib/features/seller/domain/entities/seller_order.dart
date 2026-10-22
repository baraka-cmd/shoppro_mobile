// ============================================
// ENTITÉ : SellerOrder
// ============================================
// Représente une commande du point de vue VENDEUR.
//
// Différence avec l'entité Order client :
//   - Le client voit TOUTE la commande (tous les items)
//   - Le vendeur ne voit QUE ses items (les autres sont filtrés côté backend)
//   - Le statut affiché est le statut global agrégé (recalculé par le serveur)
//   - Les totaux affichés sont UNIQUEMENT ceux du vendeur
//   - Le client est partiellement anonymisé (nom + ville)
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

class SellerOrder {
  // ============================================
  // IDENTIFIANTS
  // ============================================
  final int id;
  final String orderNumber;

  // ============================================
  // STATUTS
  // ============================================
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String currency;

  // ============================================
  // DATES
  // ============================================
  final DateTime? createdAt;
  final String? createdAtHuman;
  final DateTime? updatedAt;

  // ============================================
  // CLIENT (partiel pour respect vie privée)
  // ============================================
  final SellerOrderCustomer? customer;

  // ============================================
  // ADRESSE DE LIVRAISON (complète, pour expédition)
  // ============================================
  final SellerOrderAddress? shippingAddress;

  // ============================================
  // ITEMS (UNIQUEMENT ceux du vendeur)
  // ============================================
  final List<SellerOrderItem> items;

  // ============================================
  // TOTAUX DU VENDEUR (pas de la commande globale)
  // ============================================
  final SellerOrderTotals totals;

  // ============================================
  // RÉSUMÉ ACTIONS (pour badges UI)
  // ============================================
  final SellerOrderActionsSummary actionsSummary;

  // ============================================
  // NOTE CLIENT
  // ============================================
  final String? customerNote;

  const SellerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    this.currency = 'FCFA',
    this.createdAt,
    this.createdAtHuman,
    this.updatedAt,
    this.customer,
    this.shippingAddress,
    this.items = const [],
    required this.totals,
    required this.actionsSummary,
    this.customerNote,
  });

  // ============================================
  // GETTERS DE STATUT GLOBAL
  // ============================================

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';
  bool get isReturned => status == 'returned';

  bool get isActive =>
      status != 'delivered' &&
      status != 'cancelled' &&
      status != 'refunded' &&
      status != 'returned';

  bool get isPaid => paymentStatus == 'paid';

  // ============================================
  // GETTERS D'ACTIONS (raccourcis depuis actionsSummary)
  // ============================================

  /// Le vendeur doit accepter au moins un item.
  bool get hasItemsToAccept => actionsSummary.hasItemsToAccept;

  /// Le vendeur doit préparer au moins un item.
  bool get hasItemsToPrepare => actionsSummary.hasItemsToPrepare;

  /// Le vendeur doit expédier au moins un item.
  bool get hasItemsToShip => actionsSummary.hasItemsToShip;

  /// Le vendeur peut annuler au moins un item.
  bool get hasItemsToCancel => actionsSummary.hasItemsToCancel;

  /// Tous les items sont expédiés ou livrés.
  bool get isFullyShipped => actionsSummary.isFullyShipped;

  /// Tous les items sont livrés.
  bool get isFullyDelivered => actionsSummary.isFullyDelivered;

  /// Une action est-elle requise immédiatement ?
  bool get needsAction =>
      hasItemsToAccept || hasItemsToPrepare || hasItemsToShip;

  // ============================================
  // GETTERS ITEMS
  // ============================================

  int get itemsCount => items.length;
  int get totalQuantity => totals.quantityTotal;

  /// Le vendeur a-t-il des items dans cette commande ?
  bool get hasItems => items.isNotEmpty;

  // ============================================
  // GETTERS FINANCIERS
  // ============================================

  String get formattedSubtotal => totals.subtotalFormatted;
  String get formattedNetAmount => totals.netAmountFormatted;
  String get formattedCommission => totals.commissionFormatted;

  // ============================================
  // COPYWITH
  // ============================================

  SellerOrder copyWith({
    int? id,
    String? orderNumber,
    String? status,
    String? statusLabel,
    String? paymentStatus,
    String? paymentStatusLabel,
    String? currency,
    DateTime? createdAt,
    String? createdAtHuman,
    DateTime? updatedAt,
    SellerOrderCustomer? customer,
    SellerOrderAddress? shippingAddress,
    List<SellerOrderItem>? items,
    SellerOrderTotals? totals,
    SellerOrderActionsSummary? actionsSummary,
    String? customerNote,
  }) {
    return SellerOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentStatusLabel: paymentStatusLabel ?? this.paymentStatusLabel,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      createdAtHuman: createdAtHuman ?? this.createdAtHuman,
      updatedAt: updatedAt ?? this.updatedAt,
      customer: customer ?? this.customer,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      totals: totals ?? this.totals,
      actionsSummary: actionsSummary ?? this.actionsSummary,
      customerNote: customerNote ?? this.customerNote,
    );
  }

  @override
  String toString() {
    return 'SellerOrder(id: $id, number: $orderNumber, '
        'status: $statusLabel, items: $itemsCount, '
        'total: ${totals.subtotalFormatted})';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerOrderCustomer
// ============================================
// Représente le client (partiellement anonymisé).
// Le vendeur ne voit QUE le nom + la ville/pays.
// ============================================

class SellerOrderCustomer {
  final String name;
  final String? city;
  final String? country;

  const SellerOrderCustomer({
    required this.name,
    this.city,
    this.country,
  });

  /// Initiales pour l'avatar (ex: "Jean Dupont" → "JD").
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Localisation formatée (ex: "Douala, Cameroun").
  String get formattedLocation {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  bool get hasLocation => (city?.isNotEmpty ?? false) || (country?.isNotEmpty ?? false);

  @override
  String toString() => 'SellerOrderCustomer(name: $name, city: $city)';
}

// ============================================
// SOUS-ENTITÉ : SellerOrderAddress
// ============================================
// Adresse de livraison complète (pour expédition).
// ============================================

class SellerOrderAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country;
  final String? deliveryInstructions;

  const SellerOrderAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
    this.deliveryInstructions,
  });

  /// Adresse complète sur une ligne.
  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      if (state != null && state!.isNotEmpty) state!,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode!,
      country,
    ];
    return parts.join(', ');
  }

  /// Adresse courte (ville + pays).
  String get shortAddress => '$city, $country';

  bool get hasDeliveryInstructions =>
      deliveryInstructions != null && deliveryInstructions!.isNotEmpty;

  @override
  String toString() => 'SellerOrderAddress(fullName: $fullName, city: $city)';
}

// ============================================
// SOUS-ENTITÉ : SellerOrderItem
// ============================================
// Représente un article du vendeur dans la commande.
// ============================================

class SellerOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final String productSku;
  final int quantity;

  // Prix
  final double unitPrice;
  final String unitPriceFormatted;
  final double? discountPrice;
  final double totalPrice;
  final String totalPriceFormatted;

  // Variante
  final String? variantName;
  final String? variantColor;
  final String? variantSize;

  // Statut vendeur
  final String sellerStatus;
  final String sellerStatusLabel;
  final String sellerStatusColor;

  // Actions possibles (pré-calculées côté serveur)
  final bool canAccept;
  final bool canPrepare;
  final bool canShip;
  final bool canCancel;

  // Horodatage
  final DateTime? acceptedAt;
  final DateTime? shippedAt;

  const SellerOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.productSku,
    required this.quantity,
    required this.unitPrice,
    required this.unitPriceFormatted,
    this.discountPrice,
    required this.totalPrice,
    required this.totalPriceFormatted,
    this.variantName,
    this.variantColor,
    this.variantSize,
    required this.sellerStatus,
    required this.sellerStatusLabel,
    required this.sellerStatusColor,
    this.canAccept = false,
    this.canPrepare = false,
    this.canShip = false,
    this.canCancel = false,
    this.acceptedAt,
    this.shippedAt,
  });

  // ============================================
  // GETTERS VARIANTE
  // ============================================

  bool get hasVariant =>
      (variantColor?.isNotEmpty ?? false) ||
      (variantSize?.isNotEmpty ?? false) ||
      (variantName?.isNotEmpty ?? false);

  /// Label des variantes (ex: "Noir • 256 Go").
  String get variantLabel {
    final parts = <String>[];
    if (variantColor != null && variantColor!.isNotEmpty) parts.add(variantColor!);
    if (variantSize != null && variantSize!.isNotEmpty) parts.add(variantSize!);
    if (variantName != null && variantName!.isNotEmpty) parts.add(variantName!);
    return parts.join(' • ');
  }

  // ============================================
  // GETTERS IMAGE
  // ============================================

  bool get hasImage =>
      productImageUrl != null && productImageUrl!.isNotEmpty;

  // ============================================
  // GETTERS STATUT
  // ============================================

  bool get isToAccept => sellerStatus == 'to_accept';
  bool get isAccepted => sellerStatus == 'accepted';
  bool get isPreparing => sellerStatus == 'preparing';
  bool get isReadyToShip => sellerStatus == 'ready_to_ship';
  bool get isShipped => sellerStatus == 'shipped';
  bool get isDelivered => sellerStatus == 'delivered';
  bool get isCancelled => sellerStatus == 'cancelled';
  bool get isRejected => sellerStatus == 'rejected';

  // ============================================
  // GETTERS DISCOUNT
  // ============================================

  bool get hasDiscount =>
      discountPrice != null && discountPrice! > 0 && discountPrice! < unitPrice;

  double get savings => hasDiscount ? (unitPrice - discountPrice!) * quantity : 0;

  @override
  String toString() {
    return 'SellerOrderItem(id: $id, product: $productName, '
        'qty: $quantity, status: $sellerStatusLabel)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerOrderTotals
// ============================================
// Totaux financiers UNIQUEMENT pour les items du vendeur.
// ============================================

class SellerOrderTotals {
  final double subtotal;
  final String subtotalFormatted;
  final double commissionRate;
  final double commission;
  final String commissionFormatted;
  final double netAmount;
  final String netAmountFormatted;
  final int itemsCount;
  final int quantityTotal;

  const SellerOrderTotals({
    required this.subtotal,
    required this.subtotalFormatted,
    required this.commissionRate,
    required this.commission,
    required this.commissionFormatted,
    required this.netAmount,
    required this.netAmountFormatted,
    required this.itemsCount,
    required this.quantityTotal,
  });

  const SellerOrderTotals.empty()
      : subtotal = 0,
        subtotalFormatted = '0 FCFA',
        commissionRate = 0,
        commission = 0,
        commissionFormatted = '0 FCFA',
        netAmount = 0,
        netAmountFormatted = '0 FCFA',
        itemsCount = 0,
        quantityTotal = 0;

  @override
  String toString() =>
      'SellerOrderTotals(subtotal: $subtotalFormatted, net: $netAmountFormatted)';
}

// ============================================
// SOUS-ENTITÉ : SellerOrderActionsSummary
// ============================================
// Résumé des actions possibles sur les items du vendeur.
// ============================================

class SellerOrderActionsSummary {
  final bool hasItemsToAccept;
  final bool hasItemsToPrepare;
  final bool hasItemsToShip;
  final bool hasItemsToCancel;
  final bool isFullyShipped;
  final bool isFullyDelivered;

  const SellerOrderActionsSummary({
    this.hasItemsToAccept = false,
    this.hasItemsToPrepare = false,
    this.hasItemsToShip = false,
    this.hasItemsToCancel = false,
    this.isFullyShipped = false,
    this.isFullyDelivered = false,
  });

  const SellerOrderActionsSummary.empty()
      : hasItemsToAccept = false,
        hasItemsToPrepare = false,
        hasItemsToShip = false,
        hasItemsToCancel = false,
        isFullyShipped = false,
        isFullyDelivered = false;

  @override
  String toString() =>
      'SellerOrderActionsSummary(accept: $hasItemsToAccept, ship: $hasItemsToShip)';
}