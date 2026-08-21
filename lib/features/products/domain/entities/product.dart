// Entité Product (Domaine)
// Représente un produit dans la couche domaine

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
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Label du stock
  String get stockLabel {
    switch (stockStatus) {
      case 'in_stock':
        return 'En stock';
      case 'low_stock':
        return 'Stock faible';
      case 'out_of_stock':
        return 'Rupture de stock';
      default:
        return 'Inconnu';
    }
  }

  /// Couleur du stock
  int get stockColor {
    switch (stockStatus) {
      case 'in_stock':
        return 0xFF27AE60;
      case 'low_stock':
        return 0xFFF39C12;
      case 'out_of_stock':
        return 0xFFE74C3C;
      default:
        return 0xFF7F8C8D;
    }
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
    );
  }
}