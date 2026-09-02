// ============================================
// BOTTOM SHEET DE FILTRES PRODUITS
// ============================================
// Réutilise le FilterSheet des catégories.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FilterSheet extends StatefulWidget {
  final int? categoryId;
  final int? brandId;
  final ValueChanged<Map<String, dynamic>>? onApply;

  const FilterSheet({
    super.key,
    this.categoryId,
    this.brandId,
    this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  bool _inStockOnly = false;
  bool _onSaleOnly = false;
  double _minRating = 0;

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _inStockOnly = false;
      _onSaleOnly = false;
      _minRating = 0;
    });
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            controller: _minPriceController,
                            label: 'Min',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildPriceField(
                            controller: _maxPriceController,
                            label: 'Max',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                    SwitchListTile(
                      value: _onSaleOnly,
                      onChanged: (value) {
                        setState(() {
                          _onSaleOnly = value;
                        });
                      },
                      activeColor: AppColors.primary,
                      title: const Text(
                        'En promotion uniquement',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
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
                          widget.onApply?.call({
                            'category_id': widget.categoryId,
                            'brand_id': widget.brandId,
                            'min_price': double.tryParse(_minPriceController.text),
                            'max_price': double.tryParse(_maxPriceController.text),
                            'in_stock': _inStockOnly,
                            'on_sale': _onSaleOnly,
                            'min_rating': _minRating,
                          });
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

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
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