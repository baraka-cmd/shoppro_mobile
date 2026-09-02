// ============================================
// MODÈLE PRODUCT (DATA)
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste, valeurs par défaut
// et validation des données.
// ============================================

import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';
import 'category_model.dart';
import 'brand_model.dart';
import 'product_image_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.slug,
    super.shortDescription,
    super.description,
    required super.price,
    super.discountPrice,
    required super.currentPrice,
    super.discountPercentage,
    required super.stock,
    required super.isInStock,
    required super.stockStatus,
    super.minStock,
    required super.sku,
    super.barcode,
    super.category,
    super.brand,
    super.images,
    super.mainImage,
    super.mainImageThumbnail,
    super.viewsCount,
    super.salesCount,
    super.favoritesCount,
    super.averageRating,
    super.reviewsCount,
    super.isFeatured,
    super.isNew,
    super.isBestseller,
    super.isOnSale,
    super.isActive,
    super.isAvailable,
    super.availableFrom,
    super.availableUntil,
    super.createdAt,
    super.updatedAt,
    super.subcategoryId,
  });

  /// Créer un ProductModel depuis JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      shortDescription: _parseNullableString(json['short_description']),
      description: _parseNullableString(json['description']),

      // Prix
      price: _parseDouble(json['price']),
      discountPrice: _parseNullableDouble(json['discount_price']),
      currentPrice: _parseDouble(json['current_price'] ?? json['price']),
      discountPercentage: _parseNullableInt(json['discount_percentage']),

      // Stock
      stock: _parseInt(json['stock']),
      isInStock: _parseBool(json['is_in_stock']),
      stockStatus: _parseString(json['stock_status'], defaultValue: 'out_of_stock'),
      minStock: _parseInt(json['min_stock'], defaultValue: 5),

      // SKU
      sku: _parseString(json['sku']),
      barcode: _parseNullableString(json['barcode']),

      // Relations
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      brand: json['brand'] is Map<String, dynamic>
          ? BrandModel.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      images: _parseImages(json['images']),

      // Image principale
      mainImage: _parseNullableString(json['main_image']),
      mainImageThumbnail: _parseNullableString(json['main_image_thumbnail']),

      // Statistiques
      viewsCount: _parseInt(json['views_count']),
      salesCount: _parseInt(json['sales_count']),
      favoritesCount: _parseInt(json['favorites_count']),
      averageRating: _parseDouble(json['average_rating']),
      reviewsCount: _parseInt(json['reviews_count']),

      // Badges
      isFeatured: _parseBool(json['is_featured']),
      isNew: _parseBool(json['is_new']),
      isBestseller: _parseBool(json['is_bestseller']),
      isOnSale: _parseBool(json['is_on_sale']),

      // Disponibilité
      isActive: _parseBool(json['is_active'], defaultValue: true),
      isAvailable: _parseBool(json['is_available'], defaultValue: true),
      availableFrom: _parseDate(json['available_from']),
      availableUntil: _parseDate(json['available_until']),

      // Dates
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      subcategoryId: _parseNullableInt(json['subcategory_id']),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'short_description': shortDescription,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'current_price': currentPrice,
      'discount_percentage': discountPercentage,
      'stock': stock,
      'is_in_stock': isInStock,
      'stock_status': stockStatus,
      'min_stock': minStock,
      'sku': sku,
      'barcode': barcode,
      'category': category is CategoryModel
          ? (category as CategoryModel).toJson()
          : null,
      'brand': brand is BrandModel
          ? (brand as BrandModel).toJson()
          : null,
      'images': images
          .whereType<ProductImageModel>()
          .map((image) => image.toJson())
          .toList(),
      'main_image': mainImage,
      'main_image_thumbnail': mainImageThumbnail,
      'views_count': viewsCount,
      'sales_count': salesCount,
      'favorites_count': favoritesCount,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'is_featured': isFeatured,
      'is_new': isNew,
      'is_bestseller': isBestseller,
      'is_on_sale': isOnSale,
      'is_active': isActive,
      'is_available': isAvailable,
      'available_from': availableFrom?.toIso8601String(),
      'available_until': availableUntil?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'subcategory_id': subcategoryId,
    };
  }

  /// Copier depuis l'entité
  static ProductModel fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      slug: product.slug,
      shortDescription: product.shortDescription,
      description: product.description,
      price: product.price,
      discountPrice: product.discountPrice,
      currentPrice: product.currentPrice,
      discountPercentage: product.discountPercentage,
      stock: product.stock,
      isInStock: product.isInStock,
      stockStatus: product.stockStatus,
      minStock: product.minStock,
      sku: product.sku,
      barcode: product.barcode,
      category: product.category,
      brand: product.brand,
      images: product.images,
      mainImage: product.mainImage,
      mainImageThumbnail: product.mainImageThumbnail,
      viewsCount: product.viewsCount,
      salesCount: product.salesCount,
      favoritesCount: product.favoritesCount,
      averageRating: product.averageRating,
      reviewsCount: product.reviewsCount,
      isFeatured: product.isFeatured,
      isNew: product.isNew,
      isBestseller: product.isBestseller,
      isOnSale: product.isOnSale,
      isActive: product.isActive,
      isAvailable: product.isAvailable,
      availableFrom: product.availableFrom,
      availableUntil: product.availableUntil,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      subcategoryId: product.subcategoryId,
    );
  }

  // ============================================
  // HELPERS DE PARSING SÉCURISÉS
  // ============================================

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    final string = value.toString().trim();
    return string.isEmpty ? defaultValue : string;
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Parser les images
  static List<ProductImage> _parseImages(dynamic imagesJson) {
    if (imagesJson is! List) return [];

    return imagesJson
        .whereType<Map<String, dynamic>>()
        .map((imageJson) => ProductImageModel.fromJson(imageJson))
        .toList();
  }
}