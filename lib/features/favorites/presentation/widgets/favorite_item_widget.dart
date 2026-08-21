// Widget d'élément favori
// Affiche le produit avec actions rapides

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/favorite.dart';

class FavoriteItemWidget extends StatelessWidget {
  final Favorite favorite;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemove;
  final VoidCallback? onTogglePriceAlert;

  const FavoriteItemWidget({
    super.key,
    required this.favorite,
    this.onTap,
    this.onAddToCart,
    this.onRemove,
    this.onTogglePriceAlert,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildImage(),
              ),
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    favorite.productName,
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

                  const SizedBox(height: 5),

                  // Prix
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        favorite.formattedPrice,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: favorite.hasDiscount
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                      if (favorite.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          favorite.formattedOriginalPrice,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '-${favorite.discountPercentage}%',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Stock + date
                  Row(
                    children: [
                      // Stock
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: favorite.isInStock
                              ? AppColors.success
                              : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        favorite.isInStock
                            ? 'En stock'
                            : 'Rupture',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: favorite.isInStock
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Date
                      Icon(
                        Icons.access_time,
                        size: 10,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        favorite.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actions
            Column(
              children: [
                // Ajouter au panier
                GestureDetector(
                  onTap: favorite.isInStock ? onAddToCart : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: favorite.isInStock
                          ? AppColors.primary
                          : AppColors.textLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_shopping_cart,
                      size: 16,
                      color: favorite.isInStock
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Supprimer
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Alerte prix
                GestureDetector(
                  onTap: onTogglePriceAlert,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: favorite.priceAlert
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      favorite.priceAlert
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      size: 16,
                      color: favorite.priceAlert
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Construire l'image
  Widget _buildImage() {
    if (favorite.productImage == null || favorite.productImage!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Icon(
          Icons.favorite,
          size: 30,
          color: AppColors.textLight,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: favorite.productImage!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.background,
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
        color: AppColors.background,
        child: const Icon(
          Icons.broken_image,
          size: 30,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}