// ============================================
// SECTION DES ARTICLES SAUVEGARDÉS - PREMIUM
// ============================================
// Affiche les articles mis de côté avec option
// de réactivation et suppression. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_item_widget.dart';

class SavedForLaterSection extends StatelessWidget {
  final List<CartItem> savedItems;
  final VoidCallback? onMoveToCart;
  final VoidCallback? onRemove;
  final VoidCallback? onClearAll;

  const SavedForLaterSection({
    super.key,
    required this.savedItems,
    this.onMoveToCart,
    this.onRemove,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (savedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // EN-TÊTE
        // ============================================
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SAUVEGARDÉS POUR PLUS TARD',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (onClearAll != null)
                GestureDetector(
                  onTap: onClearAll,
                  child: const Text(
                    'Tout effacer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ============================================
        // LISTE DES ARTICLES SAUVEGARDÉS
        // ============================================
        ...savedItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: CartItemWidget(
              item: item,
              onIncrement: null,
              onDecrement: null,
              onRemove: onRemove,
              onMoveToCart: onMoveToCart,
              onTap: null,
            ),
          );
        }),

        // ============================================
        // BOUTON TOUT DÉPLACER
        // ============================================
        if (savedItems.length > 1 && onMoveToCart != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onMoveToCart,
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 16,
                ),
                label: Text(
                  'TOUT DÉPLACER VERS LE PANIER (${savedItems.length})',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}