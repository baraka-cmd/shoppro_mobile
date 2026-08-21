// Badge de statut de commande
// Affiche le statut avec couleur et icône adaptées

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const OrderStatusBadge({
    super.key,
    required this.status,
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
          // Point indicateur
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
          // Icône
          Icon(
            _getIcon(),
            size: compact ? 10 : 12,
            color: _getColor(),
          ),
          SizedBox(width: compact ? 3 : 4),
          // Label
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

  // Label du statut
  String _getLabel() {
    switch (status) {
      case 'pending':
        return 'EN ATTENTE';
      case 'confirmed':
        return 'CONFIRMÉE';
      case 'processing':
        return 'EN PRÉPARATION';
      case 'shipped':
        return 'EXPÉDIÉE';
      case 'delivered':
        return 'LIVRÉE';
      case 'cancelled':
        return 'ANNULÉE';
      case 'refunded':
        return 'REMBOURSÉE';
      case 'returned':
        return 'RETOURNÉE';
      default:
        return status.toUpperCase();
    }
  }

  // Couleur du statut
  Color _getColor() {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'processing':
        return const Color(0xFF9C27B0);
      case 'shipped':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'refunded':
        return AppColors.textSecondary;
      case 'returned':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  // Icône du statut
  IconData _getIcon() {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.refresh;
      case 'returned':
        return Icons.undo;
      default:
        return Icons.info;
    }
  }
}