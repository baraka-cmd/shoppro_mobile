// ============================================
// MINIATURE PRODUIT - VERSION PREMIUM
// ============================================
// Petite carte miniature pour la galerie produit.
// Bordure animée, surbrillance et ombre selon
// l'état de sélection. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const ProductThumbnail({
    super.key,
    required this.imageUrl,
    this.isSelected = false,
    this.onTap,
    this.size = 55,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ),

              // Overlay sélection
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}