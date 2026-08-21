// Grille des catégories
// Affiche les catégories en grille avec icônes et noms

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final bool isLoading;
  final int crossAxisCount;
  final VoidCallback? onSeeAll;
  final void Function(Category)? onCategoryTap;
  final bool showTitle;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.isLoading = false,
    this.crossAxisCount = 4,
    this.onSeeAll,
    this.onCategoryTap,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + Voir tout
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'CATÉGORIES',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Row(
                    children: [
                      Text(
                        'Voir tout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // Grille des catégories
        if (isLoading)
          _buildLoadingGrid()
        else if (categories.isEmpty)
          _buildEmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(category);
            },
          ),
      ],
    );
  }

  // Construire un item de catégorie
  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: onCategoryTap != null
          ? () => onCategoryTap!(category)
          : null,
      child: Column(
        children: [
          // Icône
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _getCategoryIcon(category),
              size: 25,
              color: _getCategoryColor(category),
            ),
          ),

          const SizedBox(height: 6),

          // Nom
          Text(
            category.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Icône selon la catégorie
  IconData _getCategoryIcon(Category category) {
    final slug = category.slug.toLowerCase();

    if (slug.contains('electro')) return Icons.phone_android;
    if (slug.contains('mode') || slug.contains('vetement')) return Icons.checkroom;
    if (slug.contains('maison') || slug.contains('jardin')) return Icons.home;
    if (slug.contains('beaute') || slug.contains('sante')) return Icons.spa;
    if (slug.contains('sport')) return Icons.sports_soccer;
    if (slug.contains('aliment')) return Icons.restaurant;
    if (slug.contains('jouet') || slug.contains('enfant')) return Icons.toys;
    if (slug.contains('auto')) return Icons.directions_car;
    return Icons.category;
  }

  // Couleur selon la catégorie
  Color _getCategoryColor(Category category) {
    final slug = category.slug.toLowerCase();

    if (slug.contains('electro')) return AppColors.primary;
    if (slug.contains('mode') || slug.contains('vetement')) return AppColors.secondary;
    if (slug.contains('maison') || slug.contains('jardin')) return AppColors.success;
    if (slug.contains('beaute') || slug.contains('sante')) return const Color(0xFFE91E63);
    if (slug.contains('sport')) return AppColors.info;
    if (slug.contains('aliment')) return const Color(0xFFFF9800);
    if (slug.contains('jouet') || slug.contains('enfant')) return const Color(0xFF9C27B0);
    if (slug.contains('auto')) return const Color(0xFF607D8B);
    return AppColors.textSecondary;
  }

  // Grille de chargement
  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 50,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: const Center(
        child: Text(
          'Aucune catégorie',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}