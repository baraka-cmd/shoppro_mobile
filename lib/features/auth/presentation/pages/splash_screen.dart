// ============================================
// ÉCRAN DE DÉMARRAGE (SPLASH SCREEN) - VERSION PRO
// ============================================
// Design épuré inspiré des meilleures pratiques :
// - Fond lumineux avec dégradé subtil
// - Logo officiel ShopPro
// - Animations séquentielles
// - Initialisation en parallèle
// - Redirection intelligente par rôle
// ============================================

// ============================================
// IMPORTS
// ============================================
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';

// ============================================
// ÉCRAN PRINCIPAL
// ============================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// ============================================
// STATE
// ============================================

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  // ============================================
  // CONTRÔLEURS D'ANIMATION
  // ============================================
  
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _loaderOpacityAnimation;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSplash();
  }

  // ============================================
  // INITIALISATION DES ANIMATIONS
  // ============================================

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Animation du logo : échelle élastique
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Animation du logo : opacité
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Animation du texte : apparaît après le logo
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Animation du loader : apparaît en dernier
    _loaderOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  // ============================================
  // SPLASH ET NAVIGATION
  // ============================================

  Future<void> _startSplash() async {
    // ✅ Exécuter l'animation et l'initialisation EN PARALLÈLE
    await Future.wait([
      _animationController.forward().orCancel,
      _initializeAuthWithTimeout(),
    ]);

    if (!mounted) return;

    await _navigateToNextScreen();
  }

  // ============================================
  // INITIALISATION AUTH AVEC TIMEOUT
  // ============================================

  Future<void> _initializeAuthWithTimeout() async {
    final authProvider = context.read<AuthProvider>();

    try {
      // Timeout de 5 secondes maximum pour l'initialisation
      await authProvider.init().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Splash: Timeout initialisation auth');
        },
      );
    } catch (e) {
      debugPrint('❌ Splash: Erreur initialisation: $e');
      // En cas d'erreur, on continue quand même vers l'onboarding
    }
  }

  // ============================================
  // NAVIGATION INTELLIGENTE
  // ============================================

  Future<void> _navigateToNextScreen() async {
    final authProvider = context.read<AuthProvider>();

    String route;

    if (authProvider.isAuthenticated) {
      // ✅ Utiliser getRedirectRoute() du provider (pas de duplication)
      route = authProvider.getRedirectRoute();
      debugPrint('✅ Splash: Redirection vers $route');
    } else {
      route = AppRoutes.onboarding;
      debugPrint('✅ Splash: Non authentifié → Onboarding');
    }

    // Petite pause pour laisser l'animation se terminer
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(route);
  }

  // ============================================
  // DISPOSE
  // ============================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Fond avec dégradé subtil (plus moderne que couleur plate)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF0F4F8),
              Color(0xFFE8EDF2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ============================================
                // LOGO SHOPPRO (image officielle)
                // ============================================
                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: FadeTransition(
                    opacity: _logoOpacityAnimation,
                    child: _buildLogo(),
                  ),
                ),

                const SizedBox(height: 20),

                // ============================================
                // NOM DE L'APPLICATION
                // ============================================
                FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Column(
                    children: [
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Votre boutique en ligne',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // ============================================
                // INDICATEUR DE CHARGEMENT ÉLÉGANT
                // ============================================
                FadeTransition(
                  opacity: _loaderOpacityAnimation,
                  child: Column(
                    children: [
                      // Loader personnalisé (3 points animés)
                      const _LoadingDots(),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ============================================
                // VERSION DE L'APPLICATION
                // ============================================
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // LOGO (image ou fallback icône)
  // ============================================

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.asset(
          'assets/images/logo.jpg',
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ✅ Fallback si le logo n'existe pas
            return const Icon(
              Icons.shopping_bag,
              size: 55,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }
}

// ============================================
// LOADER PERSONNALISÉ (3 POINTS ANIMÉS)
// ============================================

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeInOut),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final opacity = 0.3 + (_animations[index].value * 0.7);
            final scale = 0.7 + (_animations[index].value * 0.3);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}