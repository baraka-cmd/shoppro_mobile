// Suggestions de produits dans le panier
// Affiche des produits recommandés quand le panier est vide

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';

class CartSuggestions extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final ValueChanged<Product>? onProductTap;
  final VoidCallback? onSeeAll;

  const CartSuggestions({
    super.key,
    required this.products,
    this.isLoading = false,
    this.onProductTap,
    this.onSeeAll,
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
                    Icons.recommend,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SUGGESTIONS POUR VOUS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Liste horizontale
        if (isLoading)
          const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          )
        else if (products.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildSuggestionCard(product);
              },
            ),
          ),
      ],
    );
  }

  // Carte de suggestion
  Widget _buildSuggestionCard(Product product) {
    return GestureDetector(
      onTap: () => onProductTap?.call(product),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 100,
                height: 80,
                child: product.mainImage != null && product.mainImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.mainImage!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image,
                            size: 25,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image,
                          size: 25,
                          color: AppColors.textLight,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 6),

            // Nom
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 3),

            // Prix
            Text(
              product.formattedCurrentPrice,
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
    );
  }
}