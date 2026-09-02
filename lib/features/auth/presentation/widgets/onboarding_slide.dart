// ============================================
// WIDGET : OnboardingSlide
// ============================================
// Design inspiré des grandes applications (Food Express, Airbnb).
// Structure millimétrée :
// - Zone d'illustration : 45-50% de l'écran
// - Blob organique pastel derrière l'image
// - Titre en gros caractères gras
// - Sous-titre gris fin
// - Espacement généreux
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/onboarding_model.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class OnboardingSlide extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingSlide({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // ============================================
            // ZONE D'ILLUSTRATION (45-50% de l'écran)
            // ============================================
            Expanded(
              flex: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildIllustration(size),
                ),
              ),
            ),

            // ============================================
            // ZONE TEXTUELLE (20-25% de l'écran)
            // ============================================
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ============================================
                    // TITRE (gros, gras, très lisible)
                    // ============================================
                    Text(
                      model.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.25,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ============================================
                    // DESCRIPTION (fine, grise)
                    // ============================================
                    Text(
                      model.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ILLUSTRATION AVEC BLOB ORGANIQUE
  // ============================================

  Widget _buildIllustration(Size size) {
    return SizedBox(
      width: size.width * 0.75,
      height: size.width * 0.75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ============================================
          // BLOB ORGANIQUE (forme douce derrière l'image)
          // ============================================
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: model.blobColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: model.accentColor.withValues(alpha: 0.12),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // PETITE FORME DÉCORATIVE (cercle secondaire)
          // ============================================
          Positioned(
            top: 10,
            right: 5,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: model.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ============================================
          // PETITE FORME DÉCORATIVE (point)
          // ============================================
          Positioned(
            bottom: 25,
            left: 10,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: model.accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ============================================
          // IMAGE D'ILLUSTRATION (grande, nette)
          // ============================================
          Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                model.imagePath,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // ✅ Fallback élégant si l'image n'existe pas
                  return Container(
                    color: model.blobColor,
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: model.accentColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}