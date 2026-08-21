// Timeline de suivi de commande
// Affiche les étapes de progression verticalement

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
        // Titre
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

        // Timeline
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return _buildTimelineItem(event, isLast);
        }),
      ],
    );
  }

  // Construire un item de timeline
  Widget _buildTimelineItem(OrderTimelineEvent event, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne avec point + ligne
        SizedBox(
          width: 40,
          child: Column(
            children: [
              // Point
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: event.isCompleted
                      ? _getEventColor(event.status)
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: event.isCompleted
                        ? _getEventColor(event.status)
                        : AppColors.borderColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getEventIcon(event.status),
                  size: 12,
                  color: event.isCompleted ? Colors.white : AppColors.textLight,
                ),
              ),

              // Ligne verticale
              if (!isLast)
                Container(
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

        // Contenu
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
                    fontSize: 13,
                    fontWeight: event.isCompleted
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: event.isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(event.date),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.location!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (event.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.note!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
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

  // Couleur selon le statut
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

  // Icône selon le statut
  IconData _getEventIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure(s)';
    }
    return 'À l\'instant';
  }
}