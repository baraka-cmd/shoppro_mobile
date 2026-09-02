// Widget d'indicateur de stock
// Affiche le niveau de stock avec barre de progression

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock.dart';

class StockIndicatorWidget extends StatelessWidget {
  final Stock stock;
  final bool showLabels;
  final bool showBar;

  const StockIndicatorWidget({
    super.key,
    required this.stock,
    this.showLabels = true,
    this.showBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(stock.statusColor);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statut
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                stock.statusLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          if (showLabels) ...[
            const SizedBox(height: 10),
            // Quantités
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuantityLabel('Stock', '${stock.quantity}'),
                _buildQuantityLabel('Réservé', '${stock.reservedQuantity}'),
                _buildQuantityLabel(
                  'Disponible',
                  '${stock.availableQuantity}',
                  isHighlighted: true,
                ),
              ],
            ),
          ],

          if (showBar) ...[
            const SizedBox(height: 10),
            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: stock.stockPercentage,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${(stock.stockPercentage * 100).round()}% du stock disponible',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Label de quantité
  Widget _buildQuantityLabel(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isHighlighted ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}