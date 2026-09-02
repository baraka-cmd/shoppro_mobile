// ============================================
// SÉLECTEUR DE QUANTITÉ - VERSION PREMIUM
// ============================================
// Boutons +/- avec limite au stock, animations
// et mode compact. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final int maxQuantity;
  final int minQuantity;
  final ValueChanged<int>? onQuantityChanged;
  final bool showLabel;
  final bool compact;

  const QuantitySelector({
    super.key,
    this.initialQuantity = 1,
    this.maxQuantity = 99,
    this.minQuantity = 1,
    this.onQuantityChanged,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(widget.minQuantity, widget.maxQuantity);
  }

  @override
  void didUpdateWidget(QuantitySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuantity != oldWidget.initialQuantity) {
      _quantity = widget.initialQuantity.clamp(widget.minQuantity, widget.maxQuantity);
    }
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _increment() {
    if (_quantity < widget.maxQuantity) {
      setState(() {
        _quantity++;
      });
      widget.onQuantityChanged?.call(_quantity);
    }
  }

  void _decrement() {
    if (_quantity > widget.minQuantity) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged?.call(_quantity);
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          const Text(
            'QUANTITÉ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: widget.compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              // Bouton -
              _buildButton(
                icon: Icons.remove,
                onTap: _quantity > widget.minQuantity ? _decrement : null,
                isActive: _quantity > widget.minQuantity,
              ),

              // Quantité animée
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<int>(_quantity),
                  width: widget.compact ? 40 : 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: widget.compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Bouton +
              _buildButton(
                icon: Icons.add,
                onTap: _quantity < widget.maxQuantity ? _increment : null,
                isActive: _quantity < widget.maxQuantity,
              ),
            ],
          ),
        ),
        if (widget.showLabel && widget.maxQuantity < 10) ...[
          const SizedBox(height: 4),
          Text(
            'Plus que ${widget.maxQuantity} en stock',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.warning,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================
  // BOUTON +/-
  // ============================================

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.compact ? 35 : 45,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: widget.compact ? 14 : 18,
          color: isActive ? AppColors.primary : AppColors.textLight,
        ),
      ),
    );
  }
}