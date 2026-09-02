// Section des produits recommandés
// Affiche des suggestions personnalisées basées sur l'historique

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/shimmer_product_card.dart';

class RecommendedSection extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final ValueChanged<Product>? onProductTap;
  final String? userName;

  const RecommendedSection({
    super.key,
    required this.products,
    this.isLoading = false,
    this.onSeeAll,
    this.onProductTap,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête : Titre + Voir tout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.recommend,
                    size: 18,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    userName != null
                        ? 'RECOMMANDÉS POUR ${userName!.toUpperCase()}'
                        : 'RECOMMANDÉS',
                    style: const TextStyle(
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
                child: const Row(
                  children: [
                    Text(
                      'Voir tout',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
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
          const SizedBox.shrink()
        else
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