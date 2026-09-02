// ============================================
// WIDGET : BlogCard
// ============================================
// Carte d'article de blog avec :
// - Image responsive
// - Badge catégorie élégant
// - Titre lisible
// - Métadonnées complètes
// - Animation au tap
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class BlogCard extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final String title;
  final String? imageUrl;
  final String? category;
  final String? author;
  final DateTime? date;
  final VoidCallback? onTap;
  final int readTime;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const BlogCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.category,
    this.author,
    this.date,
    this.onTap,
    this.readTime = 3,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // IMAGE (150px - réduite pour éviter overflow)
            // ============================================
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: _buildImage(),
              ),
            ),

            // ============================================
            // CONTENU (padding réduit)
            // ============================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge catégorie
                    if (category != null && category!.isNotEmpty) ...[
                      _buildCategoryBadge(),
                      const SizedBox(height: 4),
                    ],

                    // Titre (police réduite)
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Métadonnées (sans Spacer pour éviter overflow)
                    _buildMetaRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // IMAGE
  // ============================================

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.article_outlined,
          size: 28,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  // ============================================
  // BADGE CATÉGORIE
  // ============================================

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        category!.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: AppColors.warningDark,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ============================================
  // MÉTADONNÉES
  // ============================================

  Widget _buildMetaRow() {
    return Row(
      children: [
        if (author != null && author!.isNotEmpty) ...[
          Expanded(
            child: Text(
              author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (date != null) ...[
          const Icon(
            Icons.schedule,
            size: 9,
            color: AppColors.textLight,
          ),
          const SizedBox(width: 2),
          Text(
            '${_formatDate(date!)} · $readTime min',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 8,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  // ============================================
  // FORMATAGE DATE
  // ============================================

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    }
    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays}j';
    }
    if (difference.inHours > 0) {
      return 'il y a ${difference.inHours}h';
    }
    if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes}min';
    }
    return "à l'instant";
  }
}