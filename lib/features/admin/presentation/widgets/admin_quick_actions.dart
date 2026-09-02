// ============================================
// WIDGET : AdminSalesChart
// ============================================
// Graphique de ventes réutilisable pour le dashboard admin.
// Design moderne avec barres animées et tooltips.
//
// Structure :
// - En-tête avec titre et période
// - Graphique à barres
// - Légende
// ============================================

// ============================================
// IMPORTS
// ============================================

// Dart
import 'dart:math' as math;

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Graphique de ventes à barres.
///
/// Affiche :
/// - Les barres de revenus par période
/// - Les valeurs au survol (tap)
/// - La légende
/// - Le total de la période
class AdminSalesChart extends StatefulWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Données du graphique
  /// Format : [{'label': 'Lun', 'value': 150000}, ...]
  final List<Map<String, dynamic>> data;

  /// Titre du graphique
  final String title;

  /// Période affichée
  final String? periodLabel;

  /// Couleur des barres
  final Color barColor;

  /// Hauteur du graphique
  final double height;

  /// Vrai si le graphique doit s'animer au chargement
  final bool animate;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminSalesChart({
    super.key,
    required this.data,
    this.title = 'Ventes',
    this.periodLabel,
    this.barColor = AppColors.primary,
    this.height = 220,
    this.animate = true,
  });

  @override
  State<AdminSalesChart> createState() => _AdminSalesChartState();
}

// ============================================
// STATE
// ============================================

class _AdminSalesChartState extends State<AdminSalesChart>
    with SingleTickerProviderStateMixin {
  // ============================================
  // ANIMATION
  // ============================================

  late final AnimationController _controller;
  late final Animation<double> _animation;

  // ============================================
  // ÉTAT
  // ============================================

  int? _selectedIndex;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // GETTERS
  // ============================================

  /// Valeur maximale des données
  double get _maxValue {
    if (widget.data.isEmpty) return 1;
    return widget.data
        .map((d) => (d['value'] as num?)?.toDouble() ?? 0)
        .fold(0.0, math.max);
  }

  /// Valeur totale
  double get _totalValue {
    return widget.data.fold(0.0, (sum, d) => sum + ((d['value'] as num?)?.toDouble() ?? 0));
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // EN-TÊTE
          // ============================================
          _buildHeader(),

          const SizedBox(height: 20),

          // ============================================
          // GRAPHIQUE
          // ============================================
          SizedBox(
            height: widget.height,
            child: widget.data.isEmpty
                ? _buildEmptyState()
                : _buildChart(),
          ),

          const SizedBox(height: 12),

          // ============================================
          // LÉGENDE
          // ============================================
          _buildLegend(),
        ],
      ),
    );
  }

  // ============================================
  // EN-TÊTE
  // ============================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (widget.periodLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.periodLabel!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // GRAPHIQUE
  // ============================================

  Widget _buildChart() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final value = (item['value'] as num?)?.toDouble() ?? 0;
            final label = item['label'] as String? ?? '';
            final isSelected = _selectedIndex == index;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildBar(
                  value: value,
                  label: label,
                  index: index,
                  isSelected: isSelected,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Construit une barre.
  Widget _buildBar({
    required double value,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final barHeight = _maxValue > 0 ? (value / _maxValue) * (widget.height - 40) : 0.0;
    final animatedHeight = barHeight * _animation.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ============================================
          // VALEUR AU-DESSUS (si sélectionnée)
          // ============================================
          if (isSelected) ...[
            _buildValueTooltip(value),
            const SizedBox(height: 4),
          ],

          // ============================================
          // BARRE
          // ============================================
          Container(
            height: math.max(animatedHeight, 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : widget.barColor,
              borderRadius: BorderRadius.circular(4),
              gradient: isSelected
                  ? AppColors.accentGradient
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),

          const SizedBox(height: 6),

          // ============================================
          // LABEL
          // ============================================
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Tooltip de valeur.
  Widget _buildValueTooltip(double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _formatValue(value),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // ÉTAT VIDE
  // ============================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: AppColors.textLight,
          ),
          SizedBox(height: 12),
          Text(
            'Aucune donnée disponible',
            style: TextStyle(
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

  // ============================================
  // LÉGENDE
  // ============================================

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indicateur de couleur
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Revenus',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        // Total
        Text(
          'Total: ${_formatValue(_totalValue)}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Formate une valeur en FCFA compact.
  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M FCFA';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k FCFA';
    }
    return '${value.toStringAsFixed(0)} FCFA';
  }
}