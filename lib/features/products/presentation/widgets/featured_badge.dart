// Badge produit en vedette
// Affiche un badge distinctif pour les produits mis en avant

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FeaturedBadge extends StatelessWidget {
  final FeaturedBadgeStyle style;
  final bool showIcon;

  const FeaturedBadge({
    super.key,
    this.style = FeaturedBadgeStyle.solid,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: _buildDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.star,
              size: 12,
              color: _buildTextColor(),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            'Vedette',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _buildTextColor(),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Décoration selon le style
  BoxDecoration _buildDecoration() {
    switch (style) {
      case FeaturedBadgeStyle.solid:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.warning,
              AppColors.warning,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );

      case FeaturedBadgeStyle.outlined:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.warning,
            width: 1.5,
          ),
        );

      case FeaturedBadgeStyle.soft:
        return BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        );
    }
  }

  // Couleur du texte selon le style
  Color _buildTextColor() {
    switch (style) {
      case FeaturedBadgeStyle.solid:
        return Colors.white;
      case FeaturedBadgeStyle.outlined:
      case FeaturedBadgeStyle.soft:
        return AppColors.warning;
    }
  }
}

// Style du badge
enum FeaturedBadgeStyle {
  solid,     // Dégradé orange
  outlined,  // Blanc avec bordure
  soft,      // Fond orange clair
}