// ============================================
// SECTION D'INFORMATIONS DU PRODUIT - PREMIUM
// ============================================
// Affiche nom, note, prix, badges, stock
// et métadonnées. Design conforme ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';
import 'discount_price_display.dart';
import 'stock_indicator.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // NOM DU PRODUIT
        // ============================================
        Text(
          product.name,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        // ============================================
        // NOTE, AVIS ET VENTES
        // ============================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Note
            if (product.averageRating > 0) ...[
              const Icon(
                Icons.star,
                size: 18,
                color: AppColors.ratingColor,
              ),
              const SizedBox(width: 4),
              Text(
                product.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '(${product.reviewsCount} avis)',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 15),
            ],

            // Badge vérifié si bestseller
            if (product.isBestseller) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Best-seller',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Ventes
            Flexible(
              child: Text(
                'Vendu : ${product.salesCount}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ============================================
        // PRIX
        // ============================================
        if (product.hasDiscount)
          DiscountPriceDisplay(
            originalPrice: product.price,
            discountedPrice: product.currentPrice,
            layout: DiscountPriceLayout.vertical,
            showSavings: true,
          )
        else
          Text(
            product.formattedCurrentPrice,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

        const SizedBox(height: 12),

        // ============================================
        // STOCK
        // ============================================
        StockIndicator(
          currentStock: product.stock,
          minStock: product.minStock,
          style: StockIndicatorStyle.badge,
        ),

        const SizedBox(height: 10),

        // ============================================
        // SKU ET CATÉGORIE
        // ============================================
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // SKU
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SKU: ${product.sku}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Catégorie
            if (product.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.category!.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            // Marque
            if (product.brand != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.brand!.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}