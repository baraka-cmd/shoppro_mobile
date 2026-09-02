// ============================================
// WIDGET : PasswordStrengthIndicator
// ============================================
// Indicateur de force du mot de passe avec :
// - Analyse complète (longueur, majuscules, chiffres, symboles)
// - Barres de force animées
// - Libellé clair (Faible, Moyen, Fort, Très fort)
// - Conseils d'amélioration
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class PasswordStrengthIndicator extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Mot de passe à analyser
  final String password;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  // ============================================
  // ANALYSE DE FORCE
  // ============================================

  /// Calcule le score de force (0-4)
  int _calculateScore(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // 1. Longueur >= 8 caractères
    if (password.length >= 8) score++;

    // 2. Longueur >= 12 caractères
    if (password.length >= 12) score++;

    // 3. Contient une majuscule
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // 4. Contient un chiffre
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // 5. Contient un symbole spécial
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Limiter à 4
    return score > 4 ? 4 : score;
  }

  /// Retourne le libellé de force
  String _getStrengthLabel(int score) {
    switch (score) {
      case 0:
        return '';
      case 1:
        return 'Faible';
      case 2:
        return 'Moyen';
      case 3:
        return 'Fort';
      case 4:
        return 'Très fort';
      default:
        return '';
    }
  }

  /// Retourne la couleur de force
  Color _getStrengthColor(int score) {
    switch (score) {
      case 0:
        return AppColors.textLight;
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.success;
      case 4:
        return AppColors.success;
      default:
        return AppColors.textLight;
    }
  }

  /// Retourne le conseil d'amélioration
  String _getSuggestion(int score, String password) {
    if (password.isEmpty) return '';

    if (score < 2) {
      return 'Ajoutez au moins 8 caractères, une majuscule et un chiffre.';
    }
    if (score == 2) {
      return 'Ajoutez un symbole spécial pour renforcer.';
    }
    if (score == 3) {
      return 'Excellent ! Encore quelques caractères pour un mot de passe parfait.';
    }
    return 'Mot de passe très sécurisé !';
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore(password);
    final strengthLabel = _getStrengthLabel(score);
    final strengthColor = _getStrengthColor(score);
    final suggestion = _getSuggestion(score, password);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: strengthColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: strengthColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // LIGNE 1 : Libellé de force
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Force du mot de passe',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (strengthLabel.isNotEmpty)
                Text(
                  strengthLabel,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: strengthColor,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================
          // LIGNE 2 : Barres de force (4 barres)
          // ============================================
          Row(
            children: List.generate(4, (index) {
              final isActive = index < score;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isActive ? strengthColor : AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),

          // ============================================
          // LIGNE 3 : Conseil (si mot de passe non vide)
          // ============================================
          if (suggestion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  score >= 3 ? Icons.check_circle_outline : Icons.info_outline,
                  size: 12,
                  color: strengthColor,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: strengthColor.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}