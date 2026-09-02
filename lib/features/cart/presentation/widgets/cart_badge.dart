// ============================================
// BADGE DU PANIER - VERSION PREMIUM
// ============================================
// Affiche le nombre d'articles avec animation
// élastique et ombre. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CartBadge extends StatefulWidget {
  final int count;
  final Widget child;
  final VoidCallback? onTap;

  const CartBadge({
    super.key,
    required this.count,
    required this.child,
    this.onTap,
  });

  @override
  State<CartBadge> createState() => _CartBadgeState();
}

class _CartBadgeState extends State<CartBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.count > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CartBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animer quand le compte change
    if (widget.count != oldWidget.count) {
      if (widget.count > 0) {
        _controller.forward(from: 0);
      } else {
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,

          if (widget.count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    widget.count > 99 ? '99+' : '${widget.count}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}