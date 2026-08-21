// Bouton de connexion sociale personnalisé
// Supporte Google, Facebook et Apple avec animations

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onPressed;
  final bool isLoading;

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

  // Boutons prédéfinis
  factory SocialButton.google({VoidCallback? onPressed, bool isLoading = false}) {
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

  factory SocialButton.facebook({VoidCallback? onPressed, bool isLoading = false}) {
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

  factory SocialButton.apple({VoidCallback? onPressed, bool isLoading = false}) {
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

class _SocialButtonState extends State<SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
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
                        size: 22,
                        color: widget.iconColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
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