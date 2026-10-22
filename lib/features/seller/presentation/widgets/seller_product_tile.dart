// ============================================
// WIDGET : SellerProductTile
// ============================================
// Carte de produit pour la liste vendeur.
//
// Design :
//   - Image carrée à gauche (80x80)
//   - Nom + SKU + catégorie
//   - Badges de statut (Brouillon, Publié, Archivé, Rupture)
//   - Prix + stock
//   - Menu d'actions (éditer, dupliquer, publier, supprimer)
//
// UX :
//   - Tap → détail produit
//   - Tap sur menu → actions rapides
//   - Feedback visuel pour les actions en cours
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerProductTile extends StatelessWidget {
  final SellerProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onPublish;
  final VoidCallback? onUnpublish;
  final VoidCallback? onDelete;
  final bool isProcessing;

  const SellerProductTile({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onPublish,
    this.onUnpublish,
    this.onDelete,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // IMAGE
                // ============================================
                _buildImage(),

                const SizedBox(width: 12),

                // ============================================
                // INFOS
                // ============================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nom + menu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isProcessing) _buildMenuButton(context),
                          if (isProcessing)
                            const Padding(
                              padding: EdgeInsets.only(left: 8, top: 2),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // SKU + Catégorie
                      Row(
                        children: [
                          Text(
                            'SKU: ${product.sku}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          if (product.category != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.textLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                product.category!.name,
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
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Badges de statut
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildStatusBadge(),
                          if (product.isLowStock) _buildStockWarning(),
                          if (product.isOutOfStock) _buildOutOfStockBadge(),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Prix + Stock
                      Row(
                        children: [
                          Text(
                            product.priceFormatted,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.textLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 11,
                            color: product.isOutOfStock
                                ? AppColors.error
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${product.stock}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: product.isOutOfStock
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // IMAGE
  // ============================================

  Widget _buildImage() {
    final imageUrl = product.heroImage;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.warning,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const Icon(
      Icons.image_outlined,
      size: 30,
      color: AppColors.textTertiary,
    );
  }

  // ============================================
  // MENU D'ACTIONS
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
      itemBuilder: (menuContext) => [
        // Éditer
        if (onEdit != null)
          _buildMenuItem(
            value: 'edit',
            icon: Icons.edit_outlined,
            label: 'Modifier',
          ),

        // Publier / Dépublier
        if (product.isDraft && onPublish != null)
          _buildMenuItem(
            value: 'publish',
            icon: Icons.publish_rounded,
            label: 'Publier',
            color: AppColors.success,
          ),
        if (product.isPublished && onUnpublish != null)
          _buildMenuItem(
            value: 'unpublish',
            icon: Icons.unpublished_rounded,
            label: 'Dépublier',
            color: AppColors.warning,
          ),

        // Dupliquer
        if (onDuplicate != null)
          _buildMenuItem(
            value: 'duplicate',
            icon: Icons.copy_all_rounded,
            label: 'Dupliquer',
          ),

        // Supprimer (uniquement si pas encore vendu)
        if (onDelete != null && product.canBeDeleted)
          _buildMenuItem(
            value: 'delete',
            icon: Icons.delete_outline_rounded,
            label: 'Archiver',
            color: AppColors.error,
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'publish':
            onPublish?.call();
            break;
          case 'unpublish':
            onUnpublish?.call();
            break;
          case 'duplicate':
            onDuplicate?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
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
      height: 42,
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

  // ============================================
  // BADGES
  // ============================================

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    if (product.isArchived) {
      bgColor = AppColors.statusInactiveBg;
      textColor = AppColors.statusInactiveText;
      label = 'Archivé';
      icon = Icons.archive_outlined;
    } else if (product.isPublished) {
      bgColor = AppColors.statusDeliveredBg;
      textColor = AppColors.statusDeliveredText;
      label = 'Publié';
      icon = Icons.check_circle_outline_rounded;
    } else {
      bgColor = AppColors.statusPendingBg;
      textColor = AppColors.statusPendingText;
      label = 'Brouillon';
      icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 10,
            color: AppColors.warningDark,
          ),
          const SizedBox(width: 3),
          Text(
            'Stock faible',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.warningDark,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 10,
            color: AppColors.errorDark,
          ),
          const SizedBox(width: 3),
          Text(
            'Rupture',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.errorDark,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}