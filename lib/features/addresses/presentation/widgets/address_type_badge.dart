// ============================================
// BADGE DE TYPE D'ADRESSE - VERSION PREMIUM
// ============================================
// Affiche le type avec couleur, icône et
// emoji. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddressTypeBadge extends StatelessWidget {
  final String type;
  final bool compact;

  const AddressTypeBadge({
    super.key,
    required this.type,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _getColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: compact ? 10 : 12,
            color: _getColor(),
          ),
          SizedBox(width: compact ? 3 : 5),
          Text(
            _getLabel(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.bold,
              color: _getColor(),
              letterSpacing: compact ? 0.3 : 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // LABEL DU TYPE
  // ============================================

  String _getLabel() {
    switch (type) {
      case 'home':
        return 'DOMICILE';
      case 'work':
        return 'TRAVAIL';
      case 'shop':
        return 'BOUTIQUE';
      case 'parents':
        return 'FAMILLE';
      case 'other':
        return 'AUTRE';
      default:
        return 'DOMICILE';
    }
  }

  // ============================================
  // COULEUR DU TYPE
  // ============================================

  Color _getColor() {
    switch (type) {
      case 'home':
        return AppColors.success;
      case 'work':
        return AppColors.info;
      case 'shop':
        return AppColors.warning;
      case 'parents':
        return const Color(0xFFE91E63);
      case 'other':
        return AppColors.textSecondary;
      default:
        return AppColors.success;
    }
  }

  // ============================================
  // ICÔNE DU TYPE
  // ============================================

  IconData _getIcon() {
    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      case 'shop':
        return Icons.store_outlined;
      case 'parents':
        return Icons.family_restroom;
      case 'other':
        return Icons.location_on_outlined;
      default:
        return Icons.home_outlined;
    }
  }
}