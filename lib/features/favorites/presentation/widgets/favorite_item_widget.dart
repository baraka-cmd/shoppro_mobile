// ============================================
// WIDGET D'ÉLÉMENT FAVORI - VERSION PREMIUM
// ============================================
// Affiche le produit avec actions rapides,
// badges et alertes. Design ShopPro.
// ============================================

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
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
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
              // ============================================
              // IMAGE
              // ============================================
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildImage(),
                ),
              ),

              const SizedBox(width: 12),

              // ============================================
              // INFORMATIONS
              // ============================================
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

                    // Badge baisse de prix
                    if (favorite.hasPriceDropped) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '🔥 BAISSE DE PRIX',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    // Rupture de stock
                    if (favorite.isOutOfStock) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '⚠️ ÉPUISÉ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 5),

                    // Prix
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.end,
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
                          Text(
                            favorite.formattedOriginalPrice,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textLight,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textLight,
                            ),
                          ),
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
                              ? favorite.isLowStock
                                  ? 'Plus que ${favorite.stock} en stock'
                                  : 'En stock'
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
                        const Icon(
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

              // ============================================
              // ACTIONS
              // ============================================
              Column(
                children: [
                  // Ajouter au panier
                  GestureDetector(
                    onTap: favorite.isInStock ? onAddToCart : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: favorite.isInStock
                            ? AppColors.primary
                            : AppColors.textLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: favorite.isInStock
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: favorite.priceAlert
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: favorite.priceAlert
                            ? Border.all(
                                color: AppColors.warning.withValues(alpha: 0.3),
                              )
                            : null,
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
      ),
    );
  }

  // ============================================
  // IMAGE
  // ============================================

  Widget _buildImage() {
    if (favorite.productImage == null || favorite.productImage!.isEmpty) {
      return Container(
        color: AppColors.surface,
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