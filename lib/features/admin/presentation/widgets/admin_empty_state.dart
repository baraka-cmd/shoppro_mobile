// ============================================
// WIDGET : AdminEmptyState
// ============================================
// État vide générique pour les pages admin.
// Design moderne avec icône, titre, message et action.
//
// Structure :
// - Icône dans un cercle décoratif
// - Titre principal
// - Message descriptif
// - Bouton d'action optionnel
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

/// État vide pour les listes et tableaux admin.
///
/// Affiche :
/// - Une icône décorative dans un cercle
/// - Un titre
/// - Un message descriptif
/// - Un bouton d'action optionnel
class AdminEmptyState extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Icône à afficher
  final IconData icon;

  /// Titre principal
  final String title;

  /// Message descriptif
  final String message;

  /// Label du bouton d'action
  final String? actionLabel;

  /// Callback du bouton d'action
  final VoidCallback? onAction;

  /// Couleur de fond du cercle d'icône
  final Color circleColor;

  /// Couleur de l'icône
  final Color iconColor;

  /// Taille de l'icône
  final double iconSize;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.circleColor = AppColors.surfaceAlt,
    this.iconColor = AppColors.textLight,
    this.iconSize = 32,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ============================================
          // CERCLE D'ICÔNE
          // ============================================
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: AppColors.softShadow,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 24),

          // ============================================
          // TITRE
          // ============================================
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // ============================================
          // MESSAGE
          // ============================================
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),

          // ============================================
          // BOUTON D'ACTION (optionnel)
          // ============================================
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            _buildActionButton(),
          ],
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit le bouton d'action.
  Widget _buildActionButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}