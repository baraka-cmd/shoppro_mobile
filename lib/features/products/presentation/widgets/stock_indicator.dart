// Indicateur de stock
// Affiche l'état du stock avec couleur, icône et barre de progression

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StockIndicator extends StatelessWidget {
  final int currentStock;
  final int minStock;
  final int? maxStock;
  final StockIndicatorStyle style;
  final bool showLabel;
  final bool showProgress;

  const StockIndicator({
    super.key,
    required this.currentStock,
    this.minStock = 5,
    this.maxStock,
    this.style = StockIndicatorStyle.dot,
    this.showLabel = true,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final stockState = _getStockState();

    switch (style) {
      case StockIndicatorStyle.dot:
        return _buildDotStyle(stockState);
      case StockIndicatorStyle.badge:
        return _buildBadgeStyle(stockState);
      case StockIndicatorStyle.progress:
        return _buildProgressStyle(stockState);
    }
  }

  // Style : Point + label
  Widget _buildDotStyle(StockState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: state.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: state.color.withValues(alpha: 0.3),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 5),
          Text(
            state.label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: state.color,
            ),
          ),
        ],
      ],
    );
  }

  // Style : Badge
  Widget _buildBadgeStyle(StockState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: state.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.icon,
            size: 12,
            color: state.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              state.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: state.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Style : Barre de progression
  Widget _buildProgressStyle(StockState state) {
    final progress = _calculateProgress();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(state.icon, size: 12, color: state.color),
              const SizedBox(width: 4),
              Text(
                '${state.label} : $currentStock',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: state.color,
                ),
              ),
            ],
          ),
        if (showProgress) ...[
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: state.color.withValues(alpha: 0.1),
              color: state.color,
            ),
          ),
        ],
      ],
    );
  }

  // Calculer la progression du stock
  double _calculateProgress() {
    if (maxStock == null || maxStock! <= 0) {
      return 1.0;
    }
    return (currentStock / maxStock!).clamp(0.0, 1.0);
  }

  // Déterminer l'état du stock
  StockState _getStockState() {
    if (currentStock <= 0) {
      return StockState(
        label: 'Rupture de stock',
        color: AppColors.error,
        icon: Icons.cancel,
      );
    }

    if (currentStock <= minStock) {
      return StockState(
        label: 'Stock faible',
        color: AppColors.warning,
        icon: Icons.warning,
      );
    }

    return StockState(
      label: 'En stock',
      color: AppColors.success,
      icon: Icons.check_circle,
    );
  }
}

// État du stock
class StockState {
  final String label;
  final Color color;
  final IconData icon;

  const StockState({
    required this.label,
    required this.color,
    required this.icon,
  });
}

// Style de l'indicateur
enum StockIndicatorStyle {
  dot,       // Point coloré
  badge,     // Badge avec icône
  progress,  // Barre de progression
}