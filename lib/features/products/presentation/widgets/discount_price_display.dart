// ============================================
// WIDGET D'AFFICHAGE DU PRIX AVEC RÉDUCTION
// ============================================
// Affiche le prix actuel, l'ancien prix barré
// et le pourcentage. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DiscountPriceDisplay extends StatelessWidget {
  final double originalPrice;
  final double discountedPrice;
  final String currency;
  final DiscountPriceLayout layout;
  final bool showPercentage;
  final bool showSavings;

  const DiscountPriceDisplay({
    super.key,
    required this.originalPrice,
    required this.discountedPrice,
    this.currency = 'FCFA',
    this.layout = DiscountPriceLayout.horizontal,
    this.showPercentage = true,
    this.showSavings = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = _calculatePercentage();
    final savings = _calculateSavings();

    switch (layout) {
      case DiscountPriceLayout.horizontal:
        return _buildHorizontalLayout(percentage, savings);
      case DiscountPriceLayout.vertical:
        return _buildVerticalLayout(percentage, savings);
      case DiscountPriceLayout.compact:
        return _buildCompactLayout(percentage, savings);
    }
  }

  // ============================================
  // LAYOUT HORIZONTAL
  // ============================================

  Widget _buildHorizontalLayout(int percentage, double savings) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Text(
          _formatPrice(discountedPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        Text(
          _formatPrice(originalPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.textLight,
            decorationThickness: 1.5,
          ),
        ),
        if (showPercentage && percentage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '-$percentage%',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // LAYOUT VERTICAL
  // ============================================

  Widget _buildVerticalLayout(int percentage, double savings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatPrice(discountedPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _formatPrice(originalPrice),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.textLight,
                decorationThickness: 1.5,
              ),
            ),
            if (showPercentage && percentage > 0)
              Text(
                '-$percentage%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        if (showSavings && savings > 0) ...[
          const SizedBox(height: 3),
          Text(
            'Économisez ${_formatPrice(savings)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.success,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================
  // LAYOUT COMPACT
  // ============================================

  Widget _buildCompactLayout(int percentage, double savings) {
    return Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _formatPrice(discountedPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        if (showPercentage && percentage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-$percentage%',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // CALCULS
  // ============================================

  int _calculatePercentage() {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  double _calculateSavings() {
    return originalPrice - discountedPrice;
  }

  // ============================================
  // FORMATAGE
  // ============================================

  String _formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0);
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

// ============================================
// ENUM
// ============================================

enum DiscountPriceLayout {
  horizontal,  // Prix actuel | Ancien prix | Badge %
  vertical,    // Prix actuel en haut, ancien prix + % en bas
  compact,     // Prix actuel + % seulement
}