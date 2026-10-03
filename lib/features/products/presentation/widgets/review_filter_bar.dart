// ============================================
// BARRE DE FILTRES POUR LES AVIS - PREMIUM
// ============================================
// Widget réutilisable affichant des chips
// horizontales pour filtrer les avis :
// - Toutes les notes
// - Par note (5★, 4★, 3★, 2★, 1★)
// - Avec photos
// - Achats vérifiés
// - Avec compteur optionnel
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Modèle de filtre pour les avis
class ReviewFilter {
  final String id;
  final String label;
  final IconData? icon;
  final int? count;

  const ReviewFilter({
    required this.id,
    required this.label,
    this.icon,
    this.count,
  });
}

class ReviewFilterBar extends StatelessWidget {
  /// Liste des filtres à afficher
  final List<ReviewFilter> filters;

  /// ID du filtre actuellement sélectionné
  final String selectedFilterId;

  /// Callback quand un filtre est sélectionné
  final ValueChanged<String> onFilterSelected;

  /// Callback optionnel quand l'utilisateur veut tout réinitialiser
  final VoidCallback? onReset;

  /// Affiche le bouton "Réinitialiser" si au moins un filtre est actif
  final bool showResetButton;

  /// Padding horizontal
  final double horizontalPadding;

  /// Espacement entre les chips
  final double spacing;

  /// Couleur de sélection (par défaut : AppColors.primary)
  final Color? selectedColor;

  /// Hauteur de la barre
  final double height;

  const ReviewFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilterId,
    required this.onFilterSelected,
    this.onReset,
    this.showResetButton = false,
    this.horizontalPadding = 20,
    this.spacing = 8,
    this.selectedColor,
    this.height = 45,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    final activeColor = selectedColor ?? AppColors.primary;

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter.id == selectedFilterId;

          return _buildChip(
            filter: filter,
            isSelected: isSelected,
            activeColor: activeColor,
            onTap: () => onFilterSelected(filter.id),
          );
        },
      ),
    );
  }

  // ============================================
  // CHIP INDIVIDUELLE
  // ============================================

  Widget _buildChip({
    required ReviewFilter filter,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            if (filter.icon != null) ...[
              Icon(
                filter.icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],

            // Label
            Text(
              filter.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),

            // Compteur
            if (filter.count != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${filter.count}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// FACTORY : FILTRES STANDARD POUR AVIS
// ============================================

/// Construit une liste de filtres standards pour les avis
/// avec les compteurs calculés automatiquement
class ReviewFilterFactory {
  /// Crée les filtres standards :
  /// - Tous
  /// - 5★, 4★, 3★, 2★, 1★
  /// - Avec photos
  /// - Vérifiés
  static List<ReviewFilter> standard({
    required int totalCount,
    required Map<int, int> distribution,
    required int withPhotosCount,
    required int verifiedCount,
    String allLabel = 'Tous',
  }) {
    return [
      ReviewFilter(
        id: 'all',
        label: allLabel,
        count: totalCount,
      ),
      ...List.generate(5, (index) {
        final star = 5 - index;
        return ReviewFilter(
          id: 'rating_$star',
          label: '$star',
          icon: Icons.star,
          count: distribution[star] ?? 0,
        );
      }),
      ReviewFilter(
        id: 'with_photos',
        label: 'Photos',
        icon: Icons.photo_camera,
        count: withPhotosCount,
      ),
      ReviewFilter(
        id: 'verified',
        label: 'Vérifiés',
        icon: Icons.verified,
        count: verifiedCount,
      ),
    ];
  }

  /// Crée une version simplifiée sans compteurs
  static List<ReviewFilter> simple() {
    return const [
      ReviewFilter(id: 'all', label: 'Tous'),
      ReviewFilter(id: 'rating_5', label: '5', icon: Icons.star),
      ReviewFilter(id: 'rating_4', label: '4', icon: Icons.star),
      ReviewFilter(id: 'rating_3', label: '3', icon: Icons.star),
      ReviewFilter(id: 'rating_2', label: '2', icon: Icons.star),
      ReviewFilter(id: 'rating_1', label: '1', icon: Icons.star),
      ReviewFilter(
        id: 'with_photos',
        label: 'Photos',
        icon: Icons.photo_camera,
      ),
      ReviewFilter(
        id: 'verified',
        label: 'Vérifiés',
        icon: Icons.verified,
      ),
    ];
  }
}