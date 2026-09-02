// ============================================
// WIDGET D'ÉLÉMENT DU PANIER - VERSION PREMIUM
// ============================================
// Affiche l'article avec image, quantité animée,
// actions et alerte stock. Design ShopPro.
// ============================================

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
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
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
              // ============================================
              // IMAGE
              // ============================================
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildImage(),
                ),
              ),

              const SizedBox(width: 12),

              // ============================================
              // INFORMATIONS
              // ============================================
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

                    // Variantes
                    if (item.hasVariant) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.variantLabel,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],

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

                    // ============================================
                    // QUANTITÉ + SOUS-TOTAL
                    // ============================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sélecteur de quantité
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQtyButton(
                                icon: Icons.remove,
                                onTap: item.canDecrement ? onDecrement : null,
                                isActive: item.canDecrement,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  key: ValueKey<int>(item.quantity),
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
                              ),
                              _buildQtyButton(
                                icon: Icons.add,
                                onTap: item.canIncrement ? onIncrement : null,
                                isActive: item.canIncrement,
                              ),
                            ],
                          ),
                        ),

                        // Sous-total
                        Flexible(
                          child: Text(
                            item.formattedSubtotal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
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

              // ============================================
              // ACTIONS
              // ============================================
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

                  // Sauvegarder pour plus tard
                  if (onSaveForLater != null)
                    GestureDetector(
                      onTap: onSaveForLater,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                  // Déplacer vers le panier
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
      ),
    );
  }

  // ============================================
  // IMAGE
  // ============================================

  Widget _buildImage() {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.image_outlined,
          size: 30,
          color: AppColors.textLight,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surface,
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
        color: AppColors.surface,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 30,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  // ============================================
  // BOUTON QUANTITÉ
  // ============================================

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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