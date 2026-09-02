// ============================================
// BARRE DE PROGRESSION LIVRAISON GRATUITE - PREMIUM
// ============================================
// Montre le progrès vers le seuil de livraison
// gratuite avec animations. Design ShopPro.
// ============================================

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
    if (cart.isEmpty) {
      return const SizedBox.shrink();
    }

    final progress = cart.freeShippingProgress;
    final remaining = cart.remainingForFreeShipping;

    // ============================================
    // LIVRAISON GRATUITE ATTEINTE
    // ============================================
    if (remaining <= 0) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * scale),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
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
                size: 22,
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
        ),
      );
    }

    // ============================================
    // PROGRESSION VERS LA LIVRAISON GRATUITE
    // ============================================
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // MESSAGE
          // ============================================
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
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

          // ============================================
          // BARRE DE PROGRESSION ANIMÉE
          // ============================================
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.surface,
                  color: AppColors.warning,
                ),
              );
            },
          ),

          const SizedBox(height: 5),

          // ============================================
          // POURCENTAGE + SEUIL
          // ============================================
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

  // ============================================
  // FORMATAGE
  // ============================================

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