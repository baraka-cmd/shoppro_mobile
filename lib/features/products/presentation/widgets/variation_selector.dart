// ============================================
// SÉLECTEUR DE VARIATIONS DU PRODUIT - VERSION PREMIUM
// ============================================
// Permet de choisir couleur, taille et autres options.
// Design avec swatches visuels, états et animations.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class VariationSelector extends StatefulWidget {
  final List<ProductVariant> variants;
  final ValueChanged<ProductVariant?>? onVariantSelected;

  const VariationSelector({
    super.key,
    required this.variants,
    this.onVariantSelected,
  });

  @override
  State<VariationSelector> createState() => _VariationSelectorState();
}

class _VariationSelectorState extends State<VariationSelector> {
  ProductVariant? _selectedVariant;
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.variants.isNotEmpty) {
      _selectedVariant = widget.variants.firstWhere(
        (v) => v.isDefault,
        orElse: () => widget.variants.first,
      );
      _selectedColor = _selectedVariant?.color;
      _selectedSize = _selectedVariant?.size;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onVariantSelected?.call(_selectedVariant);
      });
    }
  }

  // ============================================
  // GETTERS
  // ============================================

  List<String> get _availableColors {
    return widget.variants
        .map((v) => v.color)
        .where((c) => c != null && c!.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
  }

  List<String> get _availableSizes {
    return widget.variants
        .map((v) => v.size)
        .where((s) => s != null && s!.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (widget.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        const Text(
          'VARIANTES',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 12),

        // Sélection de couleur
        if (_availableColors.isNotEmpty) ...[
          _buildColorSection(),
          const SizedBox(height: 15),
        ],

        // Sélection de taille
        if (_availableSizes.isNotEmpty) ...[
          _buildSizeSection(),
          const SizedBox(height: 15),
        ],

        // Variante sélectionnée (résumé)
        if (_selectedVariant != null) ...[
          _buildSelectedVariantSummary(),
        ],
      ],
    );
  }

  // ============================================
  // SECTION COULEUR
  // ============================================

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            if (_selectedColor != null)
              Text(
                ': $_selectedColor',
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
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _availableColors.asMap().entries.map((entry) {
            final index = entry.key;
            final colorName = entry.value;
            final colorCode = _getColorCodeForName(colorName);
            final isSelected = _selectedColor == colorName;

            return _buildColorSwatch(
              color: colorCode,
              colorName: colorName,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedColor = colorName;
                  _findVariant();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================
  // SECTION TAILLE
  // ============================================

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            if (_selectedSize != null)
              Text(
                ': $_selectedSize',
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSizes.map((size) {
            final isSelected = _selectedSize == size;
            final isAvailable = _isSizeAvailable(size, _selectedColor);

            return _buildSizeChip(
              size: size,
              isSelected: isSelected,
              isAvailable: isAvailable,
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedSize = size;
                        _findVariant();
                      });
                    }
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================
  // RÉSUMÉ DE LA VARIANTE SÉLECTIONNÉE
  // ============================================

  Widget _buildSelectedVariantSummary() {
    final variant = _selectedVariant!;
    final isInStock = variant.stock > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isInStock
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInStock
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isInStock ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isInStock ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              variant.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (variant.price != null)
            Text(
              _formatPrice(variant.price!),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // SWATCH DE COULEUR
  // ============================================

  Widget _buildColorSwatch({
    required Color color,
    required String colorName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: colorName,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
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
    );
  }

  // ============================================
  // CHIP DE TAILLE
  // ============================================

  Widget _buildSizeChip({
    required String size,
    required bool isSelected,
    required bool isAvailable,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isAvailable
                  ? Colors.white
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAvailable
                    ? AppColors.borderColor
                    : AppColors.borderColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          size,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isAvailable
                    ? AppColors.textPrimary
                    : AppColors.textLight,
            decoration: isAvailable
                ? null
                : TextDecoration.lineThrough,
          ),
        ),
      ),
    );
  }

  // ============================================
  // MÉTHODES INTERNES
  // ============================================

  void _findVariant() {
    ProductVariant? variant;

    for (final v in widget.variants) {
      final matchesColor = _selectedColor == null || v.color == _selectedColor;
      final matchesSize = _selectedSize == null || v.size == _selectedSize;

      if (matchesColor && matchesSize) {
        variant = v;
        break;
      }
    }

    setState(() {
      _selectedVariant = variant;
    });

    widget.onVariantSelected?.call(variant);
  }

  bool _isSizeAvailable(String size, String? color) {
    for (final v in widget.variants) {
      final matchesSize = v.size == size;
      final matchesColor = color == null || v.color == color;
      if (matchesSize && matchesColor && v.stock > 0) {
        return true;
      }
    }
    return false;
  }

  Color _getColorCodeForName(String colorName) {
    for (final v in widget.variants) {
      if (v.color == colorName && v.colorCode != null) {
        return _parseHexColor(v.colorCode!);
      }
    }
    return Colors.grey;
  }

  Color _parseHexColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  String _formatPrice(double amount) {
    final formatted = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      buffer.write(formatted[i]);
      if ((formatted.length - 1 - i) % 3 == 0 && i != formatted.length - 1) {
        buffer.write(' ');
      }
    }
    return '$buffer FCFA';
  }
}

// ============================================
// CLASSE VARIANTE PRODUIT
// ============================================

class ProductVariant {
  final int id;
  final String name;
  final String? color;
  final String? colorCode;
  final String? size;
  final double? price;
  final int stock;
  final bool isDefault;

  const ProductVariant({
    required this.id,
    required this.name,
    this.color,
    this.colorCode,
    this.size,
    this.price,
    this.stock = 0,
    this.isDefault = false,
  });
}