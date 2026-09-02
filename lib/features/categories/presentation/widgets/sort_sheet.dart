// ============================================
// BOTTOM SHEET DE TRI - VERSION PREMIUM
// ============================================
// Affiche les options de tri des produits.
// Pertinence par défaut, 8 options complètes.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SortSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String>? onSortSelected;

  const SortSheet({
    super.key,
    required this.currentSort,
    this.onSortSelected,
  });

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
              'Trier par',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 15),

            // ============================================
            // OPTIONS DE TRI
            // ============================================
            _buildSortOption(
              context,
              icon: Icons.auto_awesome,
              label: 'Pertinence',
              value: 'created_at_desc',
            ),
            _buildSortOption(
              context,
              icon: Icons.local_fire_department,
              label: 'Popularité',
              value: 'popularity_desc',
            ),
            _buildSortOption(
              context,
              icon: Icons.access_time,
              label: 'Nouveautés',
              value: 'created_at_desc',
            ),
            _buildSortOption(
              context,
              icon: Icons.trending_up,
              label: 'Prix : croissant',
              value: 'price_asc',
            ),
            _buildSortOption(
              context,
              icon: Icons.trending_down,
              label: 'Prix : décroissant',
              value: 'price_desc',
            ),
            _buildSortOption(
              context,
              icon: Icons.sort_by_alpha,
              label: 'Nom : A → Z',
              value: 'name_asc',
            ),
            _buildSortOption(
              context,
              icon: Icons.sort_by_alpha,
              label: 'Nom : Z → A',
              value: 'name_desc',
            ),
            _buildSortOption(
              context,
              icon: Icons.star,
              label: 'Meilleures notes',
              value: 'rating_desc',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================
  // OPTION DE TRI
  // ============================================

  Widget _buildSortOption(
    BuildContext sheetContext, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = currentSort == value;

    return ListTile(
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 22,
            )
          : null,
      onTap: () {
        Navigator.of(sheetContext).pop();
        onSortSelected?.call(value);
      },
    );
  }
}

// ============================================
// FONCTION POUR AFFICHER LE SORT SHEET
// ============================================

Future<void> showSortSheet({
  required BuildContext context,
  required String currentSort,
  required ValueChanged<String> onSortSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SortSheet(
        currentSort: currentSort,
        onSortSelected: onSortSelected,
      );
    },
  );
}