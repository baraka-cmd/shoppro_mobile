// ============================================
// BARRE DE FILTRES ET TRI - VERSION PREMIUM
// ============================================
// Affiche les boutons de filtrage et de tri
// avec état actif et compteur dynamique.
// Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FilterBar extends StatelessWidget {
  final int totalProducts;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSortTap;
  final String currentSort;
  final bool hasActiveFilters;
  final int activeFiltersCount;

  const FilterBar({
    super.key,
    required this.totalProducts,
    this.onFilterTap,
    this.onSortTap,
    this.currentSort = 'Plus récents',
    this.hasActiveFilters = false,
    this.activeFiltersCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // ============================================
          // NOMBRE DE PRODUITS
          // ============================================
          Expanded(
            child: Text(
              '$totalProducts produit${totalProducts > 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // ============================================
          // BOUTON FILTRES
          // ============================================
          GestureDetector(
            onTap: onFilterTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasActiveFilters
                      ? AppColors.primary
                      : AppColors.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 14,
                    color: hasActiveFilters
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasActiveFilters
                        ? 'Filtres ($activeFiltersCount)'
                        : 'Filtres',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasActiveFilters
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ============================================
          // BOUTON TRI
          // ============================================
          GestureDetector(
            onTap: onSortTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentSort,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}