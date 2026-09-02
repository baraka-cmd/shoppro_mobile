// Carte de mouvement de stock
// Affiche les informations d'un mouvement

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock_movement.dart';

class StockMovementCard extends StatelessWidget {
  final StockMovement movement;

  const StockMovementCard({
    super.key,
    required this.movement,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(movement.typeColor);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Icône du type
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                movement.typeIcon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      movement.typeLabel,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      movement.formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  movement.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (movement.reference != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Réf : ${movement.reference}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quantité
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${movement.isIncoming ? '+' : ''}${movement.quantity}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${movement.quantityBefore} → ${movement.quantityAfter}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}