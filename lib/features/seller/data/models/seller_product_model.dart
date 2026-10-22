// ============================================
// MODEL : SellerProductModel
// ============================================
// Modèle de sérialisation JSON pour SellerProduct.
//
// Responsabilités :
//   - Parser la réponse API (fromJson)
//   - Convertir en JSON pour le cache (toJson)
//   - Fournir des conversions sûres (num → double/int)
//   - Gérer les valeurs null et formats inattendus
//   - Fournir des fallbacks pour éviter les crashs UI
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Entity
import '../../domain/entities/seller_product.dart';

// ============================================
// MODEL PRINCIPAL
// ============================================

class SellerProductModel extends SellerProduct {
  const SellerProductModel({
    required super.id,
    required super.sellerId,
    required super.name,
    required super.slug,
    super.shortDescription,
    super.description,
    required super.price,
    required super.priceFormatted,
    super.discountPrice,
    super.discountPriceFormatted,
    required super.currentPrice,
    required super.currentPriceFormatted,
    super.discountPercentage,
    super.hasDiscount,
    required super.stock,
    super.minStock,
    super.maxStock,
    super.stockStatus,
    super.stockStatusLabel,
    super.isInStock,
    super.isLowStock,
    super.isOutOfStock,
    required super.sku,
    super.barcode,
    super.category,
    super.brand,
    super.categoryId,
    super.subcategoryId,
    super.brandId,
    super.mainImage,
    super.mainImageThumbnail,
    super.images,
    super.imagesCount,
    super.viewsCount,
    super.salesCount,
    super.favoritesCount,
    super.reviewsCount,
    super.averageRating,
    super.averageRatingFormatted,
    super.isFeatured,
    super.isNew,
    super.isBestseller,
    super.isOnSale,
    super.isDigital,
    super.badges,
    super.isActive,
    super.isAvailable,
    super.statusLabel,
    super.availableFrom,
    super.availableUntil,
    super.metaTitle,
    super.metaDescription,
    super.metaKeywords,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  // ============================================
  // JSON → MODEL
  // ============================================

  factory SellerProductModel.fromJson(Map<String, dynamic> json) {
    // Parse images
    final images = _parseImagesList(json['images']);

    return SellerProductModel(
      // Identifiants
      id: _parseInt(json['id']),
      sellerId: _parseInt(json['seller_id']),
      name: _parseString(json['name'], 'Produit sans nom'),
      slug: _parseString(json['slug']),
      shortDescription: _parseNullableString(json['short_description']),
      description: _parseNullableString(json['description']),

      // Prix
      price: _parseDouble(json['price']),
      priceFormatted: _parseString(json['price_formatted'], '0 FCFA'),
      discountPrice: _parseNullableDouble(json['discount_price']),
      discountPriceFormatted: _parseNullableString(json['discount_price_formatted']),
      currentPrice: _parseDouble(json['current_price'], defaultValue: _parseDouble(json['price'])),
      currentPriceFormatted: _parseString(
        json['current_price_formatted'],
        _parseString(json['price_formatted'], '0 FCFA'),
      ),
      discountPercentage: json['discount_percentage'] != null
          ? _parseInt(json['discount_percentage'])
          : null,
      hasDiscount: _parseBool(json['has_discount']),

      // Stock
      stock: _parseInt(json['stock']),
      minStock: _parseInt(json['min_stock'], defaultValue: 5),
      maxStock: json['max_stock'] != null ? _parseInt(json['max_stock']) : null,
      stockStatus: _parseString(json['stock_status'], 'in_stock'),
      stockStatusLabel: _parseString(json['stock_status_label'], 'En stock'),
      isInStock: _parseBool(json['is_in_stock'], defaultValue: _parseInt(json['stock']) > 0),
      isLowStock: _parseBool(json['is_low_stock']),
      isOutOfStock: _parseBool(json['is_out_of_stock'], defaultValue: _parseInt(json['stock']) <= 0),

      // Identifiants
      sku: _parseString(json['sku']),
      barcode: _parseNullableString(json['barcode']),

      // Relations
      category: json['category'] != null && json['category'] is Map
          ? SellerProductCategoryModel.fromJson(
              Map<String, dynamic>.from(json['category'] as Map),
            )
          : null,
      brand: json['brand'] != null && json['brand'] is Map
          ? SellerProductBrandModel.fromJson(
              Map<String, dynamic>.from(json['brand'] as Map),
            )
          : null,
      categoryId: json['category_id'] != null ? _parseInt(json['category_id']) : null,
      subcategoryId: json['subcategory_id'] != null ? _parseInt(json['subcategory_id']) : null,
      brandId: json['brand_id'] != null ? _parseInt(json['brand_id']) : null,

      // Images
      mainImage: _parseNullableString(json['main_image']),
      mainImageThumbnail: _parseNullableString(json['main_image_thumbnail']),
      images: images,
      imagesCount: json['images_count'] != null
          ? _parseInt(json['images_count'])
          : images.length,

      // Statistiques
      viewsCount: _parseInt(json['views_count']),
      salesCount: _parseInt(json['sales_count']),
      favoritesCount: _parseInt(json['favorites_count']),
      reviewsCount: _parseInt(json['reviews_count']),
      averageRating: _parseDouble(json['average_rating']),
      averageRatingFormatted: _parseString(json['average_rating_formatted'], '0.0'),

      // Badges
      isFeatured: _parseBool(json['is_featured']),
      isNew: _parseBool(json['is_new']),
      isBestseller: _parseBool(json['is_bestseller']),
      isOnSale: _parseBool(json['is_on_sale']),
      isDigital: _parseBool(json['is_digital']),
      badges: _parseStringList(json['badges']),

      // Disponibilité
      isActive: _parseBool(json['is_active']),
      isAvailable: _parseBool(json['is_available'], defaultValue: true),
      statusLabel: _parseString(json['status_label'], 'Brouillon'),
      availableFrom: _parseDate(json['available_from']),
      availableUntil: _parseDate(json['available_until']),

      // SEO
      metaTitle: _parseNullableString(json['meta_title']),
      metaDescription: _parseNullableString(json['meta_description']),
      metaKeywords: _parseNullableString(json['meta_keywords']),

      // Horodatage
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      deletedAt: _parseDate(json['deleted_at']),
    );
  }

  // ============================================
  // MODEL → JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'slug': slug,
      'short_description': shortDescription,
      'description': description,
      'price': price,
      'price_formatted': priceFormatted,
      'discount_price': discountPrice,
      'discount_price_formatted': discountPriceFormatted,
      'current_price': currentPrice,
      'current_price_formatted': currentPriceFormatted,
      'discount_percentage': discountPercentage,
      'has_discount': hasDiscount,
      'stock': stock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'stock_status': stockStatus,
      'stock_status_label': stockStatusLabel,
      'is_in_stock': isInStock,
      'is_low_stock': isLowStock,
      'is_out_of_stock': isOutOfStock,
      'sku': sku,
      'barcode': barcode,
      'category': category != null
          ? SellerProductCategoryModel.fromEntity(category!).toJson()
          : null,
      'brand': brand != null
          ? SellerProductBrandModel.fromEntity(brand!).toJson()
          : null,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'brand_id': brandId,
      'main_image': mainImage,
      'main_image_thumbnail': mainImageThumbnail,
      'images': images.map((img) => SellerProductImageModel.fromEntity(img).toJson()).toList(),
      'images_count': imagesCount,
      'views_count': viewsCount,
      'sales_count': salesCount,
      'favorites_count': favoritesCount,
      'reviews_count': reviewsCount,
      'average_rating': averageRating,
      'average_rating_formatted': averageRatingFormatted,
      'is_featured': isFeatured,
      'is_new': isNew,
      'is_bestseller': isBestseller,
      'is_on_sale': isOnSale,
      'is_digital': isDigital,
      'badges': badges,
      'is_active': isActive,
      'is_available': isAvailable,
      'status_label': statusLabel,
      'available_from': availableFrom?.toIso8601String(),
      'available_until': availableUntil?.toIso8601String(),
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // ============================================
  // HELPER : fromEntity
  // ============================================

  factory SellerProductModel.fromEntity(SellerProduct entity) {
    return SellerProductModel(
      id: entity.id,
      sellerId: entity.sellerId,
      name: entity.name,
      slug: entity.slug,
      shortDescription: entity.shortDescription,
      description: entity.description,
      price: entity.price,
      priceFormatted: entity.priceFormatted,
      discountPrice: entity.discountPrice,
      discountPriceFormatted: entity.discountPriceFormatted,
      currentPrice: entity.currentPrice,
      currentPriceFormatted: entity.currentPriceFormatted,
      discountPercentage: entity.discountPercentage,
      hasDiscount: entity.hasDiscount,
      stock: entity.stock,
      minStock: entity.minStock,
      maxStock: entity.maxStock,
      stockStatus: entity.stockStatus,
      stockStatusLabel: entity.stockStatusLabel,
      isInStock: entity.isInStock,
      isLowStock: entity.isLowStock,
      isOutOfStock: entity.isOutOfStock,
      sku: entity.sku,
      barcode: entity.barcode,
      category: entity.category,
      brand: entity.brand,
      categoryId: entity.categoryId,
      subcategoryId: entity.subcategoryId,
      brandId: entity.brandId,
      mainImage: entity.mainImage,
      mainImageThumbnail: entity.mainImageThumbnail,
      images: entity.images,
      imagesCount: entity.imagesCount,
      viewsCount: entity.viewsCount,
      salesCount: entity.salesCount,
      favoritesCount: entity.favoritesCount,
      reviewsCount: entity.reviewsCount,
      averageRating: entity.averageRating,
      averageRatingFormatted: entity.averageRatingFormatted,
      isFeatured: entity.isFeatured,
      isNew: entity.isNew,
      isBestseller: entity.isBestseller,
      isOnSale: entity.isOnSale,
      isDigital: entity.isDigital,
      badges: entity.badges,
      isActive: entity.isActive,
      isAvailable: entity.isAvailable,
      statusLabel: entity.statusLabel,
      availableFrom: entity.availableFrom,
      availableUntil: entity.availableUntil,
      metaTitle: entity.metaTitle,
      metaDescription: entity.metaDescription,
      metaKeywords: entity.metaKeywords,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }
}

// ============================================
// MODEL : SellerProductCategoryModel
// ============================================

class SellerProductCategoryModel extends SellerProductCategory {
  const SellerProductCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.image,
  });

  factory SellerProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return SellerProductCategoryModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Catégorie'),
      slug: _parseString(json['slug']),
      image: _parseNullableString(json['image']),
    );
  }

  factory SellerProductCategoryModel.fromEntity(SellerProductCategory entity) {
    return SellerProductCategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      image: entity.image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
    };
  }
}

// ============================================
// MODEL : SellerProductBrandModel
// ============================================

class SellerProductBrandModel extends SellerProductBrand {
  const SellerProductBrandModel({
    required super.id,
    required super.name,
    required super.slug,
    super.logo,
  });

  factory SellerProductBrandModel.fromJson(Map<String, dynamic> json) {
    return SellerProductBrandModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name'], 'Marque'),
      slug: _parseString(json['slug']),
      logo: _parseNullableString(json['logo']),
    );
  }

  factory SellerProductBrandModel.fromEntity(SellerProductBrand entity) {
    return SellerProductBrandModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      logo: entity.logo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo': logo,
    };
  }
}

// ============================================
// MODEL : SellerProductImageModel
// ============================================

class SellerProductImageModel extends SellerProductImage {
  const SellerProductImageModel({
    required super.id,
    required super.url,
    super.thumbnail,
    super.altText,
    super.position,
    super.isPrimary,
    super.width,
    super.height,
    super.fileSize,
  });

  factory SellerProductImageModel.fromJson(Map<String, dynamic> json) {
    return SellerProductImageModel(
      id: _parseInt(json['id']),
      url: _parseString(json['url']),
      thumbnail: _parseNullableString(json['thumbnail']),
      altText: _parseNullableString(json['alt_text']),
      position: _parseInt(json['position']),
      isPrimary: _parseBool(json['is_primary']),
      width: json['width'] != null ? _parseInt(json['width']) : null,
      height: json['height'] != null ? _parseInt(json['height']) : null,
      fileSize: json['file_size'] != null ? _parseInt(json['file_size']) : null,
    );
  }

  factory SellerProductImageModel.fromEntity(SellerProductImage entity) {
    return SellerProductImageModel(
      id: entity.id,
      url: entity.url,
      thumbnail: entity.thumbnail,
      altText: entity.altText,
      position: entity.position,
      isPrimary: entity.isPrimary,
      width: entity.width,
      height: entity.height,
      fileSize: entity.fileSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail': thumbnail,
      'alt_text': altText,
      'position': position,
      'is_primary': isPrimary,
      'width': width,
      'height': height,
      'file_size': fileSize,
    };
  }
}

// ============================================
// HELPERS DE PARSING SÉCURISÉS
// ============================================

/// Parse un entier avec fallback à 0.
int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Parse un double avec fallback à 0.
double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Parse un double nullable.
double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Parse une string avec fallback.
String _parseString(dynamic value, [String defaultValue = '']) {
  if (value == null) return defaultValue;
  return value.toString();
}

/// Parse une string nullable.
String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString();
  return str.isEmpty ? null : str;
}

/// Parse un bool avec fallback.
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

/// Parse une date (ISO 8601 ou null).
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Parse une liste de strings.
List<String> _parseStringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .where((e) => e != null)
      .map((e) => e.toString())
      .toList();
}

/// Parse une liste d'images.
List<SellerProductImage> _parseImagesList(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((e) => SellerProductImageModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}