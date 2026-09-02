// Sections dynamiques
// Affiche une liste de sections configurables par l'admin

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'dynamic_section_item.dart';

class DynamicSections extends StatelessWidget {
  final List<DynamicSectionData> sections;
  final bool isLoading;
  final ValueChanged<DynamicSectionData>? onSectionTap;

  const DynamicSections({
    super.key,
    required this.sections,
    this.isLoading = false,
    this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'DÉCOUVRIR',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Liste des sections dynamiques
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DynamicSectionItem(
                    title: section.title,
                    subtitle: section.subtitle,
                    icon: section.icon,
                    color: section.color,
                    productsCount: section.productsCount,
                    badgeText: section.badgeText,
                    onTap: () => onSectionTap?.call(section),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// Données de section dynamique
class DynamicSectionData {
  final int id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final int productsCount;
  final String? badgeText;
  final String? route;

  const DynamicSectionData({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.productsCount = 0,
    this.badgeText,
    this.route,
  });
}