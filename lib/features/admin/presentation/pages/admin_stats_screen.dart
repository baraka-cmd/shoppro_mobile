// ============================================
// PAGE : AdminStatsScreen
// ============================================
// Écran des statistiques - Design mobile optimisé.
// Structure verticale empilée (pas de Row/Column web).
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
import '../widgets/admin_stat_card.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran des statistiques mobile.
///
/// Affiche :
/// - Sélecteur de période scrollable horizontal
/// - Cartes de résumé en grille 2x2
/// - Graphique pleine largeur
/// - Statuts empilés
/// - Top produits/catégories empilés
class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminStatsScreenState extends State<AdminStatsScreen> {
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
      title: 'Statistiques',
      subtitle: 'Analysez vos performances',
      currentRoute: AppRoutes.adminStats,
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

        if (provider.currentReport == null) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
          onRefresh: provider.loadReport,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // SÉLECTEUR DE PÉRIODE (SCROLLABLE HORIZONTAL)
                // ============================================
                _buildPeriodSelector(provider),

                const SizedBox(height: 16),

                // ============================================
                // CARTES DE RÉSUMÉ (GRILLE 2x2 MOBILE)
                // ============================================
                _buildSummaryCards(provider),

                const SizedBox(height: 16),

                // ============================================
                // GRAPHIQUE DES REVENUS (PLEINE LARGEUR)
                // ============================================
                _buildRevenueChart(provider),

                const SizedBox(height: 16),

                // ============================================
                // COMMANDES PAR STATUT (PLEINE LARGEUR)
                // ============================================
                _buildOrdersByStatus(provider),

                const SizedBox(height: 16),

                // ============================================
                // TOP PRODUITS (PLEINE LARGEUR)
                // ============================================
                _buildTopProducts(provider),

                const SizedBox(height: 16),

                // ============================================
                // TOP CATÉGORIES (PLEINE LARGEUR)
                // ============================================
                _buildTopCategories(provider),

                const SizedBox(height: 16),

                // ============================================
                // PAIEMENTS (PLEINE LARGEUR)
                // ============================================
                _buildPaymentsSection(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // SÉLECTEUR DE PÉRIODE (SCROLLABLE)
  // ============================================

  Widget _buildPeriodSelector(AdminStatsProvider provider) {
    final periods = [
      {'label': "Aujourd'hui", 'period': 'today'},
      {'label': '7 jours', 'period': 'last_7_days'},
      {'label': '30 jours', 'period': 'last_30_days'},
      {'label': 'Ce mois', 'period': 'this_month'},
      {'label': 'Cette année', 'period': 'this_year'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length + 1, // +1 pour le bouton Export
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          if (index == periods.length) {
            // Bouton Export à la fin
            return _buildExportButton(provider);
          }

          final p = periods[index];
          final isSelected = provider.selectedPeriod.code == p['period'];

          return Material(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                // Changer la période selon le chip cliqué
                final periodCode = p['period'] as String;
                switch (periodCode) {
                  case 'today':
                    provider.loadTodayReport();
                    break;
                  case 'last_7_days':
                    provider.loadLast7DaysReport();
                    break;
                  case 'last_30_days':
                    provider.loadLast30DaysReport();
                    break;
                  case 'this_month':
                    provider.loadThisMonthReport();
                    break;
                  case 'this_year':
                    provider.loadThisYearReport();
                    break;
                }
              },
  
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  p['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Bouton d'export compact.
  Widget _buildExportButton(AdminStatsProvider provider) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'csv') {
          await provider.exportCurrentReportToCsv();
          _showSnackBar('Export CSV généré');
        } else if (value == 'json') {
          await provider.exportCurrentReportToJson();
          _showSnackBar('Export JSON généré');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 16, color: AppColors.textTertiary),
              SizedBox(width: 6),
              Text('CSV', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'json',
          child: Row(
            children: [
              Icon(Icons.code, size: 16, color: AppColors.textTertiary),
              SizedBox(width: 6),
              Text('JSON', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.download, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Export',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CARTES DE RÉSUMÉ (GRILLE 2x2)
  // ============================================

  Widget _buildSummaryCards(AdminStatsProvider provider) {
    final report = provider.currentReport!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: [
        AdminStatCard(
          label: 'Revenu Total',
          value: report.totalRevenueFormatted,
          icon: Icons.payments_outlined,
          iconBackgroundColor: AppColors.successLight,
          iconColor: AppColors.success,
        ),
        AdminStatCard(
          label: 'Commandes',
          value: '${report.totalOrders}',
          icon: Icons.receipt_long_outlined,
          iconBackgroundColor: AppColors.infoLight,
          iconColor: AppColors.info,
        ),
        AdminStatCard(
          label: 'Clients',
          value: '${report.totalCustomers}',
          icon: Icons.people_outline,
          iconBackgroundColor: AppColors.warningLight,
          iconColor: AppColors.warning,
        ),
        AdminStatCard(
          label: 'Panier Moyen',
          value: report.averageOrderValueFormatted,
          icon: Icons.shopping_cart_outlined,
          iconBackgroundColor: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  // ============================================
  // GRAPHIQUE DES REVENUS (PLEINE LARGEUR)
  // ============================================

  Widget _buildRevenueChart(AdminStatsProvider provider) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenus',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Flexible(
                child: Text(
                  provider.currentReport?.periodName ?? '',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart,
                    size: 40,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.revenueByDay.length} jours de données',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
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
  // COMMANDES PAR STATUT (PLEINE LARGEUR)
  // ============================================

  Widget _buildOrdersByStatus(AdminStatsProvider provider) {
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
            'Commandes par statut',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.ordersByStatus.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Aucune donnée',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...provider.ordersByStatus.entries.take(5).map((entry) {
              return _buildStatusRow(
                label: entry.key,
                count: entry.value,
                total: provider.currentReport?.totalOrders ?? 0,
              );
            }),
        ],
      ),
    );
  }

  /// Ligne de statut avec barre.
  Widget _buildStatusRow({
    required String label,
    required int count,
    required int total,
  }) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
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
              const SizedBox(width: 8),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(2.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TOP PRODUITS (PLEINE LARGEUR)
  // ============================================

  Widget _buildTopProducts(AdminStatsProvider provider) {
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
            'Top Produits',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (provider.topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Aucun produit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...provider.topProducts.take(5).map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product['name'] ?? 'Produit',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${product['revenue'] ?? 0} FCFA',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // ============================================
  // TOP CATÉGORIES (PLEINE LARGEUR)
  // ============================================

  Widget _buildTopCategories(AdminStatsProvider provider) {
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
            'Top Catégories',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (provider.topCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Aucune catégorie',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...provider.topCategories.take(5).map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        size: 14,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name'] ?? 'Catégorie',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${category['orders'] ?? 0} cmd',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
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

  // ============================================
  // PAIEMENTS (PLEINE LARGEUR)
  // ============================================

  Widget _buildPaymentsSection(AdminStatsProvider provider) {
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
            'Méthodes de paiement',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (provider.paymentsByMethod.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Aucune donnée',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.paymentsByMethod.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        entry.key,
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
        ],
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}