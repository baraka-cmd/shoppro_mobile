// ============================================
// ENTITÉ : SellerProduct
// ============================================
// Représente un produit côté vendeur.
// Cette entité est une vue "vendeur" du produit,
// qui inclut des champs supplémentaires (statut, actions possibles)
// et masque les champs sensibles côté client.
//
// Aucune dépendance Flutter : entité PURE Dart.
// ============================================

class SellerProduct {
  // ============================================
  // IDENTIFIANTS
  // ============================================
  final int id;
  final int sellerId;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;

  // ============================================
  // PRIX
  // ============================================
  final double price;
  final String priceFormatted;
  final double? discountPrice;
  final String? discountPriceFormatted;
  final double currentPrice;
  final String currentPriceFormatted;
  final int? discountPercentage;
  final bool hasDiscount;

  // ============================================
  // STOCK
  // ============================================
  final int stock;
  final int minStock;
  final int? maxStock;
  final String stockStatus;
  final String stockStatusLabel;
  final bool isInStock;
  final bool isLowStock;
  final bool isOutOfStock;

  // ============================================
  // IDENTIFIANTS PRODUIT
  // ============================================
  final String sku;
  final String? barcode;

  // ============================================
  // RELATIONS
  // ============================================
  final SellerProductCategory? category;
  final SellerProductBrand? brand;
  final int? categoryId;
  final int? subcategoryId;
  final int? brandId;

  // ============================================
  // IMAGES
  // ============================================
  final String? mainImage;
  final String? mainImageThumbnail;
  final List<SellerProductImage> images;
  final int imagesCount;

  // ============================================
  // STATISTIQUES
  // ============================================
  final int viewsCount;
  final int salesCount;
  final int favoritesCount;
  final int reviewsCount;
  final double averageRating;
  final String averageRatingFormatted;

  // ============================================
  // BADGES
  // ============================================
  final bool isFeatured;
  final bool isNew;
  final bool isBestseller;
  final bool isOnSale;
  final bool isDigital;
  final List<String> badges;

  // ============================================
  // DISPONIBILITÉ
  // ============================================
  final bool isActive;
  final bool isAvailable;
  final String statusLabel;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  // ============================================
  // SEO
  // ============================================
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;

  // ============================================
  // HORODATAGE
  // ============================================
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const SellerProduct({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    required this.price,
    required this.priceFormatted,
    this.discountPrice,
    this.discountPriceFormatted,
    required this.currentPrice,
    required this.currentPriceFormatted,
    this.discountPercentage,
    this.hasDiscount = false,
    required this.stock,
    this.minStock = 5,
    this.maxStock,
    this.stockStatus = 'in_stock',
    this.stockStatusLabel = 'En stock',
    this.isInStock = true,
    this.isLowStock = false,
    this.isOutOfStock = false,
    required this.sku,
    this.barcode,
    this.category,
    this.brand,
    this.categoryId,
    this.subcategoryId,
    this.brandId,
    this.mainImage,
    this.mainImageThumbnail,
    this.images = const [],
    this.imagesCount = 0,
    this.viewsCount = 0,
    this.salesCount = 0,
    this.favoritesCount = 0,
    this.reviewsCount = 0,
    this.averageRating = 0,
    this.averageRatingFormatted = '0.0',
    this.isFeatured = false,
    this.isNew = false,
    this.isBestseller = false,
    this.isOnSale = false,
    this.isDigital = false,
    this.badges = const [],
    this.isActive = false,
    this.isAvailable = true,
    this.statusLabel = 'Brouillon',
    this.availableFrom,
    this.availableUntil,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // ============================================
  // GETTERS MÉTIER
  // ============================================

  /// Le produit est-il en brouillon ?
  bool get isDraft => !isActive && deletedAt == null;

  /// Le produit est-il publié ?
  bool get isPublished => isActive && deletedAt == null;

  /// Le produit est-il archivé ?
  bool get isArchived => deletedAt != null;

  /// Le produit peut-il être publié ?
  /// Conditions : brouillon + prix > 0 + catégorie + au moins 1 image
  bool get canBePublished =>
      isDraft &&
      price > 0 &&
      categoryId != null &&
      imagesCount > 0;

  /// Le produit a-t-il des images ?
  bool get hasImages => images.isNotEmpty || mainImage != null;

  /// Le produit peut-il être supprimé (archivé) ?
  /// Impossible s'il a déjà été vendu
  bool get canBeDeleted => salesCount == 0;

  // ============================================
  // GETTERS IMAGES
  // ============================================

  /// URL complète de l'image principale.
  String get fullMainImageUrl {
    if (mainImage == null || mainImage!.isEmpty) return '';
    if (mainImage!.startsWith('http')) return mainImage!;
    return 'http://127.0.0.1:8001/storage/$mainImage';
  }

  /// Toutes les URLs des images (pour la galerie).
  List<String> get allImageUrls {
    if (images.isNotEmpty) {
      return images.map((img) => img.url).toList();
    }
    if (fullMainImageUrl.isNotEmpty) return [fullMainImageUrl];
    return [];
  }

  /// L'image principale (fallback sur la première image de la galerie).
  String? get heroImage {
    if (mainImage != null && mainImage!.isNotEmpty) {
      return fullMainImageUrl;
    }
    if (images.isNotEmpty) {
      return images.first.url;
    }
    return null;
  }

  // ============================================
  // GETTERS STATISTIQUES
  // ============================================

  /// Nombre de ventes formaté (ex: "1.2k").
  String get formattedSalesCount {
    if (salesCount >= 1000) {
      return '${(salesCount / 1000).toStringAsFixed(1)}k';
    }
    return salesCount.toString();
  }

  /// Nombre de vues formaté (ex: "1.5k").
  String get formattedViewsCount {
    if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}k';
    }
    return viewsCount.toString();
  }

  // ============================================
  // COPYWITH
  // ============================================

  SellerProduct copyWith({
    int? id,
    int? sellerId,
    String? name,
    String? slug,
    String? shortDescription,
    String? description,
    double? price,
    String? priceFormatted,
    double? discountPrice,
    String? discountPriceFormatted,
    double? currentPrice,
    String? currentPriceFormatted,
    int? discountPercentage,
    bool? hasDiscount,
    int? stock,
    int? minStock,
    int? maxStock,
    String? stockStatus,
    String? stockStatusLabel,
    bool? isInStock,
    bool? isLowStock,
    bool? isOutOfStock,
    String? sku,
    String? barcode,
    SellerProductCategory? category,
    SellerProductBrand? brand,
    int? categoryId,
    int? subcategoryId,
    int? brandId,
    String? mainImage,
    String? mainImageThumbnail,
    List<SellerProductImage>? images,
    int? imagesCount,
    int? viewsCount,
    int? salesCount,
    int? favoritesCount,
    int? reviewsCount,
    double? averageRating,
    String? averageRatingFormatted,
    bool? isFeatured,
    bool? isNew,
    bool? isBestseller,
    bool? isOnSale,
    bool? isDigital,
    List<String>? badges,
    bool? isActive,
    bool? isAvailable,
    String? statusLabel,
    DateTime? availableFrom,
    DateTime? availableUntil,
    String? metaTitle,
    String? metaDescription,
    String? metaKeywords,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return SellerProduct(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      price: price ?? this.price,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      discountPrice: discountPrice ?? this.discountPrice,
      discountPriceFormatted: discountPriceFormatted ?? this.discountPriceFormatted,
      currentPrice: currentPrice ?? this.currentPrice,
      currentPriceFormatted: currentPriceFormatted ?? this.currentPriceFormatted,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      stockStatus: stockStatus ?? this.stockStatus,
      stockStatusLabel: stockStatusLabel ?? this.stockStatusLabel,
      isInStock: isInStock ?? this.isInStock,
      isLowStock: isLowStock ?? this.isLowStock,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      brandId: brandId ?? this.brandId,
      mainImage: mainImage ?? this.mainImage,
      mainImageThumbnail: mainImageThumbnail ?? this.mainImageThumbnail,
      images: images ?? this.images,
      imagesCount: imagesCount ?? this.imagesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      salesCount: salesCount ?? this.salesCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      averageRating: averageRating ?? this.averageRating,
      averageRatingFormatted: averageRatingFormatted ?? this.averageRatingFormatted,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isBestseller: isBestseller ?? this.isBestseller,
      isOnSale: isOnSale ?? this.isOnSale,
      isDigital: isDigital ?? this.isDigital,
      badges: badges ?? this.badges,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      statusLabel: statusLabel ?? this.statusLabel,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      metaKeywords: metaKeywords ?? this.metaKeywords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SellerProduct(id: $id, name: $name, status: $statusLabel, '
        'stock: $stock, price: $priceFormatted, images: $imagesCount)';
  }
}

// ============================================
// SOUS-ENTITÉ : SellerProductCategory
// ============================================
class SellerProductCategory {
  final int id;
  final String name;
  final String slug;
  final String? image;

  const SellerProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
  });

  @override
  String toString() => 'SellerProductCategory($name)';
}

// ============================================
// SOUS-ENTITÉ : SellerProductBrand
// ============================================
class SellerProductBrand {
  final int id;
  final String name;
  final String slug;
  final String? logo;

  const SellerProductBrand({
    required this.id,
    required this.name,
    required this.slug,
    this.logo,
  });

  @override
  String toString() => 'SellerProductBrand($name)';
}

// ============================================
// SOUS-ENTITÉ : SellerProductImage
// ============================================
class SellerProductImage {
  final int id;
  final String url;
  final String? thumbnail;
  final String? altText;
  final int position;
  final bool isPrimary;
  final int? width;
  final int? height;
  final int? fileSize;

  const SellerProductImage({
    required this.id,
    required this.url,
    this.thumbnail,
    this.altText,
    this.position = 0,
    this.isPrimary = false,
    this.width,
    this.height,
    this.fileSize,
  });

  @override
  String toString() => 'SellerProductImage($id, position: $position)';
}