// ============================================
// BOTTOM SHEET DE FILTRES - VERSION PREMIUM
// ============================================
// Affiche les filtres pour affiner les produits.
// Prix, disponibilité, note minimale.
// Design conforme à la vision ShopPro.
// ============================================

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

  // ============================================
  // RÉINITIALISER
  // ============================================

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 0;
      _inStockOnly = false;
      _minRating = 0;
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _minPrice > 0 ||
        _maxPrice > 0 ||
        _inStockOnly ||
        _minRating > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
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

              // ============================================
              // TITRE
              // ============================================
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

              // ============================================
              // FILTRES
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix
                    const Text(
                      'PRIX (FCFA)',
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

                    // Disponibilité
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
                    const SizedBox(height: 5),
                    SwitchListTile(
                      value: _inStockOnly,
                      onChanged: (value) {
                        setState(() {
                          _inStockOnly = value;
                        });
                      },
                      activeColor: AppColors.primary,
                      title: const Text(
                        'En stock uniquement',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 15),

                    // Note minimale
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
                            child: AnimatedScale(
                              scale: _minRating >= rating ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 200),
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
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _minRating > 0
                          ? '${_minRating.toStringAsFixed(1)}+ étoiles'
                          : 'Aucune note minimale',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),

              // ============================================
              // BOUTONS
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: hasActiveFilters ? _resetFilters : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppColors.borderColor),
                        ),
                        child: const Text(
                          'RÉINITIALISER',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
                          elevation: 0,
                          shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          'APPLIQUER',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
      ),
    );
  }

  // ============================================
  // CHAMP DE PRIX
  // ============================================

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
        prefixStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
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
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ============================================
// CLASSE DE DONNÉES DE FILTRE
// ============================================

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

  int get activeFilterCount {
    var count = 0;
    if (minPrice > 0 || maxPrice > 0) count++;
    if (inStockOnly) count++;
    if (minRating > 0) count++;
    return count;
  }

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

// ============================================
// FONCTION POUR AFFICHER LE FILTER SHEET
// ============================================

Future<FilterData?> showFilterSheet({
  required BuildContext context,
  required FilterData currentFilters,
}) {
  return showModalBottomSheet<FilterData>(
    context: context,
    isScrollControlled: true,
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