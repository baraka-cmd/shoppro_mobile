// Widget d'état vide
// Affiche un message quand il n'y a pas de données

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onAction;
  final String? actionLabel;
  final EmptyStateStyle style;

  const EmptyState({
    super.key,
    this.title = 'Aucun résultat',
    this.message,
    this.icon = Icons.inbox_outlined,
    this.iconColor = AppColors.textLight,
    this.iconBackgroundColor,
    this.onAction,
    this.actionLabel = 'Rafraîchir',
    this.style = EmptyStateStyle.full,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case EmptyStateStyle.full:
        return _buildFullStyle();
      case EmptyStateStyle.compact:
        return _buildCompactStyle();
      case EmptyStateStyle.minimal:
        return _buildMinimalStyle();
    }
  }

  // Style plein : Icône + titre + message + action
  Widget _buildFullStyle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBackgroundColor ??
                    (iconColor ?? AppColors.textLight).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 20),

            // Titre
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],

            if (onAction != null) ...[
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Style compact : Icône + message en ligne
  Widget _buildCompactStyle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.textLight).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 25,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    message!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Style minimal : Juste le texte
  Widget _buildMinimalStyle() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 10),
          Text(
            title!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 3),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Style de l'état vide
enum EmptyStateStyle {
  full,      // Icône + titre + message + action
  compact,   // Icône + message en ligne
  minimal,   // Juste le texte
}