// ============================================
// WIDGET : AdminStatCard
// ============================================
// Carte statistique du dashboard admin.
// Design moderne avec icône dans un cercle coloré.
//
// Structure :
// - Icône dans un cercle en haut à droite
// - Valeur principale en grand
// - Label descriptif
// - Variation (hausse/baisse) en bas
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Carte statistique du tableau de bord.
///
/// Affiche :
/// - Une icône dans un cercle coloré
/// - La valeur principale en grand
/// - Le label descriptif
/// - La variation avec flèche (hausse/baisse)
class AdminStatCard extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Libellé de la statistique (ex: "Revenu Total")
  final String label;

  /// Valeur à afficher (ex: "12 500 000 FCFA")
  final String value;

  /// Icône à afficher
  final IconData icon;

  /// Couleur du cercle d'icône
  final Color iconBackgroundColor;

  /// Couleur de l'icône
  final Color iconColor;

  /// Variation en pourcentage (ex: 15.2 pour +15.2%)
  final double? variation;

  /// Vrai si la variation est positive
  final bool isPositiveVariation;

  /// Texte de la variation (ex: "vs hier")
  final String? variationLabel;

  /// Callback quand on clique sur la carte
  final VoidCallback? onTap;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFFEF3C7),
    this.iconColor = AppColors.warning,
    this.variation,
    this.isPositiveVariation = true,
    this.variationLabel,
    this.onTap,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // ICÔNE ET VARIATION
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cercle d'icône
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  // Badge de variation
                  if (variation != null) _buildVariationBadge(),
                ],
              ),

              const SizedBox(height: 16),

              // ============================================
              // VALEUR PRINCIPALE
              // ============================================
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // ============================================
              // LABEL
              // ============================================
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // ============================================
              // VARIATION EN BAS (si pas en haut)
              // ============================================
              if (variation != null && variationLabel != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isPositiveVariation
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 12,
                      color: isPositiveVariation
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${isPositiveVariation ? '+' : ''}${variation!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositiveVariation
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        variationLabel ?? '',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit le badge de variation en haut à droite.
  Widget _buildVariationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositiveVariation
            ? AppColors.successLight
            : AppColors.errorLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            isPositiveVariation ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositiveVariation ? AppColors.successDark : AppColors.errorDark,
          ),
          const SizedBox(width: 2),
          Text(
            '${variation!.toStringAsFixed(1)}%',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPositiveVariation ? AppColors.successDark : AppColors.errorDark,
            ),
          ),
        ],
      ),
    );
  }
}