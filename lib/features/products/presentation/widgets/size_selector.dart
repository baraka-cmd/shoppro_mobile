// ============================================
// SÉLECTEUR DE TAILLE - VERSION PREMIUM
// ============================================
// Chips de tailles avec états disponibles,
// sélectionnés et indisponibles. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SizeSelector extends StatefulWidget {
  final List<SizeOption> sizes;
  final String? selectedSize;
  final ValueChanged<SizeOption>? onSizeSelected;

  const SizeSelector({
    super.key,
    required this.sizes,
    this.selectedSize,
    this.onSizeSelected,
  });

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  String? _selectedSizeName;

  @override
  void initState() {
    super.initState();
    _selectedSizeName = widget.selectedSize;
  }

  @override
  void didUpdateWidget(SizeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSize != oldWidget.selectedSize) {
      _selectedSizeName = widget.selectedSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label avec taille sélectionnée
        Row(
          children: [
            const Text(
              'Taille',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            if (_selectedSizeName != null)
              Text(
                ': $_selectedSizeName',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Chips de tailles
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.sizes.map((option) {
            final isSelected = _selectedSizeName == option.name;
            return _buildSizeChip(option, isSelected);
          }).toList(),
        ),

        // Guide des tailles (optionnel)
        if (widget.sizes.any((s) => !s.isAvailable))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Taille indisponible',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================
  // CHIP DE TAILLE
  // ============================================

  Widget _buildSizeChip(SizeOption option, bool isSelected) {
    return GestureDetector(
      onTap: option.isAvailable
          ? () {
              setState(() {
                _selectedSizeName = option.name;
              });
              widget.onSizeSelected?.call(option);
            }
          : null,
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : option.isAvailable
                    ? Colors.white
                    : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : option.isAvailable
                      ? AppColors.borderColor
                      : AppColors.borderColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            option.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : option.isAvailable
                      ? AppColors.textPrimary
                      : AppColors.textLight,
              decoration: option.isAvailable
                  ? null
                  : TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// CLASSE OPTION DE TAILLE
// ============================================

class SizeOption {
  final String name;
  final bool isAvailable;
  final int stock;

  const SizeOption({
    required this.name,
    this.isAvailable = true,
    this.stock = 0,
  });
}