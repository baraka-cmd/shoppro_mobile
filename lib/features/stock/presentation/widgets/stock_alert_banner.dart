// Bannière d'alerte de stock
// Affiche un avertissement quand le stock est faible ou épuisé

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/stock.dart';

class StockAlertBanner extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onTap;

  const StockAlertBanner({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pas d'alerte si le stock est bon
    if (!stock.isLowStock && !stock.isOutOfStock) {
      return const SizedBox.shrink();
    }

    final isOut = stock.isOutOfStock;
    final color = isOut ? AppColors.error : AppColors.warning;
    final icon = isOut ? Icons.cancel : Icons.warning;
    final title = isOut ? 'RUPTURE DE STOCK' : 'STOCK FAIBLE';
    final message = isOut
        ? 'Ce produit n\'est plus disponible'
        : 'Plus que ${stock.availableQuantity} unité(s) disponible(s)';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),

            const SizedBox(width: 10),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Quantité
            Text(
              '${stock.availableQuantity}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}