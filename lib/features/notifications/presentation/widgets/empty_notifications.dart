// ============================================
// ÉTAT VIDE DES NOTIFICATIONS - VERSION PREMIUM
// ============================================
// Affiche un message élégant quand il n'y a
// pas de notifications. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyNotifications extends StatelessWidget {
  final String title;
  final String message;

  const EmptyNotifications({
    super.key,
    this.title = 'Aucune notification',
    this.message = 'Vous recevrez des notifications\nsur vos commandes et promotions !',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ============================================
            // ICÔNE NOTIFICATION VIDE
            // ============================================
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 50,
                    color: AppColors.textLight,
                  ),
                  Positioned(
                    top: 22,
                    right: 20,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.textLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ============================================
            // TITRE
            // ============================================
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // ============================================
            // DESCRIPTION
            // ============================================
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            // ============================================
            // ASTUCE
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '💡 Astuce : Activez les notifications pour ne rien manquer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}