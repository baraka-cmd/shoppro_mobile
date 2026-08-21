// Widget d'état d'erreur
// Affiche un message d'erreur avec bouton de réessai

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ErrorState extends StatelessWidget {
  final String? message;
  final String title;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final ErrorStateStyle style;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ErrorState({
    super.key,
    this.message,
    this.title = 'Une erreur est survenue',
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryLabel = 'RÉESSAYER',
    this.style = ErrorStateStyle.full,
    this.iconColor = AppColors.error,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ErrorStateStyle.full:
        return _buildFullStyle();
      case ErrorStateStyle.compact:
        return _buildCompactStyle();
      case ErrorStateStyle.inline:
        return _buildInlineStyle();
    }
  }

  // Style plein : Icône + titre + message + bouton
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
                    (iconColor ?? AppColors.error).withValues(alpha: 0.1),
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
              title,
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

            if (onRetry != null) ...[
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      retryLabel,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Style compact : Icône + message + bouton sur une ligne
  Widget _buildCompactStyle() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.error).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (iconColor ?? AppColors.error).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: iconColor ?? AppColors.textPrimary,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: iconColor,
              ),
              child: Text(
                retryLabel,
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

  // Style inline : Juste un message avec un bouton
  Widget _buildInlineStyle() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                retryLabel,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Style de l'état d'erreur
enum ErrorStateStyle {
  full,      // Icône + titre + message + bouton
  compact,   // Icône + message + bouton sur une ligne
  inline,    // Juste message + bouton
}