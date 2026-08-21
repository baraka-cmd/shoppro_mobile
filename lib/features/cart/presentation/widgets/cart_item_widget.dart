// Widget d'élément du panier
// Affiche l'article avec image, quantité et actions

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final VoidCallback? onSaveForLater;
  final VoidCallback? onMoveToCart;
  final VoidCallback? onTap;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.onSaveForLater,
    this.onMoveToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildImage(),
              ),
            ),

            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom
                  Text(
                    item.fullName,
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

                  // Prix unitaire
                  const SizedBox(height: 3),
                  Text(
                    'Prix unitaire : ${item.formattedPrice}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  // Alerte stock faible
                  if (item.isLowStock) ...[
                    const SizedBox(height: 3),
                    Text(
                      '⚠️ Plus que ${item.stock} en stock',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Quantité + sous-total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sélecteur de quantité
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bouton -
                            _buildQtyButton(
                              icon: Icons.remove,
                              onTap: item.canDecrement ? onDecrement : null,
                              isActive: item.canDecrement,
                            ),
                            // Quantité
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            // Bouton +
                            _buildQtyButton(
                              icon: Icons.add,
                              onTap: item.canIncrement ? onIncrement : null,
                              isActive: item.canIncrement,
                            ),
                          ],
                        ),
                      ),

                      // ✅ NOUVEAU
                      Flexible(
                        child: Text(
                          item.formattedSubtotal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,  // ✅ RÉDUIRE
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actions
            Column(
              children: [
                // Supprimer
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Sauvegarder pour plus tard / Déplacer
                if (onSaveForLater != null)
                  GestureDetector(
                    onTap: onSaveForLater,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                if (onMoveToCart != null)
                  GestureDetector(
                    onTap: onMoveToCart,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Construire l'image
  Widget _buildImage() {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Icon(
          Icons.image,
          size: 30,
          color: AppColors.textLight,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.background,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.background,
        child: const Icon(
          Icons.broken_image,
          size: 30,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  // Bouton quantité
  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Icon(
          icon,
          size: 14,
          color: isActive ? AppColors.primary : AppColors.textLight,
        ),
      ),
    );
  }
}