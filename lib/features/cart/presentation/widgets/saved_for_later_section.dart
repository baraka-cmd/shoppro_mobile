// Section des articles sauvegardés pour plus tard
// Affiche les articles mis de côté avec option de réactivation

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
        // Titre + Effacer tout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SAUVEGARDÉS POUR PLUS TARD',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
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

        const SizedBox(height: 12),

        // Liste des articles sauvegardés
        ...savedItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: CartItemWidget(
              item: item,
              onIncrement: null, // Pas d'incrément pour sauvegardés
              onDecrement: null, // Pas de décrément
              onRemove: onRemove,
              onMoveToCart: () => onMoveToCart?.call(),
              onTap: null,
            ),
          );
        }),
      ],
    );
  }
}