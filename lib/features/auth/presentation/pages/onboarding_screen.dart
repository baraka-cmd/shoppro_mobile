// ============================================
// ÉCRAN D'INTRODUCTION (ONBOARDING)
// ============================================
// Design inspiré des grandes applications :
// - Marque centrée en haut
// - Bouton "Passer" discret à droite
// - Slides avec illustrations géantes
// - Dots élégants (trait ovale allongé pour l'actif)
// - Bouton pilule arrondi
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../data/models/onboarding_model.dart';
import '../widgets/onboarding_slide.dart';

// ============================================
// ÉCRAN PRINCIPAL
// ============================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// ============================================
// STATE
// ============================================

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingModel> _slides = OnboardingModel.slides;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================
  // NAVIGATION
  // ============================================

  /// Aller à la page suivante
  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  /// Passer l'onboarding directement
  void _skipOnboarding() {
    _finishOnboarding();
  }

  /// Terminer l'onboarding et naviguer vers Login
  Future<void> _finishOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingKey, true);
    } catch (e) {
      debugPrint('Erreur sauvegarde onboarding: $e');
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ============================================
            // HEADER (Marque centrée + Passer à droite)
            // ============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: Row(
                children: [
                  // Espace équilibré à gauche
                  const SizedBox(width: 60),

                  // Marque centrée
                  Expanded(
                    child: Center(
                      child: Text(
                        'ShopPro',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Bouton Passer à droite
                  SizedBox(
                    width: 60,
                    child: !_isLastPage
                        ? TextButton(
                            onPressed: _skipOnboarding,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: const Text(
                              'Passer',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ============================================
            // SLIDES (PageView - occupe l'espace central)
            // ============================================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLastPage = index == _slides.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(model: _slides[index]);
                },
              ),
            ),

            // ============================================
            // INDICATEURS DE PAGE (DOTS ÉLÉGANTS)
            // ============================================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 28 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? _slides[_currentPage].accentColor
                          : AppColors.borderColorDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // ============================================
            // BOUTON "SUIVANT / COMMENCER" (PILULE)
            // ============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 25),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLastPage ? 'Commencer' : 'Suivant',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _isLastPage
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward,
                      size: 20,
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
}