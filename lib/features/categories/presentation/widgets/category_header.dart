// Header de catégorie
// Affiche l'image, le nom et la description de la catégorie

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/category.dart';

class CategoryHeader extends StatelessWidget {
  final Category category;
  final int productsCount;
  final VoidCallback? onImageTap;

  const CategoryHeader({
    super.key,
    required this.category,
    this.productsCount = 0,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Image de fond
            SizedBox(
              height: 180,
              width: double.infinity,
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: _getCategoryColor(category).withValues(alpha: 0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: _getCategoryColor(category),
                        child: Icon(
                          _getCategoryIcon(category),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      color: _getCategoryColor(category),
                      child: Icon(
                        _getCategoryIcon(category),
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
            ),

            // Overlay dégradé
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Informations
            Positioned(
              left: 20,
              right: 20,
              bottom: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la catégorie
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Description
                  if (category.description != null &&
                      category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),

                  const SizedBox(height: 5),

                  // Nombre de produits
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$productsCount produits',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge vedette
            if (category.isFeatured)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'VEDETTE',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
}