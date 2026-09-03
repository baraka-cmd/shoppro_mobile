// ============================================
// WIDGET DE SECTION DE PROFIL - VERSION PREMIUM
// ============================================
// Affiche un titre de section avec icône
// optionnelle. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final String? trailingText;

  const ProfileSection({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (trailingText != null)
              Text(
                trailingText!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}