// ============================================
// ENTITÉ CART (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente le panier d'achat complet avec
// calculs intelligents, livraison gratuite
// et formatage FCFA. Design ShopPro.
// ============================================

import 'cart_item.dart';

class Cart {
  final List<CartItem> items;
  final String? couponCode;
  final double couponDiscount;
  final double shippingFee;
  final double taxRate;
  final String currency;

  const Cart({
    this.items = const [],
    this.couponCode,
    this.couponDiscount = 0,
    this.shippingFee = 2000,
    this.taxRate = 0,
    this.currency = 'FCFA',
  });

  // ============================================
  // ARTICLES
  // ============================================

  /// Articles actifs (pas sauvegardés pour plus tard)
  List<CartItem> get activeItems {
    return items.where((item) => !item.isSavedForLater).toList();
  }

  /// Articles sauvegardés pour plus tard
  List<CartItem> get savedForLaterItems {
    return items.where((item) => item.isSavedForLater).toList();
  }

  /// Le panier a-t-il des articles sauvegardés ?
  bool get hasSavedForLaterItems => savedForLaterItems.isNotEmpty;

  // ============================================
  // COMPTEURS
  // ============================================

  /// Nombre total d'articles (somme des quantités)
  int get totalQuantity {
    return activeItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Nombre d'articles uniques
  int get totalItems {
    return activeItems.length;
  }

  /// Le panier est-il vide ?
  bool get isEmpty => activeItems.isEmpty;

  /// Le panier a-t-il un code promo appliqué ?
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  /// Le panier a-t-il une réduction ?
  bool get hasDiscount => totalDiscount > 0;

  // ============================================
  // CALCULS FINANCIERS
  // ============================================

  /// Sous-total (avant réduction et livraison)
  double get subtotal {
    return activeItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Montant de la remise (réductions produits)
  double get itemsDiscount {
    return activeItems.fold(0, (sum, item) {
      if (item.hasDiscount) {
        return sum + ((item.unitPrice - item.discountPrice!) * item.quantity);
      }
      return sum;
    });
  }

  /// Remise totale (produits + coupon)
  double get totalDiscount {
    return itemsDiscount + couponDiscount;
  }

  /// Taxes calculées
  double get taxes {
    return (subtotal - couponDiscount) * taxRate;
  }

  /// Frais de livraison (gratuit si seuil atteint)
  double get effectiveShippingFee {
    if (subtotal >= freeShippingThreshold) return 0;
    return shippingFee;
  }

  /// Total final
  double get total {
    return subtotal - couponDiscount + taxes + effectiveShippingFee;
  }

  /// Total à payer (minimum 0)
  double get safeTotal {
    return total < 0 ? 0 : total;
  }

  // ============================================
  // LIVRAISON GRATUITE
  // ============================================

  /// Seuil de livraison gratuite
  static const double freeShippingThreshold = 50000;

  /// La livraison gratuite est-elle activée ?
  bool get hasFreeShipping => subtotal >= freeShippingThreshold;

  /// Progression vers la livraison gratuite (0.0 à 1.0)
  double get freeShippingProgress {
    if (hasFreeShipping) return 1.0;
    return (subtotal / freeShippingThreshold).clamp(0.0, 1.0);
  }

  /// Pourcentage de progression (0 à 100)
  int get freeShippingPercentage {
    return (freeShippingProgress * 100).round();
  }

  /// Montant restant pour la livraison gratuite
  double get remainingForFreeShipping {
    if (hasFreeShipping) return 0;
    return freeShippingThreshold - subtotal;
  }

  /// Montant restant formaté
  String get formattedRemainingForFreeShipping {
    return _formatPrice(remainingForFreeShipping);
  }

  // ============================================
  // FORMATAGE
  // ============================================

  /// Sous-total formaté
  String get formattedSubtotal => _formatPrice(subtotal);

  /// Remise produits formatée
  String get formattedItemsDiscount => _formatPrice(itemsDiscount);

  /// Remise coupon formatée
  String get formattedCouponDiscount => _formatPrice(couponDiscount);

  /// Remise totale formatée
  String get formattedDiscount => _formatPrice(totalDiscount);

  /// Taxes formatées
  String get formattedTaxes => _formatPrice(taxes);

  /// Livraison formatée
  String get formattedShippingFee {
    if (effectiveShippingFee == 0) return 'Gratuite';
    return _formatPrice(effectiveShippingFee);
  }

  /// Total formaté
  String get formattedTotal => _formatPrice(total);

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
    return '$buffer $currency';
  }

  // ============================================
  // VALIDATION
  // ============================================

  /// Le panier a-t-il des données valides ?
  bool get isValid {
    if (items.isEmpty) return true;
    return items.every((item) => item.isValid);
  }

  /// Le panier a-t-il un prix incohérent ?
  bool get hasPriceError {
    return total < 0;
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  Cart copyWith({
    List<CartItem>? items,
    String? couponCode,
    double? couponDiscount,
    double? shippingFee,
    double? taxRate,
    String? currency,
  }) {
    return Cart(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      shippingFee: shippingFee ?? this.shippingFee,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'coupon_code': couponCode,
      'coupon_discount': couponDiscount,
      'shipping_fee': shippingFee,
      'tax_rate': taxRate,
      'currency': currency,
    };
  }

  /// Créer depuis JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((itemJson) => CartItem.fromJson(itemJson))
          .toList(),
      couponCode: json['coupon_code'] as String?,
      couponDiscount: (json['coupon_discount'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 2000,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'FCFA',
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'Cart(items: ${totalItems}, quantity: $totalQuantity, '
        'subtotal: $formattedSubtotal, total: $formattedTotal, '
        'coupon: $couponCode, freeShipping: $hasFreeShipping)';
  }
}