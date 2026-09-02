// ============================================
// ÉLÉMENT DE GRILLE PRODUIT - VERSION PREMIUM
// ============================================
// Design compact pour affichage en grille 2 colonnes.
// Image dominante (75-80%), badges, prix, note et stock.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final ValueChanged<Product>? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;
  final bool isFavorite;
  final bool showAddToCartButton;

  const ProductGridItem({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
    this.isFavorite = false,
    this.showAddToCartButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(product) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // IMAGE
            // ============================================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildProductImage(),
                  ),
                ),

                // Badge de réduction
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Badge nouveau
                if (product.isNew)
                  Positioned(
                    top: 8,
                    left: product.hasDiscount ? 50 : 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Nouveau',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Bouton favori
                if (onToggleFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                // Rupture de stock
                if (!product.isInStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: Colors.black.withValues(alpha: 0.6),
                      child: const Text(
                        'Rupture',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ============================================
            // INFORMATIONS
            // ============================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Prix
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            product.formattedCurrentPrice,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: product.hasDiscount
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              product.formattedPrice,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
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

                    // Note et stock
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (product.averageRating > 0) ...[
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: AppColors.ratingColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Color(product.stockColorHex),
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
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Color(product.stockColorHex),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // BOUTON AJOUTER COMPACT
            // ============================================
            if (showAddToCartButton && product.isInStock)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // IMAGE DU PRODUIT
  // ============================================

  Widget _buildProductImage() {
    final imageUrl = product.fullImageUrl.isNotEmpty
        ? product.fullImageUrl
        : product.mainImage ?? '';

    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.textLight,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surface,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 30,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}