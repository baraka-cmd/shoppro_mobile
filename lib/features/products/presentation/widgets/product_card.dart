// Carte produit standard
// Design moderne avec image, badges, prix et actions

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<Product>? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(product) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badges
            Stack(
              children: [
                // Image du produit
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildProductImage(),
                  ),
                ),

                // Badges
                Positioned(
                  top: 10,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.hasDiscount)
                        _buildDiscountBadge(product.discountPercentage),
                      if (product.isNew) ...[
                        const SizedBox(height: 4),
                        _buildNewBadge(),
                      ],
                      if (product.isBestseller) ...[
                        const SizedBox(height: 4),
                        _buildBestsellerBadge(),
                      ],
                    ],
                  ),
                ),

                // Bouton favori
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                // Indicateur de stock
                if (!product.isInStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      color: Colors.black.withValues(alpha: 0.6),
                      child: const Text(
                        'Rupture de stock',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Informations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du produit
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Prix
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.formattedCurrentPrice,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: product.hasDiscount
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              product.formattedPrice,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // Note + stock
Row(
  mainAxisSize: MainAxisSize.min,  // ✅ AJOUTER
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    if (product.averageRating > 0) ...[
      const Icon(
        Icons.star,
        size: 12,  // ✅ RÉDUIRE de 14 à 12
        color: AppColors.ratingColor,
      ),
      const SizedBox(width: 2),
      Text(
        product.averageRating.toStringAsFixed(1),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,  // ✅ RÉDUIRE de 11 à 10
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(width: 4),
    ],
    Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: Color(product.stockColor),
        shape: BoxShape.circle,
      ),
    ),
    const SizedBox(width: 2),
    Flexible(
      child: Text(
        product.stockLabel,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,  // ✅ RÉDUIRE de 10 à 9
          fontWeight: FontWeight.w500,
          color: Color(product.stockColor),
        ),
      ),
    ),
  ],
),
                  ],
                ),
              ),
            ),

            // Bouton ajouter au panier
            if (product.isInStock)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ElevatedButton(
                  onPressed: onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_shopping_cart, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Ajouter',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Construire l'image du produit
  Widget _buildProductImage() {
    final imageUrl = (product as dynamic).fullImageUrl ?? product.mainImage ?? '';

    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Icon(
          Icons.image,
          size: 50,
          color: AppColors.textLight,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.background,
        child: const Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.background,
        child: const Icon(
          Icons.broken_image,
          size: 40,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  // Badge de réduction
  Widget _buildDiscountBadge(int? percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '-$percentage%',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Badge nouveau
  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Nouveau',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Badge bestseller
  Widget _buildBestsellerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Best-seller',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}