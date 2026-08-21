// Carte d'avis client
// Affiche avatar, nom, note, commentaire et badges

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReviewCard extends StatelessWidget {
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
  final VoidCallback? onHelpful;
  final VoidCallback? onNotHelpful;

  const ReviewCard({
    super.key,
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
    this.onHelpful,
    this.onNotHelpful,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Avatar + Nom + Badge
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: userAvatar != null && userAvatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          userAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitials();
                          },
                        ),
                      )
                    : _buildInitials(),
              ),

              const SizedBox(width: 10),

              // Nom + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isVerifiedPurchase) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 10,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Achat vérifié',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(date!),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Étoiles
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < rating.round();
              return Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: 16,
                color: isFilled ? AppColors.ratingColor : AppColors.textLight,
              );
            }),
          ),

          // Titre
          if (title != null && title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              title!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          // Commentaire
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          // Images de l'avis
          if (images != null && images!.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.borderColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.network(
                        images![index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 20,
                            color: AppColors.textLight,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Actions utiles
          if (onHelpful != null || onNotHelpful != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Cet avis est-il utile ?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                // Utile
                GestureDetector(
                  onTap: onHelpful,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$helpfulCount',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Pas utile
                GestureDetector(
                  onTap: onNotHelpful,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.thumb_down,
                          size: 12,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$notHelpfulCount',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Initiales
  Widget _buildInitials() {
    final initials = _getInitials(userName);
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Récupérer les initiales
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // Formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} an(s)';
    }
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mois';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} jour(s)';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} heure(s)';
    }
    return 'À l\'instant';
  }
}