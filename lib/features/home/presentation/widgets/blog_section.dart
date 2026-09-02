// Section blog/actualités
// Affiche les articles en scroll horizontal

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'blog_card.dart';

class BlogSection extends StatelessWidget {
  final List<BlogArticle> articles;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final ValueChanged<BlogArticle>? onArticleTap;

  const BlogSection({
    super.key,
    required this.articles,
    this.isLoading = false,
    this.onSeeAll,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête : Titre + Voir tout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.article,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'ACTUALITÉS',
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
                        fontSize: 11,
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

        // Liste horizontale des articles
        if (isLoading)
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderColor.withValues(alpha: 0.5),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: BlogCard(
                    title: article.title,
                    imageUrl: article.imageUrl,
                    category: article.category,
                    author: article.author,
                    date: article.date,
                    readTime: article.readTime,
                    onTap: () => onArticleTap?.call(article),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Modèle d'article de blog
class BlogArticle {
  final int id;
  final String title;
  final String? imageUrl;
  final String? category;
  final String? author;
  final DateTime? date;
  final int readTime;

  const BlogArticle({
    required this.id,
    required this.title,
    this.imageUrl,
    this.category,
    this.author,
    this.date,
    this.readTime = 3,
  });
}