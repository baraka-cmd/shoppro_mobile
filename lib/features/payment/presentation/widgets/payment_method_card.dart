// ============================================
// CARTE DE MÉTHODE DE PAIEMENT - VERSION PREMIUM
// ============================================
// Affiche le mode de paiement avec sélection,
// disponibilité et animations. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentMethodCard extends StatelessWidget {
  final String method;
  final String label;
  final String? description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isAvailable;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.label,
    this.description,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.onTap,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.05)
              : isAvailable
                  ? Colors.white
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : isAvailable
                    ? AppColors.borderColor.withValues(alpha: 0.5)
                    : AppColors.borderColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : isAvailable
                  ? AppColors.softShadow
                  : null,
        ),
        child: Row(
          children: [
            // ============================================
            // RADIO PERSONNALISÉ
            // ============================================
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? color
                      : isAvailable
                          ? AppColors.textLight
                          : AppColors.textLight.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // ============================================
            // ICÔNE
            // ============================================
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : isAvailable
                        ? AppColors.surface
                        : AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? color
                    : isAvailable
                        ? AppColors.textSecondary
                        : AppColors.textLight,
              ),
            ),

            const SizedBox(width: 12),

            // ============================================
            // INFORMATIONS
            // ============================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isAvailable
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: isAvailable
                            ? AppColors.textSecondary
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ============================================
            // BADGE DISPONIBILITÉ
            // ============================================
            if (!isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Bientôt',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),

            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 18,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}