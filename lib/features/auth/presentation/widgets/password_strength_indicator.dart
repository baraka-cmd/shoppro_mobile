// Widget d'indicateur de force du mot de passe
// Affiche des barres colorées, un pourcentage et des conseils

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  // Calculer le score de force (0 à 100)
  int get _score {
    if (password.isEmpty) return 0;

    int score = 0;

    // Longueur
    if (password.length >= 8) score += 25;
    if (password.length >= 12) score += 10;

    // Lettres minuscules et majuscules
    if (password.contains(RegExp(r'[a-z]'))) score += 15;
    if (password.contains(RegExp(r'[A-Z]'))) score += 15;

    // Chiffres
    if (password.contains(RegExp(r'[0-9]'))) score += 15;

    // Caractères spéciaux
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 20;

    return score.clamp(0, 100);
  }

  // Récupérer le label selon le score
  String get _label {
    if (password.isEmpty) return '';
    if (_score < 40) return 'Faible';
    if (_score < 70) return 'Moyen';
    if (_score < 90) return 'Fort';
    return 'Très fort';
  }

  // Récupérer la couleur selon le score
  Color get _color {
    if (_score < 40) return AppColors.error;
    if (_score < 70) return AppColors.warning;
    if (_score < 90) return AppColors.info;
    return AppColors.success;
  }

  // Récupérer les conseils selon le mot de passe
  List<String> get _suggestions {
    final suggestions = <String>[];

    if (password.length < 8) {
      suggestions.add('Au moins 8 caractères');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Une lettre minuscule');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Une lettre majuscule');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Un chiffre');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      suggestions.add('Un caractère spécial');
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barres de progression + label
          Row(
            children: [
              // 4 barres de progression
              Expanded(
                child: Row(
                  children: List.generate(4, (index) {
                    final isActive = _getActiveBars(index);
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? _color
                              : AppColors.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              // Label
              Text(
                _label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              ),
            ],
          ),

          // Score en pourcentage
          const SizedBox(height: 8),
          Text(
            'Sécurité : $_score%',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          // Conseils si le mot de passe n'est pas parfait
          if (_suggestions.isNotEmpty && _score < 90) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text(
              'Pour renforcer votre mot de passe :',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            ..._suggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_right,
                      size: 14,
                      color: _color.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      suggestion,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_score >= 90) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Mot de passe très sécurisé !',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Déterminer quelles barres sont actives
  bool _getActiveBars(int index) {
    final activeBars = (_score / 25).ceil();
    return index < activeBars;
  }
}