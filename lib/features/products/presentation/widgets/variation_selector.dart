// Sélecteur de variations du produit
// Permet de choisir couleur, taille et autres options

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';

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
    // Sélectionner la variante par défaut
    if (widget.variants.isNotEmpty) {
      _selectedVariant = widget.variants.firstWhere(
        (v) => v.isDefault,
        orElse: () => widget.variants.first,
      );
      _selectedColor = _selectedVariant?.color;
      _selectedSize = _selectedVariant?.size;
      widget.onVariantSelected?.call(_selectedVariant);
    }
  }

  // Récupérer les couleurs uniques
  List<String> get _availableColors {
    return widget.variants
        .map((v) => v.color)
        .where((c) => c != null && c!.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
  }

  // Récupérer les tailles uniques
  List<String> get _availableSizes {
    return widget.variants
        .map((v) => v.size)
        .where((s) => s != null && s!.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
  }

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
          _buildVariationGroup(
            label: 'Couleur',
            selectedValue: _selectedColor,
            values: _availableColors,
            colors: _getColorCodes(),
            onSelected: (color) {
              setState(() {
                _selectedColor = color;
                _findVariant();
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        // Sélection de taille
        if (_availableSizes.isNotEmpty) ...[
          _buildVariationGroup(
            label: 'Taille',
            selectedValue: _selectedSize,
            values: _availableSizes,
            onSelected: (size) {
              setState(() {
                _selectedSize = size;
                _findVariant();
              });
            },
          ),
          const SizedBox(height: 12),
        ],

        // Variante sélectionnée
        if (_selectedVariant != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedVariant!.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatPrice(_selectedVariant!.price ?? 0),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Construire un groupe de variations
  Widget _buildVariationGroup({
    required String label,
    required String? selectedValue,
    required List<String> values,
    List<Color>? colors,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value;
            final isSelected = selectedValue == value;

            if (colors != null && colors.isNotEmpty && index < colors.length) {
              // Variation de couleur (cercle coloré)
              return _buildColorChip(
                color: colors[index],
                value: value,
                isSelected: isSelected,
                onTap: () => onSelected(value),
              );
            }

            // Variation de taille (texte)
            return _buildTextChip(
              value: value,
              isSelected: isSelected,
              onTap: () => onSelected(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Chip de couleur
  Widget _buildColorChip({
    required Color color,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
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
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 5,
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
    );
  }

  // Chip de texte
  Widget _buildTextChip({
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // Trouver la variante correspondante
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

  // Récupérer les codes couleur
  List<Color> _getColorCodes() {
    return widget.variants
        .where((v) => v.colorCode != null && v.colorCode!.isNotEmpty)
        .map((v) => _parseHexColor(v.colorCode!))
        .toList();
  }

  // Parser une couleur hexadécimale
  Color _parseHexColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  // Formater le prix
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

// Classe de variante produit
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