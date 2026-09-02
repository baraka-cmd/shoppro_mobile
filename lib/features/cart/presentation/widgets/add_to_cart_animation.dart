// ============================================
// ANIMATION D'AJOUT AU PANIER - VERSION PREMIUM
// ============================================
// Affiche une animation quand un produit est ajouté.
// Design ShopPro avec effets élastiques.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddToCartAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isInCart;

  const AddToCartAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.isInCart = false,
  });

  @override
  State<AddToCartAnimation> createState() => _AddToCartAnimationState();
}

class _AddToCartAnimationState extends State<AddToCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // DÉCLENCHER L'ANIMATION
  // ============================================

  void _triggerAnimation() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isInCart
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isInCart
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              widget.isInCart
                  ? Icons.check
                  : Icons.add_shopping_cart,
              size: 20,
              color: widget.isInCart ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// OVERLAY D'ANIMATION FLOTTANTE VERS LE PANIER
// ============================================

class FlyingCartAnimation extends StatefulWidget {
  final bool show;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback? onComplete;

  const FlyingCartAnimation({
    super.key,
    required this.show,
    required this.startPosition,
    required this.endPosition,
    this.onComplete,
  });

  @override
  State<FlyingCartAnimation> createState() => _FlyingCartAnimationState();
}

class _FlyingCartAnimationState extends State<FlyingCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.show) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(FlyingCartAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0).then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final dx = widget.startPosition.dx +
            (widget.endPosition.dx - widget.startPosition.dx) * _progress.value;
        final dy = widget.startPosition.dy +
            (widget.endPosition.dy - widget.startPosition.dy) * _progress.value;

        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: (1 - (_progress.value * 0.5)).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 1 - (_progress.value * 0.3),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}