// ============================================
// WIDGET : RecommendedSection
// ============================================
// Section "Pour vous" avec :
// - Titre contextuel et personnalisé
// - Sous-titre explicatif
// - Grille de produits 2 colonnes
// - Design épuré et premium
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

class RecommendedSection extends StatelessWidget {
  final List<Product> products;
  final String? contextMessage;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onToggleFavorite;

  const RecommendedSection({
    super.key,
    required this.products,
    this.contextMessage,
    this.onSeeAllTap,
    this.onProductTap,
    this.onToggleFavorite,
  });

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
                  Icons.auto_awesome,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Pour vous',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
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

          const SizedBox(height: 4),

          // ============================================
          // SOUS-TITRE CONTEXTUEL
          // ============================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              contextMessage ?? 'Sélection personnalisée pour vous',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // ============================================
          // GRILLE DE PRODUITS (2 colonnes)
          // ============================================
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: products.length > 4 ? 4 : products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildRecommendedCard(product);
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE PRODUIT RECOMMANDÉ
  // ============================================

  Widget _buildRecommendedCard(Product product) {
    return GestureDetector(
      onTap: () => onProductTap?.call(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // IMAGE + FAVORI
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

                // Bouton favori
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => onToggleFavorite?.call(product),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ============================================
            // DÉTAILS
            // ============================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Note
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
                      ],
                    ),
                    const Spacer(),
                    // Prix
                    Row(
                      children: [
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
                        if (product.discountPrice != null) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${product.price.round()}',
                              maxLines: 1,
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