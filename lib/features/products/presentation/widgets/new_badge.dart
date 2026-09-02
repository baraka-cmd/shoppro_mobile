// ============================================
// BADGE PRODUIT NOUVEAU - PREMIUM
// ============================================
// Affiche un badge "Nouveau" avec 4 styles
// disponibles. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NewBadge extends StatelessWidget {
  final NewBadgeStyle style;
  final bool showIcon;
  final String label;

  const NewBadge({
    super.key,
    this.style = NewBadgeStyle.solid,
    this.showIcon = true,
    this.label = 'Nouveau',
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
              Icons.fiber_new,
              size: 12,
              color: _buildTextColor(),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
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

  // ============================================
  // DÉCORATION
  // ============================================

  BoxDecoration _buildDecoration() {
    switch (style) {
      case NewBadgeStyle.solid:
        return BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        );

      case NewBadgeStyle.outlined:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.success,
            width: 1.5,
          ),
        );

      case NewBadgeStyle.soft:
        return BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        );

      case NewBadgeStyle.gradient:
        return BoxDecoration(
          gradient: AppColors.successGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        );
    }
  }

  // ============================================
  // COULEUR DU TEXTE
  // ============================================

  Color _buildTextColor() {
    switch (style) {
      case NewBadgeStyle.solid:
      case NewBadgeStyle.gradient:
        return Colors.white;
      case NewBadgeStyle.outlined:
      case NewBadgeStyle.soft:
        return AppColors.success;
    }
  }
}

// ============================================
// ENUM
// ============================================

enum NewBadgeStyle {
  solid,     // Vert plein
  outlined,  // Blanc avec bordure
  soft,      // Fond vert clair
  gradient,  // Dégradé vert → vert clair
}