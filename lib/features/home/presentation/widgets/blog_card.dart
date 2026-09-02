// Carte d'article de blog
// Affiche l'image, le titre, la date et la catégorie

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class BlogCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? category;
  final String? author;
  final DateTime? date;
  final VoidCallback? onTap;
  final int readTime;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.article,
                            size: 30,
                            color: AppColors.textLight,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.article,
                          size: 30,
                          color: AppColors.textLight,
                        ),
                      ),
              ),
            ),

            // Badge catégorie
            if (category != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category!.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Titre
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),

            const Spacer(),

            // Auteur + Date + Temps de lecture
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Auteur
                  if (author != null)
                    Expanded(
                      child: Text(
                        author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  // Date + Temps
                  if (date != null) ...[
                    const Icon(
                      Icons.access_time,
                      size: 10,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${_formatDate(date!)} · $readTime min',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    }
    return '${difference.inMinutes}min';
  }
}