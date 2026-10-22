// ============================================
// WIDGET : SellerReviewTile
// ============================================
// Carte d'avis client pour la liste vendeur.
//
// Design :
//   - Header : avatar client + nom + note (étoiles) + date
//   - Titre + contenu de l'avis
//   - Galerie photos (miniatures cliquables)
//   - Badge "Achat vérifié" si applicable
//   - Stats utilité (votes utiles / pas utiles)
//   - Réponse vendeur (si existante) dans un encadré
//   - Menu d'actions (répondre, approuver, rejeter, spam)
//
// UX :
//   - Tap → détail complet
//   - Menu actions rapides
//   - Pulse si action requise (pending)
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_review.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerReviewTile extends StatelessWidget {
  final SellerReview review;
  final VoidCallback? onTap;
  final VoidCallback? onRespond;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onMarkSpam;
  final bool isProcessing;

  const SellerReviewTile({
    super.key,
    required this.review,
    this.onTap,
    this.onRespond,
    this.onApprove,
    this.onReject,
    this.onMarkSpam,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: review.isPending
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : AppColors.borderColor.withValues(alpha: 0.6),
                width: review.isPending ? 1.5 : 1,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // HEADER : Client + Note + Date + Menu
                // ============================================
                _buildHeader(context),

                const SizedBox(height: 10),

                // ============================================
                // TITRE + CONTENU
                // ============================================
                _buildContent(),

                // ============================================
                // PHOTOS
                // ============================================
                if (review.hasImages) ...[
                  const SizedBox(height: 10),
                  _buildImages(context),
                ],

                // ============================================
                // BADGE "ACHAT VÉRIFIÉ"
                // ============================================
                if (review.isVerifiedPurchase) ...[
                  const SizedBox(height: 10),
                  _buildVerifiedBadge(),
                ],

                // ============================================
                // STATS UTILITÉ
                // ============================================
                if (review.totalVotes > 0) ...[
                  const SizedBox(height: 10),
                  _buildHelpfulStats(),
                ],

                // ============================================
                // RÉPONSE VENDEUR
                // ============================================
                if (review.hasResponse) ...[
                  const SizedBox(height: 10),
                  _buildAdminResponse(),
                ],

                // ============================================
                // ACTIONS RAPIDES (si pending ou approved)
                // ============================================
                if (!isProcessing && _hasAvailableActions()) ...[
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                ],

                if (isProcessing) ...[
                  const SizedBox(height: 12),
                  const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // HEADER
  // ============================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar client
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              review.customer?.initials ?? '?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Nom + Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      review.customer?.name ?? 'Client',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (review.isPending) ...[
                    const SizedBox(width: 6),
                    _buildPendingBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _buildStars(review.rating),
                  const SizedBox(width: 6),
                  Text(
                    review.ratingLabel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      review.createdAtHuman ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Menu actions
        if (!isProcessing && _hasAvailableActions())
          _buildMenuButton(context)
        else if (isProcessing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.warning,
            ),
          ),
      ],
    );
  }

  Widget _buildPendingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.statusPendingBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'À modérer',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.statusPendingText,
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < rating;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 12,
          color: isFilled
              ? AppColors.ratingColor
              : AppColors.ratingEmptyColor,
        );
      }),
    );
  }

  // ============================================
  // CONTENU (TITRE + DESCRIPTION)
  // ============================================

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (review.title != null && review.title!.isNotEmpty) ...[
          Text(
            review.title!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        Text(
          review.shortContent,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ============================================
  // IMAGES
  // ============================================

  Widget _buildImages(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final image = review.images[index];
          return GestureDetector(
            onTap: () => _showImageFullscreen(context, image.url),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  image.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceAlt,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 24,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageFullscreen(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenImageViewer(imageUrl: url),
      ),
    );
  }

  // ============================================
  // BADGE VÉRIFIÉ
  // ============================================

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 12,
            color: AppColors.successDark,
          ),
          SizedBox(width: 4),
          Text(
            'Achat vérifié',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.successDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS UTILITÉ
  // ============================================

  Widget _buildHelpfulStats() {
    return Row(
      children: [
        const Icon(
          Icons.thumb_up_outlined,
          size: 12,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          '${review.helpfulCount} utile${review.helpfulCount > 1 ? 's' : ''}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.thumb_down_outlined,
          size: 12,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          '${review.notHelpfulCount}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ============================================
  // RÉPONSE VENDEUR
  // ============================================

  Widget _buildAdminResponse() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 12,
                color: AppColors.warning,
              ),
              SizedBox(width: 6),
              Text(
                'Votre réponse',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.adminResponse!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACTIONS RAPIDES
  // ============================================

  bool _hasAvailableActions() {
    return review.canApprove ||
        review.canReject ||
        review.canRespond ||
        review.canMarkSpam;
  }

  Widget _buildQuickActions() {
    final actions = <Widget>[];

    if (review.canApprove) {
      actions.add(_buildActionChip(
        icon: Icons.check_rounded,
        label: 'Approuver',
        color: AppColors.success,
        onTap: onApprove,
      ));
    }

    if (review.canReject) {
      actions.add(_buildActionChip(
        icon: Icons.close_rounded,
        label: 'Rejeter',
        color: AppColors.error,
        onTap: onReject,
      ));
    }

    if (review.canRespond) {
      actions.add(_buildActionChip(
        icon: Icons.reply_rounded,
        label: 'Répondre',
        color: AppColors.info,
        onTap: onRespond,
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: actions,
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // MENU ACTIONS
  // ============================================

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: AppColors.textTertiary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.background,
      elevation: 4,
      onSelected: (value) {
        switch (value) {
          case 'respond':
            onRespond?.call();
            break;
          case 'approve':
            onApprove?.call();
            break;
          case 'reject':
            onReject?.call();
            break;
          case 'spam':
            onMarkSpam?.call();
            break;
        }
      },
      itemBuilder: (menuContext) {
        final items = <PopupMenuEntry<String>>[];

        if (review.canRespond) {
          items.add(_buildMenuItem(
            value: 'respond',
            icon: Icons.reply_rounded,
            label: review.hasResponse ? 'Modifier la réponse' : 'Répondre',
            color: AppColors.info,
          ));
        }

        if (review.canApprove) {
          items.add(_buildMenuItem(
            value: 'approve',
            icon: Icons.check_circle_outline_rounded,
            label: 'Approuver',
            color: AppColors.success,
          ));
        }

        if (review.canReject) {
          items.add(_buildMenuItem(
            value: 'reject',
            icon: Icons.cancel_outlined,
            label: 'Rejeter',
            color: AppColors.error,
          ));
        }

        if (review.canMarkSpam) {
          items.add(_buildMenuItem(
            value: 'spam',
            icon: Icons.report_outlined,
            label: 'Marquer comme spam',
            color: AppColors.promo,
          ));
        }

        return items;
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGET : _FullscreenImageViewer
// ============================================
// Affiche une image en plein écran avec zoom.
// ============================================

class _FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullscreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 60,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}