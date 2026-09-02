// ============================================
// ÉLÉMENT DE LISTE CATÉGORIE - VERSION PREMIUM
// ============================================
// Affiche icône, nom, description et compteur.
// Design ShopPro avec effet ripple et ombre.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/category.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final int productsCount;

  const CategoryListItem({
    super.key,
    required this.category,
    this.onTap,
    this.productsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ============================================
                // ICÔNE DE LA CATÉGORIE
                // ============================================
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    size: 25,
                    color: _getCategoryColor(category),
                  ),
                ),

                const SizedBox(width: 14),

                // ============================================
                // INFORMATIONS
                // ============================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 3),

                      if (category.description != null &&
                          category.description!.isNotEmpty)
                        Text(
                          category.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$productsCount produits',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(category),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ============================================
                // BADGE VEDETTE
                // ============================================
                if (category.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 10,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'Vedette',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE SELON LA CATÉGORIE
  // ============================================

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

  // ============================================
  // COULEUR SELON LA CATÉGORIE
  // ============================================

  Color _getCategoryColor(Category category) {
    final slug = category.slug.toLowerCase();

    if (slug.contains('electro')) return AppColors.primary;
    if (slug.contains('mode') || slug.contains('vetement')) return AppColors.warning;
    if (slug.contains('maison') || slug.contains('jardin')) return AppColors.success;
    if (slug.contains('beaute') || slug.contains('sante')) return const Color(0xFFE91E63);
    if (slug.contains('sport')) return AppColors.info;
    if (slug.contains('aliment')) return const Color(0xFFFF9800);
    if (slug.contains('jouet') || slug.contains('enfant')) return const Color(0xFF9C27B0);
    if (slug.contains('auto')) return const Color(0xFF607D8B);
    return AppColors.textSecondary;
  }
}