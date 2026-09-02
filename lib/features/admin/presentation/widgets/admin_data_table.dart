// ============================================
// WIDGET : AdminDataTable
// ============================================
// Tableau de données générique du backoffice admin.
// Design moderne avec en-têtes gris clair et lignes séparées.
//
// Structure :
// - En-tête avec titres de colonnes
// - Lignes de données avec hover
// - Colonne d'actions optionnelle
// - État vide intégré
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// MODÈLE DE COLONNE
// ============================================

/// Définition d'une colonne du tableau
class AdminTableColumn {
  final String label;
  final double? width;
  final TextAlign alignment;
  final bool sortable;

  const AdminTableColumn({
    required this.label,
    this.width,
    this.alignment = TextAlign.left,
    this.sortable = false,
  });
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Tableau de données générique pour l'administration.
///
/// Affiche :
/// - En-têtes de colonnes
/// - Lignes de données
/// - Actions par ligne
/// - État vide
/// - Loading state
class AdminDataTable extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Colonnes du tableau
  final List<AdminTableColumn> columns;

  /// Données à afficher (chaque ligne est une liste de widgets)
  final List<List<Widget>> rows;

  /// Actions par ligne (optionnel - alignées à droite)
  final List<Widget>? actions;

  /// Vrai si le tableau est en chargement
  final bool isLoading;

  /// Message d'état vide
  final String emptyMessage;

  /// Callback pour trier une colonne
  final void Function(int columnIndex)? onSort;

  /// Index de la colonne triée
  final int? sortColumnIndex;

  /// Direction du tri (true = asc)
  final bool? sortAscending;

  /// Callback quand on clique sur une ligne
  final void Function(int rowIndex)? onRowTap;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.actions,
    this.isLoading = false,
    this.emptyMessage = 'Aucune donnée disponible',
    this.onSort,
    this.sortColumnIndex,
    this.sortAscending,
    this.onRowTap,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // ============================================
          // EN-TÊTE
          // ============================================
          _buildHeader(),

          // Séparateur
          Container(
            height: 1,
            color: AppColors.borderColor,
          ),

          // ============================================
          // CORPS DU TABLEAU
          // ============================================
          if (isLoading)
            _buildLoadingState()
          else if (rows.isEmpty)
            _buildEmptyState()
          else
            _buildRows(),
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit l'en-tête du tableau.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Colonnes
          ...columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            return _buildHeaderCell(column, index);
          }),
          // Colonne actions
          if (actions != null)
            Container(
              width: 80,
              alignment: Alignment.centerRight,
              child: const Text(
                'Actions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construit une cellule d'en-tête.
  Widget _buildHeaderCell(AdminTableColumn column, int index) {
    final isSorted = sortColumnIndex == index;

    return Expanded(
      flex: column.width != null ? 0 : 1,
      child: column.width != null
          ? SizedBox(
              width: column.width,
              child: _buildHeaderContent(column, isSorted, index),
            )
          : _buildHeaderContent(column, isSorted, index),
    );
  }

  /// Construit le contenu d'une cellule d'en-tête.
  Widget _buildHeaderContent(AdminTableColumn column, bool isSorted, int index) {
    return InkWell(
      onTap: column.sortable ? () => onSort?.call(index) : null,
      child: Row(
        mainAxisAlignment: column.alignment == TextAlign.right
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Text(
            column.label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isSorted ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
          if (column.sortable) ...[
            const SizedBox(width: 4),
            Icon(
              isSorted
                  ? (sortAscending ?? true
                      ? Icons.arrow_upward
                      : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 14,
              color: isSorted ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ],
      ),
    );
  }

  /// Construit les lignes de données.
  Widget _buildRows() {
    return Column(
      children: rows.asMap().entries.map((entry) {
        final rowIndex = entry.key;
        final row = entry.value;
        return _buildRow(row, rowIndex);
      }).toList(),
    );
  }

  /// Construit une ligne de données.
  Widget _buildRow(List<Widget> cells, int rowIndex) {
    return InkWell(
      onTap: onRowTap != null ? () => onRowTap!(rowIndex) : null,
      hoverColor: AppColors.surfaceHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderColor.withOpacity(0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            // Cellules
            ...cells.asMap().entries.map((cellEntry) {
              final cellIndex = cellEntry.key;
              final cell = cellEntry.value;
              final column = columns[cellIndex];
              return Expanded(
                flex: column.width != null ? 0 : 1,
                child: column.width != null
                    ? SizedBox(
                        width: column.width,
                        child: cell,
                      )
                    : cell,
              );
            }),
            // Actions
            if (actions != null)
              Container(
                width: 80,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construit l'état de chargement.
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Construit l'état vide.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 28,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}