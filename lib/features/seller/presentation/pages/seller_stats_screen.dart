// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// fl_chart
import 'package:fl_chart/fl_chart.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_stats.dart';

// Data (👈 NOUVEAU - pour SellerStatsExportResult)
import '../../data/sources/seller_stats_api.dart';

// Presentation
import '../providers/seller_stats_provider.dart';
import '../providers/seller_dashboard_provider.dart';
import '../widgets/seller_scaffold.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerStatsScreen extends StatefulWidget {
  const SellerStatsScreen({super.key});

  @override
  State<SellerStatsScreen> createState() => _SellerStatsScreenState();
}

class _SellerStatsScreenState extends State<SellerStatsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerStatsProvider>();
      if (provider.status == SellerStatsStatus.initial) {
        provider.loadAll();
      }
      final dashboard = context.read<SellerDashboardProvider>();
      if (dashboard.status == SellerDashboardStatus.initial) {
        dashboard.loadDashboard();
      }
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SellerScaffold(
      currentIndex: 4,
      title: 'Statistiques',
      subtitle: 'Analysez vos performances',
      showBackButton: false,
      extraActions: [
        Consumer<SellerStatsProvider>(
          builder: (context, provider, _) {
            if (provider.isExporting) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              );
            }

            return IconButton(
              icon: const Icon(
                Icons.download_rounded,
                size: 22,
                color: AppColors.textPrimary,
              ),
              onPressed: () => _showExportSheet(provider),
              tooltip: 'Exporter CSV',
            );
          },
        ),
      ],
      child: Consumer<SellerStatsProvider>(
        builder: (context, provider, _) {
          final dashboardProvider = context.watch<SellerDashboardProvider>();
          return Column(
            children: [
              _buildPeriodSelector(provider),

              Expanded(child: _buildContent(provider, dashboardProvider)),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // SÉLECTEUR DE PÉRIODE
  // ============================================

  Widget _buildPeriodSelector(SellerStatsProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: SellerStatsPeriod.values.map((period) {
            final isActive = provider.period == period;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setPeriod(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.warning : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    period.shortLabel,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(
    SellerStatsProvider provider,
    SellerDashboardProvider dashboardProvider,
  ) {
    if (provider.isLoading && !provider.hasAnyData) {
      return _buildSkeleton();
    }

    if (provider.isForbidden) {
      return _buildForbiddenState(provider);
    }

    if (provider.isUnauthorized) {
      return _buildUnauthorizedState();
    }

    if (provider.hasError && !provider.hasAnyData) {
      return _buildErrorState(provider);
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppColors.warning,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ============================================
            // KPI CARDS
            // ============================================
            _buildKpiGrid(provider),

            const SizedBox(height: 20),

            // ============================================
            // GRAPHIQUE DE VENTES
            // ============================================
            _buildSalesChart(provider),

            const SizedBox(height: 20),

            _buildOperationsCharts(dashboardProvider),

            const SizedBox(height: 20),

            _buildProductPerformanceChart(provider),

            const SizedBox(height: 20),

            // ============================================
            // TOP PRODUITS
            // ============================================
            _buildTopProducts(provider),

            const SizedBox(height: 20),

            // ============================================
            // TOP CLIENTS
            // ============================================
            _buildTopCustomers(provider),

            const SizedBox(height: 20),

            // ============================================
            // BOUTON EXPORT
            // ============================================
            _buildExportButton(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationsCharts(SellerDashboardProvider provider) {
    final orders = provider.orders;
    final products = provider.products;
    final orderSegments = <_ChartSegment>[
      _ChartSegment('À accepter', orders?.toAccept ?? 0, AppColors.warning),
      _ChartSegment('À préparer', orders?.toPrepare ?? 0, AppColors.info),
      _ChartSegment('À expédier', orders?.toShip ?? 0, const Color(0xFF8B5CF6)),
      _ChartSegment('Expédiées', orders?.shipped ?? 0, const Color(0xFF06B6D4)),
      _ChartSegment('Livrées', orders?.delivered ?? 0, AppColors.success),
      _ChartSegment('Annulées', orders?.cancelled ?? 0, AppColors.error),
    ];
    final stockSegments = <_ChartSegment>[
      _ChartSegment(
        'En stock',
        ((products?.active ?? 0) -
                (products?.outOfStock ?? 0) -
                (products?.lowStock ?? 0))
            .clamp(0, 1 << 30)
            .toInt(),
        AppColors.success,
      ),
      _ChartSegment('Stock faible', products?.lowStock ?? 0, AppColors.warning),
      _ChartSegment('Rupture', products?.outOfStock ?? 0, AppColors.error),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Vue opérationnelle',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDonutCard(
                  title: 'Commandes',
                  centerLabel: '${orders?.total ?? 0}',
                  segments: orderSegments,
                  emptyMessage: provider.isLoading
                      ? 'Chargement…'
                      : 'Aucune commande',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDonutCard(
                  title: 'Stock produits',
                  centerLabel: '${products?.active ?? 0}',
                  segments: stockSegments,
                  emptyMessage: provider.isLoading
                      ? 'Chargement…'
                      : 'Aucun produit actif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformanceChart(SellerStatsProvider provider) {
    final products = provider.products.topProducts.take(5).toList();
    final maxSold = products.fold<int>(
      0,
      (maximum, product) =>
          product.quantitySold > maximum ? product.quantitySold : maximum,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: .6)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produits les plus vendus',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Articles vendus · ${provider.period.shortLabel}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          if (products.isEmpty)
            const SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Aucune vente de produit sur cette période',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...products.map((product) {
              final ratio = maxSold == 0 ? 0.0 : product.quantitySold / maxSold;
              return Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${product.quantitySold} vendu(s)',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDonutCard({
    required String title,
    required String centerLabel,
    required List<_ChartSegment> segments,
    required String emptyMessage,
  }) {
    final visibleSegments = segments
        .where((segment) => segment.value > 0)
        .toList();
    final total = visibleSegments.fold<int>(
      0,
      (sum, segment) => sum + segment.value,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: .6)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 112,
            child: total == 0
                ? Center(
                    child: Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 31,
                          sections: visibleSegments
                              .map(
                                (segment) => PieChartSectionData(
                                  value: segment.value.toDouble(),
                                  color: segment.color,
                                  radius: 14,
                                  showTitle: false,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Text(
                        centerLabel,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          ...visibleSegments.map(
            (segment) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: segment.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      segment.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${segment.value}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // KPI GRID
  // ============================================

  Widget _buildKpiGrid(SellerStatsProvider provider) {
    final sales = provider.sales;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.45,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildKpiCard(
            icon: Icons.payments_outlined,
            value: sales.formattedRevenue,
            label: 'Chiffre d\'affaires',
            growthLabel: sales.revenueGrowthLabel,
            isPositive: sales.isRevenuePositive,
            color: AppColors.success,
          ),
          _buildKpiCard(
            icon: Icons.receipt_long_outlined,
            value: '${sales.totalOrders}',
            label: 'Commandes',
            growthLabel: sales.ordersGrowthLabel,
            isPositive: sales.isOrdersPositive,
            color: AppColors.info,
          ),
          _buildKpiCard(
            icon: Icons.inventory_2_outlined,
            value: '${sales.totalItems}',
            label: 'Articles vendus',
            growthLabel: sales.itemsGrowthLabel,
            isPositive: sales.isItemsPositive,
            color: AppColors.warning,
          ),
          _buildKpiCard(
            icon: Icons.trending_up_rounded,
            value: sales.formattedAverageOrderValue,
            label: 'Panier moyen',
            growthLabel: sales.avgOrderGrowthLabel,
            isPositive: sales.isAvgOrderPositive,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String value,
    required String label,
    required String growthLabel,
    required bool isPositive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 10,
                      color: isPositive
                          ? AppColors.successDark
                          : AppColors.errorDark,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      growthLabel,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? AppColors.successDark
                            : AppColors.errorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================
  // GRAPHIQUE DE VENTES
  // ============================================

  Widget _buildSalesChart(SellerStatsProvider provider) {
    final timeline = provider.sales.timeline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Évolution des ventes',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  provider.period.shortLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (timeline.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Aucune donnée pour cette période',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            SizedBox(height: 200, child: _buildChart(timeline)),
        ],
      ),
    );
  }

  Widget _buildChart(List<SellerSalesTimelinePoint> timeline) {
    // Trouver le max
    final maxRevenue = timeline.fold<double>(
      0,
      (max, p) => p.revenue > max ? p.revenue : max,
    );

    if (maxRevenue == 0) {
      return const Center(
        child: Text(
          'Aucune vente sur cette période',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    // Limiter à 14 points max pour la lisibilité (échantillonnage)
    final displayTimeline = timeline.length > 14
        ? _sampleTimeline(timeline, 14)
        : timeline;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxRevenue / 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.borderColor.withValues(alpha: 0.4),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: maxRevenue / 3,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  _formatCompact(value),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (displayTimeline.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= displayTimeline.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    displayTimeline[index].dateFormatted,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (displayTimeline.length - 1).clamp(1, 1 << 30).toDouble(),
        minY: 0,
        maxY: maxRevenue * 1.15,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              displayTimeline.length,
              (i) => FlSpot(i.toDouble(), displayTimeline[i].revenue),
            ),
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.warning,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.background,
                  strokeWidth: 2,
                  strokeColor: AppColors.warning,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.warning.withValues(alpha: 0.25),
                  AppColors.warning.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final point = displayTimeline[spot.x.toInt()];
                return LineTooltipItem(
                  '${point.dateFormatted}\n${point.revenue.toStringAsFixed(0)} FCFA',
                  const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<SellerSalesTimelinePoint> _sampleTimeline(
    List<SellerSalesTimelinePoint> timeline,
    int targetCount,
  ) {
    if (timeline.length <= targetCount) return timeline;

    final step = timeline.length / targetCount;
    final result = <SellerSalesTimelinePoint>[];

    for (int i = 0; i < targetCount; i++) {
      result.add(timeline[(i * step).floor()]);
    }

    return result;
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

  // ============================================
  // TOP PRODUITS
  // ============================================

  Widget _buildTopProducts(SellerStatsProvider provider) {
    final products = provider.products;

    if (!products.hasProducts) {
      return _buildEmptySection(
        icon: Icons.inventory_2_outlined,
        title: 'Aucun produit vendu',
        subtitle: 'Vos meilleures ventes apparaîtront ici',
      );
    }

    return _buildSection(
      title: 'Top produits',
      icon: Icons.inventory_2_outlined,
      count: products.topProducts.length,
      child: Column(
        children: products.topProducts
            .map((product) => _buildProductRow(product))
            .toList(),
      ),
    );
  }

  Widget _buildProductRow(SellerProductStat product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Rang
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: product.isTopThree
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: product.rankMedal != null
                  ? Text(
                      product.rankMedal!,
                      style: const TextStyle(fontSize: 14),
                    )
                  : Text(
                      '${product.rank}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: product.isTopThree
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.hasImage
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Nom + quantité
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${product.quantitySold} vendus',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (product.averageRating > 0) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        size: 10,
                        color: AppColors.ratingColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Revenu
          Text(
            product.revenueFormatted,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TOP CLIENTS
  // ============================================

  Widget _buildTopCustomers(SellerStatsProvider provider) {
    final customers = provider.customers;

    if (!customers.hasCustomers) {
      return _buildEmptySection(
        icon: Icons.people_outline_rounded,
        title: 'Aucun client',
        subtitle: 'Vos meilleurs clients apparaîtront ici',
      );
    }

    return _buildSection(
      title: 'Top clients',
      icon: Icons.people_outline_rounded,
      count: customers.topCustomers.length,
      child: Column(
        children: customers.topCustomers
            .map((customer) => _buildCustomerRow(customer))
            .toList(),
      ),
    );
  }

  Widget _buildCustomerRow(SellerCustomerStat customer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: customer.isLoyal
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                customer.initials,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: customer.isLoyal
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Nom + infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        customer.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (customer.isLoyal) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Fidèle',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${customer.ordersCount} commande${customer.ordersCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Total dépensé
          Text(
            customer.totalSpentFormatted,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION GÉNÉRIQUE
  // ============================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required int count,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON EXPORT
  // ============================================

  Widget _buildExportButton(SellerStatsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: provider.isExporting
              ? null
              : () => _showExportSheet(provider),
          icon: provider.isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.warning,
                  ),
                )
              : const Icon(Icons.download_rounded, size: 20),
          label: Text(
            provider.isExporting
                ? 'Export en cours...'
                : 'Exporter les données',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.warning,
            side: const BorderSide(color: AppColors.warning, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM SHEET EXPORT
  // ============================================

  void _showExportSheet(SellerStatsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _buildExportSheet(provider),
    );
  }

  Widget _buildExportSheet(SellerStatsProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Exporter les données',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Format CSV · Période : ${provider.period.label}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              icon: Icons.receipt_long_outlined,
              label: 'Commandes',
              description: 'Toutes vos commandes avec détails',
              color: AppColors.info,
              onTap: () async {
                Navigator.pop(context);
                await _performExport(provider, 'orders');
              },
            ),
            const SizedBox(height: 10),
            _buildExportOption(
              icon: Icons.inventory_2_outlined,
              label: 'Produits',
              description: 'Vos produits avec statistiques de vente',
              color: AppColors.warning,
              onTap: () async {
                Navigator.pop(context);
                await _performExport(provider, 'products');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS EXPORT
  // ============================================

  Future<void> _performExport(SellerStatsProvider provider, String type) async {
    final result = type == 'orders'
        ? await provider.exportOrders()
        : await provider.exportProducts();

    if (!mounted) return;

    if (result != null) {
      _showExportSuccess(result, provider);
    } else {
      _showError(provider.exportError ?? 'Erreur lors de l\'export');
    }
  }

  void _showExportSuccess(
    SellerStatsExportResult result,
    SellerStatsProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 32,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Export réussi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${result.fileName} · ${result.formattedSize}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        provider.shareLastExport();
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text(
                        'Partager',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
                        side: const BorderSide(color: AppColors.info),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        provider.openLastExport();
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text(
                        'Ouvrir',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              4,
              (_) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ERROR STATES
  // ============================================

  Widget _buildErrorState(SellerStatsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              provider.errorMessage ?? 'Impossible de charger les statistiques',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadAll(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Réessayer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForbiddenState(SellerStatsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 45,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'KYC en attente',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              provider.errorMessage ?? 'Votre KYC doit être validé.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.sellerProfile),
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: const Text(
                'Voir mon profil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorizedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Session expirée',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez vous reconnecter pour continuer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Se reconnecter',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS UI
  // ============================================

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _ChartSegment {
  final String label;
  final int value;
  final Color color;

  const _ChartSegment(this.label, this.value, this.color);
}
