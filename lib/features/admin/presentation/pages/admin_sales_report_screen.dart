// ============================================
// PAGE : AdminSalesReportScreen
// ============================================
// Écran de rapport de ventes - Design mobile optimisé.
// Structure verticale empilée (pas de Row web).
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Providers (même feature admin)
import '../providers/admin_stats_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de rapport de ventes mobile.
///
/// Affiche :
/// - Résumé financier en grille 2x3
/// - Répartition des commandes en grille
/// - Analyse des clients en grille 2x2
/// - Analyse des produits en grille 2x2
class AdminSalesReportScreen extends StatefulWidget {
  const AdminSalesReportScreen({super.key});

  @override
  State<AdminSalesReportScreen> createState() => _AdminSalesReportScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminSalesReportScreenState extends State<AdminSalesReportScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStatsProvider>().loadReport();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Rapport de ventes',
      subtitle: 'Analyse détaillée',
      currentRoute: AppRoutes.adminSalesReport,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () {},
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminStatsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading || provider.isGenerating) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 5,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadReport,
            ),
          );
        }

        final report = provider.currentReport;
        if (report == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // PÉRIODE + EXPORT
              // ============================================
              _buildPeriodHeader(provider),

              const SizedBox(height: 16),

              // ============================================
              // RÉSUMÉ FINANCIER (GRILLE 2x3)
              // ============================================
              _buildFinancialSummary(report),

              const SizedBox(height: 16),

              // ============================================
              // RÉPARTITION DES COMMANDES (GRILLE)
              // ============================================
              _buildOrdersBreakdown(report),

              const SizedBox(height: 16),

              // ============================================
              // ANALYSE DES CLIENTS (GRILLE 2x2)
              // ============================================
              _buildCustomerAnalysis(report),

              const SizedBox(height: 16),

              // ============================================
              // ANALYSE DES PRODUITS (GRILLE 2x2)
              // ============================================
              _buildProductAnalysis(report),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // EN-TÊTE : PÉRIODE + EXPORT
  // ============================================

  Widget _buildPeriodHeader(AdminStatsProvider provider) {
    return Column(
      children: [
        // Période
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  provider.currentReport?.periodFormatted ?? '',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Boutons Export
        Row(
          children: [
            Expanded(
              child: _buildExportButton(
                label: 'CSV',
                icon: Icons.table_chart_outlined,
                color: AppColors.success,
                onTap: () => provider.exportCurrentReportToCsv(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildExportButton(
                label: 'JSON',
                icon: Icons.code,
                color: AppColors.primary,
                onTap: () => provider.exportCurrentReportToJson(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bouton d'export.
  Widget _buildExportButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // RÉSUMÉ FINANCIER (GRILLE 2x3)
  // ============================================

  Widget _buildFinancialSummary(dynamic report) {
    final items = [
      {
        'label': 'Revenu Total',
        'value': report.totalRevenueFormatted,
        'icon': Icons.payments_outlined,
        'color': AppColors.success,
        'bgColor': AppColors.successLight,
      },
      {
        'label': 'Revenu Net',
        'value': report.netRevenueFormatted,
        'icon': Icons.account_balance_outlined,
        'color': AppColors.primary,
        'bgColor': AppColors.infoLight,
      },
      {
        'label': 'Taxes',
        'value': report.taxRevenueFormatted,
        'icon': Icons.percent,
        'color': AppColors.warning,
        'bgColor': AppColors.warningLight,
      },
      {
        'label': 'Livraison',
        'value': report.shippingRevenueFormatted,
        'icon': Icons.local_shipping_outlined,
        'color': AppColors.info,
        'bgColor': AppColors.infoLight,
      },
      {
        'label': 'Remises',
        'value': report.discountAmountFormatted,
        'icon': Icons.local_offer_outlined,
        'color': const Color(0xFF8B5CF6),
        'bgColor': const Color(0xFFF3E8FF),
      },
      {
        'label': 'Remboursements',
        'value': report.refundAmountFormatted,
        'icon': Icons.replay,
        'color': AppColors.error,
        'bgColor': AppColors.errorLight,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé financier',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item['bgColor'] as Color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 14,
                        color: item['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['value'] as String,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================
  // RÉPARTITION DES COMMANDES
  // ============================================

  Widget _buildOrdersBreakdown(dynamic report) {
    final stats = [
      {'label': 'Total', 'value': report.totalOrders, 'color': AppColors.info},
      {'label': 'Payées', 'value': report.paidOrders, 'color': AppColors.success},
      {'label': 'En attente', 'value': report.pendingOrders, 'color': AppColors.warning},
      {'label': 'Annulées', 'value': report.cancelledOrders, 'color': AppColors.error},
      {'label': 'Livrées', 'value': report.deliveredOrders, 'color': AppColors.primary},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des commandes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: stats.map((stat) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${stat['value']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Taux en Wrap
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildRatePill(
                label: 'Paiement',
                value: report.paidOrdersRateFormatted,
                color: AppColors.success,
              ),
              _buildRatePill(
                label: 'Annulation',
                value: report.cancelledOrdersRateFormatted,
                color: AppColors.error,
              ),
              _buildRatePill(
                label: 'Livraison',
                value: report.deliveredOrdersRateFormatted,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pilule de taux compacte.
  Widget _buildRatePill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ANALYSE DES CLIENTS (GRILLE 2x2)
  // ============================================

  Widget _buildCustomerAnalysis(dynamic report) {
    final customers = [
      {'label': 'Total', 'value': report.totalCustomers, 'icon': Icons.people_outline, 'color': AppColors.info},
      {'label': 'Nouveaux', 'value': report.newCustomers, 'icon': Icons.person_add_outlined, 'color': AppColors.success},
      {'label': 'Actifs', 'value': report.activeCustomers, 'icon': Icons.person_outline, 'color': AppColors.primary},
      {'label': 'Fidèles', 'value': report.loyalCustomers, 'icon': Icons.star_outline, 'color': AppColors.warning},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse des clients',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: customers.map((c) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(c['icon'] as IconData, size: 18, color: c['color'] as Color),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${c['value']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          c['label'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Taux en Wrap
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildRatePill(
                label: 'Rétention',
                value: report.retentionRateFormatted,
                color: AppColors.success,
              ),
              _buildRatePill(
                label: 'Conversion',
                value: report.conversionRateFormatted,
                color: AppColors.info,
              ),
              _buildRatePill(
                label: 'Articles/cmd',
                value: report.averageItemsPerOrder.toStringAsFixed(1),
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // ANALYSE DES PRODUITS (GRILLE 2x2)
  // ============================================

  Widget _buildProductAnalysis(dynamic report) {
    final products = [
      {'label': 'Articles vendus', 'value': report.totalItemsSold, 'icon': Icons.inventory_2_outlined, 'color': AppColors.info},
      {'label': 'Produits actifs', 'value': report.activeProducts, 'icon': Icons.check_circle_outline, 'color': AppColors.success},
      {'label': 'Rupture', 'value': report.outOfStockProducts, 'icon': Icons.cancel_outlined, 'color': AppColors.error},
      {'label': 'Top produit', 'value': report.topProductFormatted, 'icon': Icons.emoji_events_outlined, 'color': AppColors.warning},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse des produits',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: products.map((p) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(p['icon'] as IconData, size: 18, color: p['color'] as Color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${p['value']}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            p['label'] as String,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}