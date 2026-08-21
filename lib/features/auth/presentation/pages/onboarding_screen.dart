// Écran d'introduction (Onboarding)
// Affiche les slides avec navigation, indicateur et boutons

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../data/models/onboarding_model.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingModel> _slides = OnboardingModel.slides;

  @override
  void initState() {
    super.initState();
    _isLastPage = _currentPage == _slides.length - 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Naviguer vers la page suivante
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

  // Passer l'onboarding
  void _skipOnboarding() {
    _finishOnboarding();
  }

  // Terminer l'onboarding et naviguer vers login
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Slides
          PageView.builder(
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

          // Indicateur de page (dots)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: index == _currentPage ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // Boutons "Passer" et "Suivant"
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Passer (visible sauf sur la dernière page)
                if (!_isLastPage)
                  TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Passer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 80),

                // Bouton Suivant / Commencer
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLastPage ? 'Commencer' : 'Suivant',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isLastPage
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}