// ============================================
// WIDGET : SocialButton
// ============================================
// Bouton de connexion sociale avec :
// - Animation d'échelle au tap
// - Feedback visuel (SnackBar "Bientôt disponible")
// - Loading state
// - Icônes correctes pour Google, Facebook, Apple
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SocialButton extends StatefulWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.borderColor,
    this.onPressed,
    this.isLoading = false,
  });

  // ============================================
  // FACTORIES PRÉDÉFINIS
  // ============================================

  /// Bouton Google
  factory SocialButton.google({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      label: 'Google',
      icon: Icons.g_mobiledata,
      iconColor: const Color(0xFFEA4335),
      backgroundColor: Colors.white,
      borderColor: AppColors.borderColor,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  /// Bouton Facebook
  factory SocialButton.facebook({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      label: 'Facebook',
      icon: Icons.facebook,
      iconColor: const Color(0xFF1877F2),
      backgroundColor: Colors.white,
      borderColor: AppColors.borderColor,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  /// Bouton Apple
  factory SocialButton.apple({
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialButton(
      label: 'Apple',
      icon: Icons.apple,
      iconColor: Colors.black,
      backgroundColor: Colors.white,
      borderColor: AppColors.borderColor,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

// ============================================
// STATE
// ============================================

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================
  // GESTION DU TAP
  // ============================================

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    _handlePress();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  /// Gère l'action du bouton avec feedback
  void _handlePress() {
    if (widget.isLoading) return;

    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      // ✅ Feedback si pas de handler
      _showComingSoon();
    }
  }

  /// Affiche un SnackBar "Bientôt disponible"
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connexion ${widget.label} bientôt disponible',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.iconColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: 20,
                        color: widget.iconColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}