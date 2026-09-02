// ============================================
// WIDGET : AdminPagination
// ============================================
// Composant de pagination réutilisable pour les tableaux admin.
// Design moderne avec numéros de pages et navigation.
//
// Structure :
// - Bouton précédent
// - Numéros de pages (avec ellipsis)
// - Bouton suivant
// - Informations (Page X sur Y - Total Z)
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

/// Pagination générique pour les listes et tableaux admin.
///
/// Affiche :
/// - Les numéros de pages avec ellipsis intelligents
/// - Les boutons précédent/suivant
/// - Les informations de pagination
class AdminPagination extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Page actuelle (commence à 1)
  final int currentPage;

  /// Nombre total de pages
  final int totalPages;

  /// Nombre total d'éléments
  final int totalItems;

  /// Nombre d'éléments par page
  final int perPage;

  /// Callback quand on change de page
  final ValueChanged<int> onPageChanged;

  /// Nombre maximum de pages visibles avant ellipsis
  final int maxVisiblePages;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.perPage = 20,
    required this.onPageChanged,
    this.maxVisiblePages = 5,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // ============================================
          // INFORMATIONS
          // ============================================
          Expanded(
            child: Text(
              _buildInfoText(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ),

          // ============================================
          // BOUTON PRÉCÉDENT
          // ============================================
          _buildNavButton(
            icon: Icons.chevron_left,
            onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            tooltip: 'Page précédente',
          ),

          const SizedBox(width: 4),

          // ============================================
          // NUMÉROS DE PAGES
          // ============================================
          ..._buildPageNumbers(),

          const SizedBox(width: 4),

          // ============================================
          // BOUTON SUIVANT
          // ============================================
          _buildNavButton(
            icon: Icons.chevron_right,
            onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            tooltip: 'Page suivante',
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit le texte d'information.
  String _buildInfoText() {
    final start = ((currentPage - 1) * perPage) + 1;
    final end = (currentPage * perPage) > totalItems ? totalItems : (currentPage * perPage);

    if (totalItems == 0) {
      return 'Aucun élément';
    }

    return '$start - $end sur $totalItems';
  }

  /// Construit un bouton de navigation.
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: onTap != null ? AppColors.surfaceAlt : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: onTap != null ? AppColors.borderColor : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: onTap != null ? AppColors.textSecondary : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit les numéros de pages avec ellipsis.
  List<Widget> _buildPageNumbers() {
    final pages = _getVisiblePages();
    final widgets = <Widget>[];

    for (int i = 0; i < pages.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(width: 4));
      }

      if (pages[i] == -1) {
        // Ellipsis
        widgets.add(
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Text(
              '...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        );
      } else {
        widgets.add(_buildPageButton(pages[i]));
      }
    }

    return widgets;
  }

  /// Construit un bouton de page.
  Widget _buildPageButton(int page) {
    final isCurrent = page == currentPage;

    return Material(
      color: isCurrent ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isCurrent ? null : () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent ? AppColors.primary : AppColors.borderColor,
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Calcule les pages visibles avec ellipsis.
  ///
  /// Retourne une liste où -1 représente une ellipsis.
  List<int> _getVisiblePages() {
    if (totalPages <= maxVisiblePages) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final pages = <int>[];
    final half = (maxVisiblePages / 2).floor();

    // Toujours afficher la première page
    pages.add(1);

    // Calculer le début et la fin
    var start = currentPage - half;
    var end = currentPage + half;

    if (start < 2) {
      start = 2;
      end = maxVisiblePages;
    }

    if (end > totalPages - 1) {
      end = totalPages - 1;
      start = totalPages - maxVisiblePages + 1;
    }

    // Ellipsis avant si nécessaire
    if (start > 2) {
      pages.add(-1);
    }

    // Pages intermédiaires
    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    // Ellipsis après si nécessaire
    if (end < totalPages - 1) {
      pages.add(-1);
    }

    // Toujours afficher la dernière page
    pages.add(totalPages);

    return pages;
  }
}