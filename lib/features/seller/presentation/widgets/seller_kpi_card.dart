// ============================================
// WIDGET : SellerKpiCard
// ============================================
// Carte KPI réutilisable pour le dashboard vendeur.
//
// Design :
//   - Icône colorée avec fond pastel
//   - Valeur principale (gros chiffre)
//   - Label (petit texte)
//   - Indicateur de tendance (optionnel : +12%, -5%)
//   - Badge (optionnel : "Ce mois", "Total")
//
// Responsive :
//   - S'adapte à la largeur fournie par le parent
//   - Aucun overflow grâce à maxLines + ellipsis
//
// Couleurs :
//   - Utilise AppColors selon la sémantique (success, warning, error...)
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerKpiCard extends StatelessWidget {
  /// Icône affichée en haut à gauche.
  final IconData icon;

  /// Couleur de l'icône + fond pastel.
  final Color color;

  /// Valeur principale (ex: "1 250 000", "45", "4.5/5").
  final String value;

  /// Label sous la valeur (ex: "Revenus", "Commandes").
  final String label;

  /// Texte additionnel affiché sous le label (ex: "Ce mois", "Total").
  final String? subtitle;

  /// Tendance (ex: "+12,5%", "-5,2%").
  final String? trend;

  /// La tendance est-elle positive (vert) ou négative (rouge) ?
  final bool? isTrendPositive;

  /// Callback de tap (optionnel).
  final VoidCallback? onTap;

  /// Icône de tendance (flèche haut/bas). Auto si null.
  final IconData? trendIcon;

  /// Hauteur minimale de la carte.
  final double minHeight;

  const SellerKpiCard({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.subtitle,
    this.trend,
    this.isTrendPositive,
    this.onTap,
    this.trendIcon,
    this.minHeight = 108,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================================
              // LIGNE 1 : Icône + Tendance
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIcon(),
                  if (trend != null) _buildTrend(),
                ],
              ),

              const SizedBox(height: 12),

              // ============================================
              // LIGNE 2 : Valeur
              // ============================================
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 4),

              // ============================================
              // LIGNE 3 : Label + Subtitle
              // ============================================
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE
  // ============================================

  Widget _buildIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }

  // ============================================
  // TENDANCE
  // ============================================

  Widget _buildTrend() {
    final positive = isTrendPositive ?? _inferPositive(trend!);
    final trendColor = positive ? AppColors.success : AppColors.error;
    final trendBg = positive
        ? AppColors.successLight
        : AppColors.errorLight;

    final icon = trendIcon ??
        (positive
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: trendBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: trendColor),
          const SizedBox(width: 2),
          Text(
            trend!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Infère si la tendance est positive à partir de la chaîne.
  bool _inferPositive(String trend) {
    return !trend.contains('-');
  }
}

// ============================================
// VARIANTE : SellerKpiCardGrid
// ============================================
// Affiche un GridView de SellerKpiCard en 2x2.
// ============================================

class SellerKpiCardGrid extends StatelessWidget {
  final List<SellerKpiCard> cards;
  final EdgeInsets padding;

  const SellerKpiCardGrid({
    super.key,
    required this.cards,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: cards,
      ),
    );
  }
}