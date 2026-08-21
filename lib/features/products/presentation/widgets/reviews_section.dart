// Section des avis clients
// Affiche la note moyenne, la distribution et la liste des avis

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

  const ReviewsSection({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.reviews,
    this.onSeeAllReviews,
    this.onAddReview,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (totalReviews == 0 && reviews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
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
            if (showAddButton)
              GestureDetector(
                onTap: onAddReview,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
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

        // Résumé de la note
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
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
                        ? (count / totalReviews * 100).clamp(0, 100)
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
                                backgroundColor: AppColors.background,
                                color: AppColors.ratingColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 25,
                            child: Text(
                              '$count',
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

        // Liste des avis (max 3 affichés)
        ...reviews.take(3).map((review) {
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

        // Bouton voir tous les avis
        if (totalReviews > 3)
          Center(
            child: TextButton(
              onPressed: onSeeAllReviews,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
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

  // État vide
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
                const SizedBox(height: 10),
                if (showAddButton)
                  ElevatedButton(
                    onPressed: onAddReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SOYEZ LE PREMIER À DONNER VOTRE AVIS',
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

// Données d'un avis
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