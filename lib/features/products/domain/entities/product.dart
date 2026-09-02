// ============================================
// ENTITÉ PRODUCT (DOMAINE)
// ============================================
// Représente un produit dans la couche domaine.
// Design premium : variantes liées aux images,
// prix formatés FCFA, stock intelligent,
// badges contextuels, URLs sécurisées.
// ============================================

import 'category.dart';
import 'brand.dart';
import 'product_image.dart';

class Product {
  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;

  // Prix
  final double price;
  final double? discountPrice;
  final double currentPrice;
  final int? discountPercentage;

  // Stock
  final int stock;
  final bool isInStock;
  final String stockStatus;
  final int minStock;

  // SKU
  final String sku;
  final String? barcode;

  // Relations
  final Category? category;
  final Brand? brand;
  final List<ProductImage> images;

  // Image principale
  final String? mainImage;
  final String? mainImageThumbnail;

  // Statistiques
  final int viewsCount;
  final int salesCount;
  final int favoritesCount;
  final double averageRating;
  final int reviewsCount;

  // Badges
  final bool isFeatured;
  final bool isNew;
  final bool isBestseller;
  final bool isOnSale;

  // Disponibilité
  final bool isActive;
  final bool isAvailable;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  // Dates
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int? subcategoryId;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    required this.price,
    this.discountPrice,
    required this.currentPrice,
    this.discountPercentage,
    required this.stock,
    required this.isInStock,
    required this.stockStatus,
    this.minStock = 5,
    required this.sku,
    this.barcode,
    this.category,
    this.brand,
    this.images = const [],
    this.mainImage,
    this.mainImageThumbnail,
    this.viewsCount = 0,
    this.salesCount = 0,
    this.favoritesCount = 0,
    this.averageRating = 0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.isNew = false,
    this.isBestseller = false,
    this.isOnSale = false,
    this.isActive = true,
    this.isAvailable = true,
    this.availableFrom,
    this.availableUntil,
    this.createdAt,
    this.updatedAt,
    this.subcategoryId,
  });

  // ============================================
  // GETTERS PRIX
  // ============================================

  /// Prix formaté en FCFA
  String get formattedPrice => _formatPrice(price);

  /// Prix réduit formaté
  String? get formattedDiscountPrice {
    if (discountPrice == null) return null;
    return _formatPrice(discountPrice!);
  }

  /// Prix actuel formaté
  String get formattedCurrentPrice => _formatPrice(currentPrice);

  /// Le produit a-t-il une réduction ?
  bool get hasDiscount =>
      discountPrice != null && discountPrice! < price && discountPrice! > 0;

  /// Pourcentage de réduction recalculé (fiable)
  int get discountPercent {
    if (discountPercentage != null && discountPercentage! > 0) {
      return discountPercentage!;
    }
    if (hasDiscount) {
      return ((price - discountPrice!) / price * 100).round();
    }
    return 0;
  }

  /// Le produit est-il gratuit ?
  bool get isFree => price == 0 && currentPrice == 0;

  // ============================================
  // GETTERS STOCK
  // ============================================

  /// Label du stock
  String get stockLabel {
    switch (stockStatus) {
      case 'in_stock':
        return 'En stock';
      case 'low_stock':
        return stock > 0 ? 'Plus que $stock en stock' : 'Stock faible';
      case 'out_of_stock':
        return 'Rupture de stock';
      default:
        return 'Disponibilité inconnue';
    }
  }

  /// Couleur du stock (hex)
  int get stockColorHex {
    switch (stockStatus) {
      case 'in_stock':
        return 0xFF087F5B; // Emerald
      case 'low_stock':
        return 0xFFF4B942; // Gold
      case 'out_of_stock':
        return 0xFFFF6B6B; // Coral
      default:
        return 0xFF68756F; // Texte secondaire
    }
  }

  /// Stock faible (alerte visuelle)
  bool get isLowStock => stockStatus == 'low_stock' || (stock > 0 && stock <= minStock);

  /// En rupture
  bool get isOutOfStock => stockStatus == 'out_of_stock' || stock == 0;

  // ============================================
  // GETTERS BADGES
  // ============================================

  /// Liste des badges actifs du produit
  List<String> get activeBadges {
    final badges = <String>[];
    if (isOnSale && hasDiscount) badges.add('PROMO');
    if (isNew) badges.add('NOUVEAU');
    if (isBestseller) badges.add('BESTSELLER');
    if (isFeatured) badges.add('VEDETTE');
    return badges;
  }

  /// Le produit a-t-il au moins un badge ?
  bool get hasBadges => activeBadges.isNotEmpty;

  /// Badge principal (priorité)
  String? get primaryBadge {
    if (isOnSale && hasDiscount) return 'PROMO';
    if (isNew) return 'NOUVEAU';
    if (isBestseller) return 'BESTSELLER';
    if (isFeatured) return 'VEDETTE';
    return null;
  }

  // ============================================
  // GETTERS IMAGES
  // ============================================

  /// URL complète de l'image principale
  String get fullImageUrl {
    if (mainImage == null || mainImage!.isEmpty) return '';
    if (mainImage!.startsWith('http')) return mainImage!;
    return 'http://127.0.0.1:8000/storage/$mainImage';
  }

  /// URL complète de la miniature
  String get fullThumbnailUrl {
    if (mainImageThumbnail == null || mainImageThumbnail!.isEmpty) return '';
    if (mainImageThumbnail!.startsWith('http')) return mainImageThumbnail!;
    return 'http://127.0.0.1:8000/storage/$mainImageThumbnail';
  }

  /// Toutes les URLs des images (pour la galerie)
  List<String> get allImageUrls {
    if (images.isNotEmpty) {
      return images.map((img) => img.fullUrl).where((url) => url.isNotEmpty).toList();
    }
    if (fullImageUrl.isNotEmpty) return [fullImageUrl];
    return [];
  }

  /// Nombre d'images disponibles
  int get imageCount => allImageUrls.length;

  /// Le produit a-t-il plusieurs images ? (pour effet 360°)
  bool get hasMultipleImages => imageCount > 1;

  /// Image principale (pour compatibilité)
  String? get heroImage => allImageUrls.isNotEmpty ? allImageUrls.first : null;

  // ============================================
  // GETTERS DISPONIBILITÉ
  // ============================================

  /// Le produit est-il dans sa période de disponibilité ?
  bool get isInAvailabilityWindow {
    if (availableFrom != null && DateTime.now().isBefore(availableFrom!)) {
      return false;
    }
    if (availableUntil != null && DateTime.now().isAfter(availableUntil!)) {
      return false;
    }
    return true;
  }

  /// Le produit est-il réellement achetable ?
  bool get isPurchasable => isActive && isAvailable && isInStock && isInAvailabilityWindow;

  // ============================================
  // GETTERS NOTE
  // ============================================

  /// Note formatée (ex: 4.5)
  String get formattedRating => averageRating.toStringAsFixed(1);

  /// Note sur 5 étoiles (pour affichage)
  double get ratingOutOfFive => averageRating.clamp(0, 5).toDouble();

  /// Le produit a-t-il des avis ?
  bool get hasReviews => reviewsCount > 0;

  /// Nombre d'avis formaté (ex: 124)
  String get formattedReviewsCount {
    if (reviewsCount >= 1000) {
      return '${(reviewsCount / 1000).toStringAsFixed(1)}k';
    }
    return '$reviewsCount';
  }

  // ============================================
  // MÉTHODES
  // ============================================

  /// Formater un prix
  String _formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final parts = formatted.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      buffer.write(parts[i]);
      if ((parts.length - 1 - i) % 3 == 0 && i != parts.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer FCFA';
  }

  /// Copier avec modifications
  Product copyWith({
    int? id,
    String? name,
    String? slug,
    String? shortDescription,
    String? description,
    double? price,
    double? discountPrice,
    double? currentPrice,
    int? discountPercentage,
    int? stock,
    bool? isInStock,
    String? stockStatus,
    int? minStock,
    String? sku,
    String? barcode,
    Category? category,
    Brand? brand,
    List<ProductImage>? images,
    String? mainImage,
    String? mainImageThumbnail,
    int? viewsCount,
    int? salesCount,
    int? favoritesCount,
    double? averageRating,
    int? reviewsCount,
    bool? isFeatured,
    bool? isNew,
    bool? isBestseller,
    bool? isOnSale,
    bool? isActive,
    bool? isAvailable,
    DateTime? availableFrom,
    DateTime? availableUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? subcategoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      stock: stock ?? this.stock,
      isInStock: isInStock ?? this.isInStock,
      stockStatus: stockStatus ?? this.stockStatus,
      minStock: minStock ?? this.minStock,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      mainImage: mainImage ?? this.mainImage,
      mainImageThumbnail: mainImageThumbnail ?? this.mainImageThumbnail,
      viewsCount: viewsCount ?? this.viewsCount,
      salesCount: salesCount ?? this.salesCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      averageRating: averageRating ?? this.averageRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isBestseller: isBestseller ?? this.isBestseller,
      isOnSale: isOnSale ?? this.isOnSale,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subcategoryId: subcategoryId ?? this.subcategoryId,
    );
  }

  // ============================================
  // SÉCURITÉ & VALIDATION
  // ============================================

  /// Le produit a-t-il des données valides ?
  bool get isValid {
    return id > 0 &&
        name.isNotEmpty &&
        slug.isNotEmpty &&
        price >= 0 &&
        currentPrice >= 0;
  }

  /// Le produit a-t-il un prix incohérent ?
  bool get hasPriceError {
    return discountPrice != null && discountPrice! > price;
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $formattedPrice, '
        'stock: $stock, rating: $formattedRating, badges: $activeBadges)';
  }
}