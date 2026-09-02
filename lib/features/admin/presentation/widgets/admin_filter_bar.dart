// ============================================
// WIDGET : AdminFilterBar
// ============================================
// Barre de filtres réutilisable pour les écrans admin.
// Design moderne avec chips de filtres et dropdowns.
//
// Structure :
// - Filtres sous forme de chips
// - Dropdowns pour les filtres à options
// - Bouton "Effacer" si des filtres sont actifs
// - Compteur de filtres actifs
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// MODÈLE DE FILTRE
// ============================================

/// Définition d'un filtre
class AdminFilterItem {
  /// Libellé du filtre
  final String label;

  /// Icône du filtre
  final IconData icon;

  /// Valeur actuelle (null = aucun filtre)
  final String? value;

  /// Options possibles (si dropdown)
  final List<AdminFilterOption>? options;

  /// Callback quand la valeur change
  final ValueChanged<String?> onChanged;

  const AdminFilterItem({
    required this.label,
    required this.icon,
    this.value,
    this.options,
    required this.onChanged,
  });
}

/// Option d'un filtre dropdown
class AdminFilterOption {
  /// Valeur de l'option
  final String value;

  /// Libellé affiché
  final String label;

  /// Icône optionnelle
  final IconData? icon;

  const AdminFilterOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Barre de filtres générique.
///
/// Affiche :
/// - Des chips de filtres simples (toggle)
/// - Des dropdowns pour les filtres à options
/// - Un bouton Effacer si des filtres sont actifs
class AdminFilterBar extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Liste des filtres
  final List<AdminFilterItem> filters;

  /// Callback pour effacer tous les filtres
  final VoidCallback? onClearAll;

  /// Vrai si au moins un filtre est actif
  final bool hasActiveFilters;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminFilterBar({
    super.key,
    required this.filters,
    this.onClearAll,
    this.hasActiveFilters = false,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // ============================================
          // ICÔNE FILTRE
          // ============================================
          const Icon(
            Icons.filter_list,
            size: 18,
            color: AppColors.textTertiary,
          ),

          const SizedBox(width: 10),

          // ============================================
          // FILTRES
          // ============================================
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < filters.length - 1 ? 8 : 0,
                    ),
                    child: _buildFilterItem(filter),
                  );
                }).toList(),
              ),
            ),
          ),

          // ============================================
          // BOUTON EFFACER (si filtres actifs)
          // ============================================
          if (hasActiveFilters && onClearAll != null) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.error,
              ),
              label: const Text(
                'Effacer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit un filtre individuel.
  Widget _buildFilterItem(AdminFilterItem filter) {
    // Si le filtre a des options → dropdown
    if (filter.options != null && filter.options!.isNotEmpty) {
      return _buildDropdownFilter(filter);
    }

    // Sinon → chip toggle
    return _buildChipFilter(filter);
  }

  /// Construit un filtre dropdown.
  Widget _buildDropdownFilter(AdminFilterItem filter) {
    final isActive = filter.value != null;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.borderColor,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter.value,
          isDense: true,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                filter.label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          items: [
            // Option "Tous"
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Tous',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: filter.value == null
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            // Options
            ...filter.options!.map((option) {
              return DropdownMenuItem<String>(
                value: option.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(option.icon, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      option.label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: filter.onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: isActive ? Colors.white : AppColors.textTertiary,
          ),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: isActive ? Colors.white : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  /// Construit un filtre chip (toggle).
  Widget _buildChipFilter(AdminFilterItem filter) {
    final isActive = filter.value != null && filter.value == 'active';

    return Material(
      color: isActive ? AppColors.primary : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          filter.onChanged(isActive ? null : 'active');
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: 14,
                color: isActive ? Colors.white : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                filter.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textTertiary,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}