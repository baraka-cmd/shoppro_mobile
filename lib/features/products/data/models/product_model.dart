// Modèle Product (Data)
// Gère la sérialisation/désérialisation JSON du produit

import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/brand.dart';
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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      
      // Prix
      price: _parseDouble(json['price']),
      discountPrice: _parseNullableDouble(json['discount_price']),
      currentPrice: _parseDouble(json['current_price'] ?? json['price']),
      discountPercentage: json['discount_percentage'] as int?,
      
      // Stock
      stock: json['stock'] as int? ?? 0,
      isInStock: json['is_in_stock'] as bool? ?? false,
      stockStatus: json['stock_status'] as String? ?? 'out_of_stock',
      minStock: json['min_stock'] as int? ?? 5,
      
      // SKU
      sku: json['sku'] as String? ?? '',
      barcode: json['barcode'] as String?,
      
      // Relations
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      brand: json['brand'] != null
          ? BrandModel.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      images: _parseImages(json['images']),
      
      // Image principale
      mainImage: json['main_image'] as String?,
      mainImageThumbnail: json['main_image_thumbnail'] as String?,
      
      // Statistiques
      viewsCount: json['views_count'] as int? ?? 0,
      salesCount: json['sales_count'] as int? ?? 0,
      favoritesCount: json['favorites_count'] as int? ?? 0,
      averageRating: _parseDouble(json['average_rating']),
      reviewsCount: json['reviews_count'] as int? ?? 0,
      
      // Badges
      isFeatured: json['is_featured'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      isBestseller: json['is_bestseller'] as bool? ?? false,
      isOnSale: json['is_on_sale'] as bool? ?? false,
      
      // Disponibilité
      isActive: json['is_active'] as bool? ?? true,
      isAvailable: json['is_available'] as bool? ?? true,
      availableFrom: json['available_from'] != null
          ? DateTime.tryParse(json['available_from'] as String)
          : null,
      availableUntil: json['available_until'] != null
          ? DateTime.tryParse(json['available_until'] as String)
          : null,
      
      // Dates
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      subcategoryId: json['subcategory_id'] as int?,
    );
  }

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
      'category': category != null ? (category as CategoryModel).toJson() : null,
      'brand': brand != null ? (brand as BrandModel).toJson() : null,
      'images': images.map((image) => (image as ProductImageModel).toJson()).toList(),
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
    };
  }

  /// Parser un double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Parser un double nullable
  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parser les images
static List<ProductImage> _parseImages(dynamic imagesJson) {
  if (imagesJson == null || imagesJson is! List) {
    return [];
  }

  final images = <ProductImage>[];
  
  for (final imageJson in imagesJson) {
    if (imageJson is Map<String, dynamic>) {
      images.add(ProductImageModel.fromJson(imageJson) as ProductImage);
    }
  }
  
  return images;
}
}