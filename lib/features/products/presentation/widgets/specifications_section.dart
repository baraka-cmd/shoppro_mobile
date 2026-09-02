// ============================================
// SECTION DES SPÉCIFICATIONS TECHNIQUES - PREMIUM
// ============================================
// Affiche les caractéristiques du produit avec
// icônes, labels et valeurs. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SpecificationsSection extends StatelessWidget {
  final List<SpecificationItem> specifications;

  const SpecificationsSection({
    super.key,
    required this.specifications,
  });

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // TITRE
        // ============================================
        const Text(
          'SPÉCIFICATIONS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 12),

        // ============================================
        // TABLEAU DES SPÉCIFICATIONS
        // ============================================
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            children: specifications.asMap().entries.map((entry) {
              final index = entry.key;
              final spec = entry.value;
              final isLast = index == specifications.length - 1;

              return Column(
                children: [
                  // Ligne de spécification
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icône
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            spec.icon ?? Icons.info_outline,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Label
                        SizedBox(
                          width: 110,
                          child: Text(
                            spec.label,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Valeur
                        Expanded(
                          child: Text(
                            spec.value,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider sauf après le dernier
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderColor.withValues(alpha: 0.3),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ============================================
// ITEM DE SPÉCIFICATION
// ============================================

class SpecificationItem {
  final String label;
  final String value;
  final IconData? icon;

  const SpecificationItem({
    required this.label,
    required this.value,
    this.icon,
  });
}