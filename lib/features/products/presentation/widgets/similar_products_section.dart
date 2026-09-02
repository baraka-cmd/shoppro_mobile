// ============================================
// SECTION PRODUITS SIMILAIRES - VERSION PREMIUM
// ============================================
// Carrousel horizontal "Vous pourriez aimer"
// avec cartes produits et bouton voir tout.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

class SimilarProductsSection extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product>? onProductTap;
  final VoidCallback? onSeeAllTap;
  final void Function(Product, bool)? onToggleFavorite;
  final bool Function(Product)? isFavorite;

  const SimilarProductsSection({
    super.key,
    required this.products,
    this.onProductTap,
    this.onSeeAllTap,
    this.onToggleFavorite,
    this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // EN-TÊTE
        // ============================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VOUS POURRIEZ AIMER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                ),
              ),
              if (onSeeAllTap != null)
                GestureDetector(
                  onTap: onSeeAllTap,
                  child: const Text(
                    'Voir tout',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ============================================
        // CARROUSEL HORIZONTAL
        // ============================================
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 150,
                  child: ProductCard(
                    product: product,
                    onTap: onProductTap,
                    onToggleFavorite: onToggleFavorite != null
                        ? () => onToggleFavorite!(product, isFavorite?.call(product) ?? false)
                        : null,
                    isFavorite: isFavorite?.call(product) ?? false,
                    showAddToCartButton: false,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}