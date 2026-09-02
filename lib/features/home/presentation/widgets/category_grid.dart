// ============================================
// WIDGET : CategoryGrid
// ============================================
// Grille de catégories horizontale avec :
// - Icônes légères dans des cercles pastel
// - Scroll horizontal fluide
// - Design épuré
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/category.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category>? onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  // ============================================
  // COULEURS PASTEL POUR LES ICÔNES
  // ============================================

  static const List<Color> _pastelColors = [
    Color(0xFFDBEAFE), // Bleu pastel
    Color(0xFFD1FAE5), // Vert pastel
    Color(0xFFFEF3C7), // Orange pastel
    Color(0xFFFFE4E4), // Corail pastel
    Color(0xFFF3E8FF), // Violet pastel
    Color(0xFFE0F2FE), // Cyan pastel
    Color(0xFFFCE7F3), // Rose pastel
    Color(0xFFFEF9C3), // Jaune pastel
  ];

  static const List<Color> _iconColors = [
    Color(0xFF2563EB), // Bleu Royal
    Color(0xFF10B981), // Vert succès
    Color(0xFFF59E0B), // Orange/Or
    Color(0xFFFF6B6B), // Corail
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Rose
    Color(0xFFCA8A04), // Jaune foncé
  ];

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 95,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final colorIndex = index % _pastelColors.length;
          return _buildCategoryItem(
            category,
            _pastelColors[colorIndex],
            _iconColors[colorIndex],
          );
        },
      ),
    );
  }

  // ============================================
  // ITEM DE CATÉGORIE
  // ============================================

  Widget _buildCategoryItem(
    Category category,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: () => onCategoryTap?.call(category),
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            // ============================================
            // CERCLE D'ICÔNE
            // ============================================
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(category),
                  size: 24,
                  color: iconColor,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ============================================
            // NOM DE LA CATÉGORIE
            // ============================================
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE SELON LA CATÉGORIE
  // ============================================

  IconData _getCategoryIcon(Category category) {
    final name = category.name.toLowerCase();

    if (name.contains('tech') || name.contains('electron')) {
      return Icons.devices_outlined;
    }
    if (name.contains('mode') || name.contains('vet')) {
      return Icons.checkroom_outlined;
    }
    if (name.contains('maison') || name.contains('home')) {
      return Icons.home_outlined;
    }
    if (name.contains('beaut') || name.contains('soin')) {
      return Icons.spa_outlined;
    }
    if (name.contains('sport')) {
      return Icons.sports_basketball_outlined;
    }
    if (name.contains('jouet') || name.contains('toy')) {
      return Icons.toys_outlined;
    }
    if (name.contains('livre') || name.contains('book')) {
      return Icons.menu_book_outlined;
    }
    if (name.contains('auto') || name.contains('voiture')) {
      return Icons.directions_car_outlined;
    }
    if (name.contains('aliment') || name.contains('food')) {
      return Icons.restaurant_outlined;
    }

    return Icons.category_outlined;
  }
}