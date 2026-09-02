// ============================================
// ÉTAT VIDE DU PANIER - VERSION PREMIUM
// ============================================
// Affiche un message élégant et un bouton
// pour explorer les produits. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyCart extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyCart({
    super.key,
    this.onExplore,
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
            // ICÔNE PANIER VIDE
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
                    Icons.shopping_bag_outlined,
                    size: 50,
                    color: AppColors.textLight,
                  ),
                  Positioned(
                    top: 22,
                    right: 22,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.textLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
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
            const Text(
              'Votre panier est vide',
              style: TextStyle(
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
            const Text(
              'Découvrez nos produits et trouvez\nce qui vous plaît !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // ============================================
            // BOUTON EXPLORER
            // ============================================
            ElevatedButton(
              onPressed: onExplore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'EXPLORER LES PRODUITS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ============================================
            // SUGGESTIONS RAPIDES
            // ============================================
            Text(
              'Populaire : Électronique • Mode • Maison',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}