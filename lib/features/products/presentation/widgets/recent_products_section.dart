// Section produits récents
// Scroll horizontal avec titre et lien "Voir tout"

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';
import 'shimmer_product_card.dart';

class RecentProductsSection extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final void Function(Product)? onProductTap;
  final VoidCallback? onAddToCart;
  final void Function(Product, bool)? onToggleFavorite;

  const RecentProductsSection({
    super.key,
    required this.products,
    this.isLoading = false,
    this.onSeeAll,
    this.onProductTap,
    this.onAddToCart,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + Voir tout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppColors.info,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'RÉCENTS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
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
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Liste horizontale
        if (isLoading)
          const ShimmerProductHorizontal(itemCount: 4)
        else if (products.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 170,
                    child: ProductCard(
                      product: product,
                      onTap: onProductTap,
                      onAddToCart: onAddToCart,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: const Center(
        child: Text(
          'Aucun produit récent',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}