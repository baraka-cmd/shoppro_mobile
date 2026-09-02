// ============================================
// RÉCAPITULATIF DU PANIER - VERSION PREMIUM
// ============================================
// Affiche sous-total, livraison, remises, taxes
// et total avec hiérarchie visuelle claire.
// Design ShopPro.
// ============================================

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
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // TITRE
          // ============================================
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

          // ============================================
          // SOUS-TOTAL
          // ============================================
          _buildSummaryRow(
            label: 'Sous-total',
            value: cart.formattedSubtotal,
          ),

          const SizedBox(height: 8),

          // ============================================
          // REMISE PRODUITS
          // ============================================
          if (cart.itemsDiscount > 0) ...[
            _buildSummaryRow(
              label: 'Remise produits',
              value: '- ${_formatAmount(cart.itemsDiscount)}',
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 8),
          ],

          // ============================================
          // REMISE COUPON
          // ============================================
          if (cart.couponDiscount > 0) ...[
            _buildSummaryRow(
              label: 'Code promo (${cart.couponCode})',
              value: '- ${_formatAmount(cart.couponDiscount)}',
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 8),
          ],

          // ============================================
          // LIVRAISON
          // ============================================
          _buildSummaryRow(
            label: 'Livraison',
            value: cart.formattedShippingFee,
            valueColor: cart.effectiveShippingFee == 0
                ? AppColors.success
                : AppColors.textPrimary,
          ),

          // ============================================
          // TAXES
          // ============================================
          if (cart.taxes > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              label: 'Taxes',
              value: cart.formattedTaxes,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 12),

          // ============================================
          // TOTAL
          // ============================================
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
                  fontSize: 20,
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

  // ============================================
  // LIGNE DE RÉSUMÉ
  // ============================================

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
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // FORMATAGE
  // ============================================

  String _formatAmount(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer FCFA';
  }
}