// Récapitulatif du panier
// Affiche sous-total, livraison, remises, taxes et total

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart.dart';

class CartSummary extends StatelessWidget {
  final Cart cart;

  const CartSummary({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          const Text(
            'RÉCAPITULATIF',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          // Sous-total
          _buildSummaryRow(
            label: 'Sous-total',
            value: cart.formattedSubtotal,
          ),

          const SizedBox(height: 8),

          // Remise produits
          if (cart.itemsDiscount > 0) ...[
            _buildSummaryRow(
              label: 'Remise produits',
              value: '- ${cart.itemsDiscount.toStringAsFixed(0)} FCFA',
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 8),
          ],

          // Remise coupon
          if (cart.couponDiscount > 0) ...[
            _buildSummaryRow(
              label: 'Code promo (${cart.couponCode})',
              value: '- ${cart.couponDiscount.toStringAsFixed(0)} FCFA',
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 8),
          ],

          // Livraison
          _buildSummaryRow(
            label: 'Livraison',
            value: cart.formattedShippingFee,
            valueColor: cart.effectiveShippingFee == 0
                ? AppColors.success
                : AppColors.textPrimary,
          ),

          // Taxes
          if (cart.taxes > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: 'Taxes',
              value: cart.formattedTaxes,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),

          const SizedBox(height: 12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                cart.formattedTotal,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Ligne de résumé
  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}