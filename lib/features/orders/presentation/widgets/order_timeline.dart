// ============================================
// TIMELINE DE SUIVI DE COMMANDE - VERSION PREMIUM
// ============================================
// Affiche les étapes de progression verticalement
// avec animations et statut actuel. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/repositories/order_repository.dart';

class OrderTimeline extends StatelessWidget {
  final List<OrderTimelineEvent> events;

  const OrderTimeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // TITRE
        // ============================================
        const Text(
          'SUIVI DE COMMANDE',
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
        // TIMELINE
        // ============================================
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return _buildTimelineItem(event, isLast);
        }),
      ],
    );
  }

  // ============================================
  // ITEM DE TIMELINE
  // ============================================

  Widget _buildTimelineItem(OrderTimelineEvent event, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // COLONNE POINT + LIGNE
        // ============================================
        SizedBox(
          width: 40,
          child: Column(
            children: [
              // Point avec animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: event.isCurrent ? 28 : 24,
                height: event.isCurrent ? 28 : 24,
                decoration: BoxDecoration(
                  color: event.isCompleted
                      ? _getEventColor(event.status)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: event.isCompleted
                        ? _getEventColor(event.status)
                        : AppColors.borderColor,
                    width: event.isCurrent ? 3 : 2,
                  ),
                  boxShadow: event.isCurrent
                      ? [
                          BoxShadow(
                            color: _getEventColor(event.status).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _getEventIcon(event.status),
                  size: event.isCurrent ? 14 : 12,
                  color: event.isCompleted ? Colors.white : AppColors.textLight,
                ),
              ),

              // Ligne verticale
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 2,
                  height: 50,
                  color: event.isCompleted
                      ? _getEventColor(event.status)
                      : AppColors.borderColor,
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ============================================
        // CONTENU
        // ============================================
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: event.isCurrent ? 14 : 13,
                    fontWeight: event.isCompleted || event.isCurrent
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: event.isCompleted || event.isCurrent
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                if (event.hasLocation) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        event.location!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (event.hasNote) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.note!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // COULEUR SELON LE STATUT
  // ============================================

  Color _getEventColor(String status) {
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
      default:
        return AppColors.textSecondary;
    }
  }

  // ============================================
  // ICÔNE SELON LE STATUT
  // ============================================

  IconData _getEventIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }
}