// ============================================
// WIDGET : AdminConfirmDialog
// ============================================
// Boîte de dialogue de confirmation générique.
// Design moderne avec icône, titre, message et actions.
//
// Structure :
// - Icône d'avertissement dans un cercle coloré
// - Titre de confirmation
// - Message descriptif
// - Boutons Annuler / Confirmer
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// ENUM DE TYPE DE DIALOGUE
// ============================================

/// Type de dialogue de confirmation
enum AdminDialogType {
  /// Confirmation standard (bleu)
  confirm,

  /// Avertissement (ambre)
  warning,

  /// Danger / Suppression (rouge)
  danger,

  /// Succès (vert)
  success,

  /// Information (bleu clair)
  info,
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Boîte de dialogue de confirmation.
///
/// Affiche :
/// - Une icône selon le type
/// - Un titre
/// - Un message
/// - Des boutons Annuler / Confirmer
class AdminConfirmDialog extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Titre du dialogue
  final String title;

  /// Message descriptif
  final String message;

  /// Type de dialogue
  final AdminDialogType type;

  /// Label du bouton de confirmation
  final String confirmLabel;

  /// Label du bouton d'annulation
  final String cancelLabel;

  /// Callback quand on confirme
  final VoidCallback? onConfirm;

  /// Callback quand on annule
  final VoidCallback? onCancel;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AdminDialogType.confirm,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.onConfirm,
    this.onCancel,
  });

  // ============================================
  // AFFICHAGE STATIQUE
  // ============================================

  /// Affiche le dialogue et retourne le résultat.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    AdminDialogType type = AdminDialogType.confirm,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AdminConfirmDialog(
          title: title,
          message: message,
          type: type,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          onCancel: () => Navigator.of(dialogContext).pop(false),
        );
      },
    );
  }

  // ============================================
  // GETTERS DE COULEURS SELON LE TYPE
  // ============================================

  Color get _iconColor {
    switch (type) {
      case AdminDialogType.confirm:
        return AppColors.primary;
      case AdminDialogType.warning:
        return AppColors.warning;
      case AdminDialogType.danger:
        return AppColors.error;
      case AdminDialogType.success:
        return AppColors.success;
      case AdminDialogType.info:
        return AppColors.info;
    }
  }

  Color get _iconBackgroundColor {
    switch (type) {
      case AdminDialogType.confirm:
        return AppColors.infoLight;
      case AdminDialogType.warning:
        return AppColors.warningLight;
      case AdminDialogType.danger:
        return AppColors.errorLight;
      case AdminDialogType.success:
        return AppColors.successLight;
      case AdminDialogType.info:
        return AppColors.infoLight;
    }
  }

  Color get _confirmButtonColor {
    switch (type) {
      case AdminDialogType.confirm:
        return AppColors.primary;
      case AdminDialogType.warning:
        return AppColors.warning;
      case AdminDialogType.danger:
        return AppColors.error;
      case AdminDialogType.success:
        return AppColors.success;
      case AdminDialogType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (type) {
      case AdminDialogType.confirm:
        return Icons.help_outline;
      case AdminDialogType.warning:
        return Icons.warning_amber_rounded;
      case AdminDialogType.danger:
        return Icons.delete_outline;
      case AdminDialogType.success:
        return Icons.check_circle_outline;
      case AdminDialogType.info:
        return Icons.info_outline;
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.mediumShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============================================
            // ICÔNE
            // ============================================
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 30,
                color: _iconColor,
              ),
            ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 24),

            // ============================================
            // BOUTONS
            // ============================================
            Row(
              children: [
                // Bouton Annuler
                Expanded(
                  child: _buildCancelButton(context),
                ),
                const SizedBox(width: 12),
                // Bouton Confirmer
                Expanded(
                  child: _buildConfirmButton(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit le bouton Annuler.
  Widget _buildCancelButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCancel ?? () => Navigator.of(context).pop(false),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderColorDark,
            ),
          ),
          child: Text(
            cancelLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit le bouton Confirmer.
  Widget _buildConfirmButton(BuildContext context) {
    return Material(
      color: _confirmButtonColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onConfirm ?? () => Navigator.of(context).pop(true),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            confirmLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}