// ============================================
// WIDGET DE SUGGESTIONS DE RECHERCHE - PREMIUM
// ============================================
// Affiche les suggestions pendant la frappe avec
// produits, catégories et miniatures.
// Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';

class SearchSuggestions extends StatelessWidget {
  final List<Product> products;
  final List<String> categories;
  final ValueChanged<String>? onSuggestionTap;
  final bool isLoading;

  const SearchSuggestions({
    super.key,
    required this.products,
    required this.categories,
    this.onSuggestionTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (products.isEmpty && categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // PRODUITS SUGGÉRÉS
        // ============================================
        if (products.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'PRODUITS SUGGÉRÉS',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          ...products.take(5).map((product) {
            return _buildProductSuggestion(product);
          }),
        ],

        // ============================================
        // CATÉGORIES SUGGÉRÉES
        // ============================================
        if (categories.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'CATÉGORIES SUGGÉRÉES',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
          ...categories.take(3).map((category) {
            return _buildCategorySuggestion(category);
          }),
        ],

        const SizedBox(height: 10),
      ],
    );
  }

  // ============================================
  // SUGGESTION PRODUIT
  // ============================================

  Widget _buildProductSuggestion(Product product) {
    return ListTile(
      dense: true,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 38,
          height: 38,
          child: product.fullImageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.fullImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                )
              : Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
        ),
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        product.formattedCurrentPrice,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: product.hasDiscount ? AppColors.error : AppColors.primary,
        ),
      ),
      trailing: const Icon(
        Icons.north_west,
        size: 14,
        color: AppColors.textLight,
      ),
      onTap: () => onSuggestionTap?.call(product.name),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: AppColors.surface,
    );
  }

  // ============================================
  // SUGGESTION CATÉGORIE
  // ============================================

  Widget _buildCategorySuggestion(String category) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.category_outlined,
          size: 16,
          color: AppColors.warning,
        ),
      ),
      title: Text(
        category,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: () => onSuggestionTap?.call(category),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: AppColors.surface,
    );
  }

  // ============================================
  // ÉTAT DE CHARGEMENT
  // ============================================

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(4, (index) {
        return Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}