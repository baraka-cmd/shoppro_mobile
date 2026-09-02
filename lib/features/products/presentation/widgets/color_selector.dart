// ============================================
// SÉLECTEUR DE COULEUR - VERSION PREMIUM
// ============================================
// Swatches visuels circulaires avec animations,
// tooltips et état sélectionné. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ColorSelector extends StatefulWidget {
  final List<ColorOption> colors;
  final String? selectedColor;
  final ValueChanged<ColorOption>? onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    this.selectedColor,
    this.onColorSelected,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  String? _selectedColorName;

  @override
  void initState() {
    super.initState();
    _selectedColorName = widget.selectedColor;
  }

  @override
  void didUpdateWidget(ColorSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) {
      _selectedColorName = widget.selectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.colors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label avec couleur sélectionnée
        Row(
          children: [
            const Text(
              'Couleur',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            if (_selectedColorName != null)
              Text(
                ': $_selectedColorName',
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

        // Swatches
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.colors.map((option) {
            final isSelected = _selectedColorName == option.name;
            return _buildColorSwatch(option, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  // ============================================
  // SWATCH DE COULEUR
  // ============================================

  Widget _buildColorSwatch(ColorOption option, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorName = option.name;
        });
        widget.onColorSelected?.call(option);
      },
      child: Tooltip(
        message: option.name,
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderColor,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// ============================================
// CLASSE OPTION DE COULEUR
// ============================================

class ColorOption {
  final String name;
  final Color color;
  final String? hexCode;
  final bool isAvailable;

  const ColorOption({
    required this.name,
    required this.color,
    this.hexCode,
    this.isAvailable = true,
  });

  /// Créer depuis un code hexadécimal
  factory ColorOption.fromHex({
    required String name,
    required String hex,
    bool isAvailable = true,
  }) {
    return ColorOption(
      name: name,
      color: _parseHex(hex),
      hexCode: hex,
      isAvailable: isAvailable,
    );
  }

  static Color _parseHex(String hex) {
    var cleanHex = hex.replaceAll('#', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.parse(cleanHex, radix: 16));
  }
}