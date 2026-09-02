// Badge de type d'adresse
// Affiche le type avec couleur et icône adaptées

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
    return Container(
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

  // Label du type
  String _getLabel() {
    switch (type) {
      case 'home':
        return 'DOMICILE';
      case 'work':
        return 'TRAVAIL';
      case 'other':
        return 'AUTRE';
      default:
        return 'DOMICILE';
    }
  }

  // Couleur du type
  Color _getColor() {
    switch (type) {
      case 'home':
        return AppColors.success;
      case 'work':
        return AppColors.info;
      case 'other':
        return AppColors.textSecondary;
      default:
        return AppColors.success;
    }
  }

  // Icône du type
  IconData _getIcon() {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.home;
    }
  }
}