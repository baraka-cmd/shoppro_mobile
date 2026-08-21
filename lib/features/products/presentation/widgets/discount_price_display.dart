// Widget d'affichage du prix avec réduction
// Affiche le prix actuel, l'ancien prix barré et le pourcentage de réduction

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

  // Layout horizontal : Prix actuel | Ancien prix | Badge %
  Widget _buildHorizontalLayout(int percentage, double savings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Prix actuel
        Text(
          _formatPrice(discountedPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),

        const SizedBox(width: 8),

        // Ancien prix barré
        Text(
          _formatPrice(originalPrice),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
            decoration: TextDecoration.lineThrough,
          ),
        ),

        if (showPercentage) ...[
          const SizedBox(width: 8),
          // Badge pourcentage
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
      ],
    );
  }

  // Layout vertical : Prix actuel en haut, ancien prix + % en bas
  Widget _buildVerticalLayout(int percentage, double savings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prix actuel
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

        // Ancien prix + pourcentage
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatPrice(originalPrice),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textLight,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(width: 6),
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
          ],
        ),

        if (showSavings) ...[
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

  // Layout compact : Prix actuel + % seulement
  Widget _buildCompactLayout(int percentage, double savings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
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
        if (showPercentage) ...[
          const SizedBox(width: 5),
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
      ],
    );
  }

  // Calculer le pourcentage de réduction
  int _calculatePercentage() {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round();
  }

  // Calculer les économies
  double _calculateSavings() {
    return originalPrice - discountedPrice;
  }

  // Formater le prix
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

// Layout du prix avec réduction
enum DiscountPriceLayout {
  horizontal,  // Prix actuel | Ancien prix | Badge %
  vertical,    // Prix actuel en haut, ancien prix + % en bas
  compact,     // Prix actuel + % seulement
}