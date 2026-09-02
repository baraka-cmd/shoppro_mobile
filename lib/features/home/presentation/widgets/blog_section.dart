// ============================================
// WIDGET : BlogSection
// ============================================
// Section "Conseils & tendances" avec :
// - Titre élégant avec icône
// - Sous-titre descriptif
// - Scroll horizontal de cartes d'articles
// - Design éditorial premium
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'blog_card.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class BlogSection extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final List<Map<String, dynamic>> articles;
  final VoidCallback? onSeeAllTap;
  final ValueChanged<Map<String, dynamic>>? onArticleTap;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const BlogSection({
    super.key,
    required this.articles,
    this.onSeeAllTap,
    this.onArticleTap,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // EN-TÊTE DE LA SECTION
          // ============================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Conseils & tendances',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                if (onSeeAllTap != null)
                  GestureDetector(
                    onTap: onSeeAllTap,
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
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ============================================
          // SOUS-TITRE
          // ============================================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Des conseils pour mieux choisir',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ============================================
          // LISTE DES ARTICLES (SCROLL HORIZONTAL)
          // ============================================
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: BlogCard(
                    title: article['title'] as String? ?? 'Article',
                    imageUrl: article['imageUrl'] as String?,
                    category: article['category'] as String?,
                    author: article['author'] as String?,
                    date: article['date'] as DateTime?,
                    readTime: article['readTime'] as int? ?? 3,
                    onTap: () => onArticleTap?.call(article),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}