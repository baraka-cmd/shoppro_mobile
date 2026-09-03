// ============================================
// WIDGET : BestSellersSection
// ============================================
// Section Meilleures Ventes avec :
// - Badges or/argent/bronze pour le top 3
// - Cartes produits propres et premium
// - Boutons favoris élégants avec état dynamique
// - Scroll horizontal fluide
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class BestSellersSection extends StatelessWidget {
  final List<Product> products;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onAddToCart;
  final ValueChanged<Product>? onToggleFavorite;
  final bool Function(Product)? isFavorite;

  const BestSellersSection({
    super.key,
    required this.products,
    this.onSeeAllTap,
    this.onProductTap,
    this.onAddToCart,
    this.onToggleFavorite,
    this.isFavorite,
  });

  // ============================================
  // COULEURS DES BADGES (OR, ARGENT, BRONZE)
  // ============================================

  static const List<Color> _badgeColors = [
    Color(0xFFF4B942), // Or
    Color(0xFF9CA3AF), // Argent
    Color(0xFFB45309), // Bronze
  ];

  static const List<String> _badgeIcons = ['🥇', '🥈', '🥉'];

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // EN-TÊTE DE LA SECTION
          // ============================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 20,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Meilleures ventes',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TOP',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warningDark,
                    ),
                  ),
                ),
                const Spacer(),
                if (onSeeAllTap != null)
                  GestureDetector(
                    onTap: onSeeAllTap,
                    child: const Row(
                      children: [
                        Text(
                          'Voir tout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // ============================================
          // SOUS-TITRE
          // ============================================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Les produits préférés de nos clients',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ============================================
          // LISTE DES PRODUITS (SCROLL HORIZONTAL)
          // ============================================
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isTop3 = index < 3;
                final badgeColor = isTop3 ? _badgeColors[index] : null;
                final badgeIcon = isTop3 ? _badgeIcons[index] : null;
                return _buildBestSellerCard(
                  product,
                  badgeColor,
                  badgeIcon,
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE PRODUIT BEST SELLER
  // ============================================

  Widget _buildBestSellerCard(
    Product product,
    Color? badgeColor,
    String? badgeIcon,
    int index,
  ) {
    final isFav = isFavorite?.call(product) ?? false;

    return GestureDetector(
      onTap: () => onProductTap?.call(product),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // IMAGE + BADGES
            // ============================================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: product.mainImage != null
                        ? CachedNetworkImage(
                            imageUrl: product.mainImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
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
                                Icons.image_outlined,
                                size: 28,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 28,
                            color: AppColors.textLight,
                          ),
                  ),
                ),

                // Badge top 3 (or, argent, bronze)
                if (badgeIcon != null && badgeColor != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          badgeIcon,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),

                // ✅ Bouton favori avec état dynamique
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => onToggleFavorite?.call(product),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: isFav
                            ? Border.all(color: AppColors.error, width: 1.5)
                            : null,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFav ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ============================================
            // DÉTAILS DU PRODUIT
            // ============================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${product.reviewsCount})',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${product.currentPrice.round()} FCFA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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
}