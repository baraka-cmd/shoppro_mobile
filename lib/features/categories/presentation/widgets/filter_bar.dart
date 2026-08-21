// Barre de filtres et tri
// Affiche les boutons de filtrage et de tri

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FilterBar extends StatelessWidget {
  final int totalProducts;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSortTap;
  final String currentSort;
  final bool hasActiveFilters;

  const FilterBar({
    super.key,
    required this.totalProducts,
    this.onFilterTap,
    this.onSortTap,
    this.currentSort = 'Plus récents',
    this.hasActiveFilters = false,
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
          // Nombre de produits
          Expanded(
            child: Text(
              '$totalProducts produits',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Bouton Filtres
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
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
                    'Filtres',
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

          // Bouton Tri
          GestureDetector(
            onTap: onSortTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
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