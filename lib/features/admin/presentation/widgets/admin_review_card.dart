// ============================================
// WIDGET : AdminReviewCard (MOBILE SENIOR)
// ============================================
// Carte d'avis client réutilisable pour l'admin.
// - Avatar utilisateur (réseau + fallback initiales)
// - Étoiles + date
// - Badge statut
// - Titre + contenu
// - Photos miniatures (scrollables)
// - Réponse admin (si présente)
// - Actions contextuelles (approuver, rejeter, répondre, supprimer)
// - Mode compact (pour accordéons)
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Entities
import '../../domain/entities/admin_review.dart';

class AdminReviewCard extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// L'avis à afficher
  final AdminReview review;

  /// Mode compact (utilisé dans les accordéons par produit)
  final bool compact;

  /// Callback : approuver
  final VoidCallback? onApprove;

  /// Callback : rejeter
  final VoidCallback? onReject;

  /// Callback : répondre
  final VoidCallback? onRespond;

  /// Callback : remettre en attente
  final VoidCallback? onReset;

  /// Callback : supprimer
  final VoidCallback? onDelete;

  /// Callback : tap sur la carte (ouvre le détail)
  final VoidCallback? onTap;

  /// Callback : tap sur une photo
  final void Function(int index)? onImageTap;

  /// Désactive les actions (ex: pendant une mise à jour)
  final bool actionsDisabled;

  const AdminReviewCard({
    super.key,
    required this.review,
    this.compact = false,
    this.onApprove,
    this.onReject,
    this.onRespond,
    this.onReset,
    this.onDelete,
    this.onTap,
    this.onImageTap,
    this.actionsDisabled = false,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: compact ? AppColors.surfaceAlt : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: compact ? const [] : AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // EN-TÊTE : AVATAR + NOM + ÉTOILES + STATUT
              // ============================================
              _buildHeader(),

              const SizedBox(height: 10),

              // ============================================
              // TITRE (optionnel)
              // ============================================
              if (review.hasTitle) ...[
                Text(
                  review.title!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],

              // ============================================
              // CONTENU
              // ============================================
              Text(
                review.content,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: compact ? 2 : 4,
                overflow: TextOverflow.ellipsis,
              ),

              // ============================================
              // PHOTOS
              // ============================================
              if (review.hasImages) ...[
                const SizedBox(height: 10),
                _buildImagesSection(),
              ],

              // ============================================
              // PRODUIT CONCERNÉ (masqué en compact)
              // ============================================
              if (!compact) ...[
                const SizedBox(height: 8),
                _buildProductChip(),
              ],

              // ============================================
              // RÉPONSE ADMIN (si présente)
              // ============================================
              if (review.hasAdminResponse) ...[
                const SizedBox(height: 10),
                _buildAdminResponse(),
              ],

              // ============================================
              // SÉPARATEUR + ACTIONS
              // ============================================
              if (_hasAnyAction) ...[
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.borderColor),
                const SizedBox(height: 8),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // EN-TÊTE
  // ============================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  // Étoiles
                  ...List.generate(5, (i) {
                    return Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 12,
                      color: AppColors.warning,
                    );
                  }),
                  const SizedBox(width: 6),
                  // Date
                  Text(
                    review.createdAtFormatted,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5,
                      color: AppColors.textLight,
                    ),
                  ),
                  // Badge vérifié
                  if (review.isVerifiedPurchase) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      size: 11,
                      color: AppColors.success,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  // ============================================
  // AVATAR
  // ============================================

  Widget _buildAvatar() {
    final hasAvatar =
        review.userAvatar != null && review.userAvatar!.isNotEmpty;
    final size = compact ? 32.0 : 40.0;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? CachedNetworkImage(
              imageUrl: review.userAvatar!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildInitials(),
              errorWidget: (_, __, ___) => _buildInitials(),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final parts = review.userName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (review.userName.isNotEmpty
            ? review.userName[0].toUpperCase()
            : '?');

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // BADGE STATUT
  // ============================================

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;
    IconData? icon;

    if (review.isPending) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'En attente';
      icon = Icons.hourglass_empty;
    } else if (review.isApproved) {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'Approuvé';
      icon = Icons.check_circle_outline;
    } else if (review.isRejected) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Rejeté';
      icon = Icons.cancel_outlined;
    } else if (review.isSpam) {
      bgColor = AppColors.surfaceAlt;
      textColor = AppColors.textTertiary;
      label = 'Spam';
      icon = Icons.block;
    } else {
      bgColor = AppColors.surfaceAlt;
      textColor = AppColors.textTertiary;
      label = 'Inconnu';
      icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PHOTOS
  // ============================================

  Widget _buildImagesSection() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: review.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => onImageTap?.call(i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: review.images[i],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceAlt,
                  child: const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.surfaceAlt,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // PRODUIT CHIP
  // ============================================

  Widget _buildProductChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (review.productImage != null &&
              review.productImage!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: review.productImage!,
                width: 16,
                height: 16,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 6),
          ] else ...[
            const Icon(
              Icons.inventory_2_outlined,
              size: 12,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              review.productName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  Widget _buildAdminResponse() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 12,
                color: AppColors.info,
              ),
              const SizedBox(width: 4),
              const Text(
                'Réponse admin',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
              const Spacer(),
              if (review.adminResponseAt != null)
                Text(
                  review.adminResponseAtFormatted,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.adminResponse!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  bool get _hasAnyAction {
    if (actionsDisabled) return false;
    if (review.isPending && (onApprove != null || onReject != null)) return true;
    if (review.isApproved && onRespond != null) return true;
    if ((review.isRejected || review.isSpam) && onReset != null) return true;
    if (onDelete != null) return true;
    return false;
  }

  Widget _buildActions() {
    final actions = <Widget>[];

    // Avis en attente : Approuver + Rejeter
    if (review.isPending) {
      if (onApprove != null) {
        actions.add(_buildActionButton(
          label: 'Approuver',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          onTap: onApprove!,
        ));
        actions.add(const SizedBox(width: 6));
      }
      if (onReject != null) {
        actions.add(_buildActionButton(
          label: 'Rejeter',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onTap: onReject!,
        ));
      }
    }

    // Avis approuvé : Répondre
    else if (review.isApproved && onRespond != null) {
      actions.add(_buildActionButton(
        label: review.hasAdminResponse ? 'Modifier réponse' : 'Répondre',
        icon: Icons.reply_outlined,
        color: AppColors.info,
        onTap: onRespond!,
      ));
    }

    // Avis rejeté ou spam : Remettre en attente
    else if ((review.isRejected || review.isSpam) && onReset != null) {
      actions.add(_buildActionButton(
        label: 'Remettre en attente',
        icon: Icons.refresh,
        color: AppColors.warning,
        onTap: onReset!,
      ));
    }

    // Toujours : Supprimer
    if (onDelete != null) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: 6));
      }
      actions.add(_buildActionButton(
        label: 'Supprimer',
        icon: Icons.delete_outline,
        color: AppColors.error,
        onTap: onDelete!,
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}