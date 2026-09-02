// ============================================
// WIDGET : DynamicSectionItem
// ============================================
// Item de section dynamique réutilisable.
// Permet de créer des sections avec différents types de contenu.
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';

// ============================================
// ENUM DE TYPE DE SECTION
// ============================================

enum DynamicSectionType {
  products,
  banner,
  categories,
  custom,
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

class DynamicSectionItem extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final String title;
  final String? subtitle;
  final DynamicSectionType type;
  final List<Product>? products;
  final String? bannerImageUrl;
  final Color? bannerColor;
  final IconData? bannerIcon;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onToggleFavorite;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const DynamicSectionItem({
    super.key,
    required this.title,
    this.subtitle,
    this.type = DynamicSectionType.products,
    this.products,
    this.bannerImageUrl,
    this.bannerColor,
    this.bannerIcon,
    this.onSeeAllTap,
    this.onProductTap,
    this.onToggleFavorite,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                Text(
                  title,
                  style: const TextStyle(
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

          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ============================================
          // CONTENU SELON LE TYPE
          // ============================================
          _buildContent(),
        ],
      ),
    );
  }

  // ============================================
  // CONTENU PAR TYPE
  // ============================================

  Widget _buildContent() {
    switch (type) {
      case DynamicSectionType.products:
        return _buildProductsGrid();
      case DynamicSectionType.banner:
        return _buildBanner();
      case DynamicSectionType.categories:
        return _buildCategoriesPlaceholder();
      case DynamicSectionType.custom:
        return const SizedBox.shrink();
    }
  }

  // ============================================
  // GRILLE DE PRODUITS (2 COLONNES)
  // ============================================

  Widget _buildProductsGrid() {
    if (products == null || products!.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: products!.length > 4 ? 4 : products!.length,
      itemBuilder: (context, index) {
        final product = products![index];
        return _buildProductCard(product);
      },
    );
  }

  // ============================================
  // CARTE PRODUIT
  // ============================================

  Widget _buildProductCard(Product product) {
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
            // Image + Favori
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: product.mainImage != null
                        ? CachedNetworkImage(
                            imageUrl: product.mainImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.surface,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 26,
                                color: AppColors.textLight,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 26,
                            color: AppColors.textLight,
                          ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => onToggleFavorite?.call(product),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Détails
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.currentPrice.round()} FCFA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
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

  // ============================================
  // BANNIÈRE
  // ============================================

  Widget _buildBanner() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bannerColor ?? AppColors.primary,
            (bannerColor ?? AppColors.primary).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          bannerIcon ?? Icons.local_offer,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // CATÉGORIES PLACEHOLDER
  // ============================================

  Widget _buildCategoriesPlaceholder() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Catégories',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}