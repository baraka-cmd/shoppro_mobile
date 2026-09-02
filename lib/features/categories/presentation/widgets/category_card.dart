// ============================================
// CARTE DE CATÉGORIE - VERSION PREMIUM
// ============================================
// Grande carte visuelle avec image, nom et
// compteur de produits. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.width = 160,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ============================================
                // IMAGE DE FOND
                // ============================================
                if (category.hasImage)
                  CachedNetworkImage(
                    imageUrl: category.fullImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surface,
                    ),
                    errorWidget: (context, url, error) => _buildFallback(),
                  )
                else
                  _buildFallback(),

                // ============================================
                // OVERLAY GRADIENT
                // ============================================
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // ============================================
                // CONTENU
                // ============================================
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Nom de la catégorie
                      Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      // Compteur de produits
                      if (category.effectiveProductsCount > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          '${category.effectiveProductsCount} produits',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // FALLBACK SANS IMAGE
  // ============================================

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.7),
            AppColors.primaryDark.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(category.icon),
          size: 35,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE SELON CATÉGORIE
  // ============================================

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'devices':
      case 'phone_android':
        return Icons.phone_android;
      case 'checkroom':
      case 'fashion':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'restaurant':
        return Icons.restaurant;
      case 'sports':
        return Icons.sports;
      case 'beauty':
        return Icons.face;
      default:
        return Icons.category;
    }
  }
}