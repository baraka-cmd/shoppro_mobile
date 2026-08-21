// Section d'informations du produit
// Affiche nom, note, prix et badges

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
        // Nom du produit
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

        // Note, avis et ventes
        Row(
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
              Text(
                ' (${product.reviewsCount} avis)',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 15),
            ],

            // Ventes
            Text(
              'Vendu : ${product.salesCount}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Prix
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

        // Stock
        StockIndicator(
          currentStock: product.stock,
          minStock: product.minStock,
          style: StockIndicatorStyle.badge,
        ),

        const SizedBox(height: 10),

        // SKU et catégorie
        Row(
          children: [
            // SKU
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
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
            const SizedBox(width: 8),
            // Catégorie
            if (product.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
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
          ],
        ),
      ],
    );
  }
}