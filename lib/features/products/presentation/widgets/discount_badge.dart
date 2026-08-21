// Badge de réduction
// Affiche le pourcentage ou le montant de réduction

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DiscountBadge extends StatelessWidget {
  final int? percentage;
  final double? amount;
  final DiscountBadgeSize size;
  final DiscountBadgeStyle style;

  const DiscountBadge({
    super.key,
    this.percentage,
    this.amount,
    this.size = DiscountBadgeSize.medium,
    this.style = DiscountBadgeStyle.solid,
  });

  @override
  Widget build(BuildContext context) {
    final label = _buildLabel();
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: _buildPadding(),
      decoration: _buildDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            size: _buildIconSize(),
            color: _buildTextColor(),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: _buildFontSize(),
              fontWeight: FontWeight.bold,
              color: _buildTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  // Construire le label
  String _buildLabel() {
    if (percentage != null && percentage! > 0) {
      return '-$percentage%';
    }
    if (amount != null && amount! > 0) {
      return '-${amount!.toStringAsFixed(0)} F';
    }
    return '';
  }

  // Padding selon la taille
  EdgeInsets _buildPadding() {
    switch (size) {
      case DiscountBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
      case DiscountBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
      case DiscountBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 7);
    }
  }

  // Décoration selon le style
  BoxDecoration _buildDecoration() {
    switch (style) {
      case DiscountBadgeStyle.solid:
        return BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );

      case DiscountBadgeStyle.outlined:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.error,
            width: 1.5,
          ),
        );

      case DiscountBadgeStyle.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.error,
              AppColors.error.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        );
    }
  }

  // Taille de l'icône
  double _buildIconSize() {
    switch (size) {
      case DiscountBadgeSize.small:
        return 10;
      case DiscountBadgeSize.medium:
        return 12;
      case DiscountBadgeSize.large:
        return 16;
    }
  }

  // Taille du texte
  double _buildFontSize() {
    switch (size) {
      case DiscountBadgeSize.small:
        return 9;
      case DiscountBadgeSize.medium:
        return 11;
      case DiscountBadgeSize.large:
        return 14;
    }
  }

  // Couleur du texte
  Color _buildTextColor() {
    switch (style) {
      case DiscountBadgeStyle.solid:
      case DiscountBadgeStyle.gradient:
        return Colors.white;
      case DiscountBadgeStyle.outlined:
        return AppColors.error;
    }
  }
}

// Taille du badge
enum DiscountBadgeSize {
  small,
  medium,
  large,
}

// Style du badge
enum DiscountBadgeStyle {
  solid,
  outlined,
  gradient,
}