// ============================================
// RÉSUMÉ DU PAIEMENT - VERSION PREMIUM
// ============================================
// Affiche le montant, les frais et le total
// avec hiérarchie visuelle claire. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentSummary extends StatelessWidget {
  final double amount;
  final double fee;
  final double total;
  final String currency;
  final String methodLabel;

  const PaymentSummary({
    super.key,
    required this.amount,
    this.fee = 0,
    required this.total,
    this.currency = 'FCFA',
    required this.methodLabel,
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
            'RÉSUMÉ DU PAIEMENT',
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
          // MÉTHODE
          // ============================================
          _buildRow(
            label: 'Méthode',
            value: methodLabel,
            valueColor: AppColors.textPrimary,
          ),

          const SizedBox(height: 8),

          // ============================================
          // MONTANT
          // ============================================
          _buildRow(
            label: 'Montant',
            value: _formatPrice(amount),
            valueColor: AppColors.textPrimary,
          ),

          // ============================================
          // FRAIS
          // ============================================
          if (fee > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              label: 'Frais',
              value: _formatPrice(fee),
              valueColor: AppColors.warning,
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
                'TOTAL À PAYER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Flexible(
                child: Text(
                  _formatPrice(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
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

  Widget _buildRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
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
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // FORMATAGE
  // ============================================

  String _formatPrice(double value) {
    final formatted = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer $currency';
  }
}