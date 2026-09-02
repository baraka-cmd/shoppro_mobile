// Barre de progression livraison gratuite
// Montre le progrès vers le seuil de livraison gratuite

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart.dart';

class FreeShippingProgress extends StatelessWidget {
  final Cart cart;

  const FreeShippingProgress({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    // Si le panier est vide, ne rien afficher
    if (cart.isEmpty) {
      return const SizedBox.shrink();
    }

    final progress = cart.freeShippingProgress;
    final remaining = cart.remainingForFreeShipping;

    // Si la livraison est gratuite
    if (remaining <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 20,
              color: AppColors.success,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🎉 Félicitations ! Vous bénéficiez de la livraison gratuite !',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message
          Row(
            children: [
              const Icon(
                Icons.local_shipping,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Plus que ${cart.formattedRemainingForFreeShipping} pour la livraison gratuite',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              color: AppColors.warning,
            ),
          ),

          const SizedBox(height: 5),

          // Pourcentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
              Text(
                'Seuil : ${_formatPrice(Cart.freeShippingThreshold)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formater le prix
  String _formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer FCFA';
  }
}