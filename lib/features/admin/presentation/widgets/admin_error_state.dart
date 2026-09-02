// ============================================
// WIDGET : AdminErrorState
// ============================================
// État d'erreur générique pour les pages admin.
// Design moderne avec icône d'erreur, message et actions.
//
// Structure :
// - Icône d'erreur dans un cercle rouge pâle
// - Titre d'erreur
// - Message descriptif
// - Bouton de réessai
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

/// État d'erreur pour les pages admin.
///
/// Affiche :
/// - Une icône d'erreur
/// - Un titre d'erreur
/// - Un message descriptif
/// - Un bouton de réessai
class AdminErrorState extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Titre de l'erreur
  final String title;

  /// Message descriptif
  final String message;

  /// Label du bouton de réessai
  final String retryLabel;

  /// Callback pour réessayer
  final VoidCallback? onRetry;

  /// Icône à afficher
  final IconData icon;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminErrorState({
    super.key,
    this.title = 'Une erreur est survenue',
    required this.message,
    this.retryLabel = 'Réessayer',
    this.onRetry,
    this.icon = Icons.error_outline,
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
          // CERCLE D'ERREUR
          // ============================================
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
              boxShadow: AppColors.softShadow,
            ),
            child: Icon(
              icon,
              size: 36,
              color: AppColors.error,
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
          // BOUTON DE RÉESSAI (optionnel)
          // ============================================
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit le bouton de réessai.
  Widget _buildRetryButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.refresh,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                retryLabel,
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