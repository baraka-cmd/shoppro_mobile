// ============================================
// SECTION DES AVIS CLIENTS - VERSION PREMIUM
// ============================================
// Affiche la note moyenne, la distribution,
// la liste des avis et le bouton d'ajout.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'review_card.dart';

class ReviewsSection extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<ReviewCardData> reviews;
  final VoidCallback? onSeeAllReviews;
  final VoidCallback? onAddReview;
  final bool showAddButton;
  final int maxDisplayedReviews;

  const ReviewsSection({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.reviews,
    this.onSeeAllReviews,
    this.onAddReview,
    this.showAddButton = true,
    this.maxDisplayedReviews = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (totalReviews == 0 && reviews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // TITRE + BOUTON AJOUTER
        // ============================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AVIS CLIENTS',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            if (showAddButton && onAddReview != null)
              GestureDetector(
                onTap: onAddReview,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Écrire un avis',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 15),

        // ============================================
        // RÉSUMÉ DE LA NOTE
        // ============================================
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Note moyenne
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '$totalReviews avis',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isFilled = index < averageRating.round();
                      return Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        size: 14,
                        color: isFilled
                            ? AppColors.ratingColor
                            : AppColors.textLight,
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(width: 20),

              // Distribution des notes
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = ratingDistribution[star] ?? 0;
                    final percentage = totalReviews > 0
                        ? (count / totalReviews * 100).clamp(0.0, 100.0)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: AppColors.ratingColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 6,
                                backgroundColor: AppColors.surface,
                                color: AppColors.ratingColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 25,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // ============================================
        // LISTE DES AVIS (limités)
        // ============================================
        ...reviews.take(maxDisplayedReviews).map((review) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReviewCard(
              userName: review.userName,
              userAvatar: review.userAvatar,
              rating: review.rating,
              title: review.title,
              comment: review.comment,
              date: review.date,
              isVerifiedPurchase: review.isVerifiedPurchase,
              helpfulCount: review.helpfulCount,
              notHelpfulCount: review.notHelpfulCount,
              images: review.images,
            ),
          );
        }),

        // ============================================
        // BOUTON VOIR TOUS LES AVIS
        // ============================================
        if (totalReviews > maxDisplayedReviews && onSeeAllReviews != null)
          Center(
            child: TextButton(
              onPressed: onSeeAllReviews,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Voir tous les avis ($totalReviews)',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // ÉTAT VIDE
  // ============================================

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AVIS CLIENTS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  size: 40,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Aucun avis pour le moment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Soyez le premier à partager votre expérience',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 15),
                if (showAddButton && onAddReview != null)
                  ElevatedButton(
                    onPressed: onAddReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'DONNER MON AVIS',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// DONNÉES D'UN AVIS
// ============================================

class ReviewCardData {
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final String? title;
  final DateTime? date;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final int notHelpfulCount;
  final List<String>? images;

  const ReviewCardData({
    required this.userName,
    required this.rating,
    required this.comment,
    this.userAvatar,
    this.title,
    this.date,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.images,
  });
}