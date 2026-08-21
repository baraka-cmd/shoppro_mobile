// Bottom sheet de filtres
// Affiche les filtres pour affiner les produits

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FilterSheet extends StatefulWidget {
  final FilterData currentFilters;
  final ValueChanged<FilterData>? onApply;

  const FilterSheet({
    super.key,
    required this.currentFilters,
    this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double _minPrice;
  late double _maxPrice;
  late bool _inStockOnly;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.currentFilters.minPrice;
    _maxPrice = widget.currentFilters.maxPrice;
    _inStockOnly = widget.currentFilters.inStockOnly;
    _minRating = widget.currentFilters.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),

            // Indicateur de glissement
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Titre
            const Text(
              'Filtres',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 20),

            // Contenu des filtres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre prix
                  const Text(
                    'PRIX',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceField(
                          label: 'Min',
                          value: _minPrice,
                          onChanged: (value) {
                            setState(() {
                              _minPrice = double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPriceField(
                          label: 'Max',
                          value: _maxPrice,
                          onChanged: (value) {
                            setState(() {
                              _maxPrice = double.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Filtre stock
                  const Text(
                    'DISPONIBILITÉ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Switch(
                        value: _inStockOnly,
                        onChanged: (value) {
                          setState(() {
                            _inStockOnly = value;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'En stock uniquement',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Filtre note
                  const Text(
                    'NOTE MINIMALE',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) {
                      final rating = (index + 1).toDouble();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _minRating = rating;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            _minRating >= rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 30,
                            color: _minRating >= rating
                                ? AppColors.ratingColor
                                : AppColors.textLight,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),

            // Boutons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = 0;
                          _maxPrice = 0;
                          _inStockOnly = false;
                          _minRating = 0;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'RÉINITIALISER',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onApply?.call(
                          FilterData(
                            minPrice: _minPrice,
                            maxPrice: _maxPrice,
                            inStockOnly: _inStockOnly,
                            minRating: _minRating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'APPLIQUER',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Champ de prix
  Widget _buildPriceField({
    required String label,
    required double value,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        prefixText: 'FCFA ',
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

// Classe de données de filtre
class FilterData {
  final double minPrice;
  final double maxPrice;
  final bool inStockOnly;
  final double minRating;

  const FilterData({
    this.minPrice = 0,
    this.maxPrice = 0,
    this.inStockOnly = false,
    this.minRating = 0,
  });

  bool get hasActiveFilters =>
      minPrice > 0 ||
      maxPrice > 0 ||
      inStockOnly ||
      minRating > 0;

  FilterData copyWith({
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    double? minRating,
  }) {
    return FilterData(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      minRating: minRating ?? this.minRating,
    );
  }
}

// Fonction pour afficher le filter sheet
Future<FilterData?> showFilterSheet({
  required BuildContext context,
  required FilterData currentFilters,
}) {
  return showModalBottomSheet<FilterData>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return FilterSheet(
        currentFilters: currentFilters,
        onApply: (filters) {
          Navigator.of(sheetContext).pop(filters);
        },
      );
    },
  );
}