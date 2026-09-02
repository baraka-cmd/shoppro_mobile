// ============================================
// PAGE : AdminDashboardScreen
// ============================================
// Écran principal du tableau de bord administrateur.
// Design mobile avec bottom navigation et drawer.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Cartes statistiques (grille 2x2 mobile)
// - Graphique des ventes
// - Alertes et activité récente
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
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
import '../providers/admin_dashboard_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_sales_chart.dart';      // ✅ AJOUTE CECI
import '../widgets/admin_quick_actions.dart';    // ✅ AJOUTE CECI
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import 'package:provider/provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran du tableau de bord administrateur mobile.
///
/// Affiche :
/// - 4 cartes statistiques en grille 2x2
/// - Graphique des ventes
/// - Alertes récentes
/// - Actions rapides
/// - Top produits
/// - Commandes récentes
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    // Charger les données après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().loadDashboard();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      subtitle: "Vue d'ensemble",
      currentRoute: AppRoutes.adminDashboard,
      notificationCount: 3,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () async {
        final authProvider = context.read<AuthProvider>();
        await authProvider.logout();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.cards,
              itemCount: 4,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadDashboard,
            ),
          );
        }

        if (provider.hasStats) {
          return _buildDashboardContent(provider);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ============================================
  // CONTENU DU DASHBOARD
  // ============================================

  Widget _buildDashboardContent(AdminDashboardProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refreshDashboard,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // CARTES STATISTIQUES (GRILLE 2x2 MOBILE)
            // ============================================
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                AdminStatCard(
                  label: 'Revenu Total',
                  value: provider.totalRevenueFormatted,
                  icon: Icons.payments_outlined,
                  iconBackgroundColor: AppColors.successLight,
                  iconColor: AppColors.success,
                  variation: 15.2,
                  isPositiveVariation: true,
                  variationLabel: 'vs mois dernier',
                ),
                AdminStatCard(
                  label: 'Commandes',
                  value: '${provider.totalOrders}',
                  icon: Icons.receipt_long_outlined,
                  iconBackgroundColor: AppColors.infoLight,
                  iconColor: AppColors.info,
                  variation: 8.5,
                  isPositiveVariation: true,
                  variationLabel: 'vs mois dernier',
                ),
                AdminStatCard(
                  label: 'Utilisateurs',
                  value: '${provider.totalUsers}',
                  icon: Icons.people_outline,
                  iconBackgroundColor: AppColors.warningLight,
                  iconColor: AppColors.warning,
                  variation: 5.3,
                  isPositiveVariation: true,
                  variationLabel: 'vs mois dernier',
                ),
                AdminStatCard(
                  label: 'Produits',
                  value: '${provider.totalProducts}',
                  icon: Icons.inventory_2_outlined,
                  iconBackgroundColor: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF8B5CF6),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ============================================
// GRAPHIQUE DES VENTES (INLINE)
// ============================================
Container(
  padding: const EdgeInsets.all(16),
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
            'Ventes des 30 derniers jours',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: AppColors.textTertiary),
                SizedBox(width: 6),
                Text(
                  '30 jours',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        height: 180,
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
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.salesByDay.length} jours de données',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
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
),

const SizedBox(height: 16),

// ============================================
// ALERTES (si présentes)
// ============================================
if (provider.hasAlerts) ...[
  _buildAlertsSection(provider),
  const SizedBox(height: 16),
],

// ============================================
// ACTIONS RAPIDES (INLINE)
// ============================================
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: AppColors.cardShadow,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Actions rapides',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          _buildQuickAction(
            label: 'Produits',
            icon: Icons.inventory_2_outlined,
            color: AppColors.primary,
            bgColor: AppColors.infoLight,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminProducts),
          ),
          const SizedBox(width: 8),
          _buildQuickAction(
            label: 'Commandes',
            icon: Icons.receipt_long_outlined,
            color: AppColors.info,
            bgColor: AppColors.infoLight,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminOrders),
          ),
          const SizedBox(width: 8),
          _buildQuickAction(
            label: 'Avis',
            icon: Icons.star_outline,
            color: AppColors.warningDark,
            bgColor: AppColors.warningLight,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminReviews),
          ),
          const SizedBox(width: 8),
          _buildQuickAction(
            label: 'Stocks',
            icon: Icons.warehouse_outlined,
            color: AppColors.error,
            bgColor: AppColors.errorLight,
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminStocks),
          ),
        ],
      ),
    ],
  ),
),

            const SizedBox(height: 16),

            // ============================================
            // TOP PRODUITS
            // ============================================
            _buildTopProducts(provider),

            const SizedBox(height: 16),

            // ============================================
            // COMMANDES RÉCENTES
            // ============================================
            _buildRecentOrders(provider),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SECTION ALERTES
  // ============================================

  Widget _buildAlertsSection(AdminDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.totalAlerts} alerte(s)',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningDark,
                  ),
                ),
                Text(
                  '${provider.lowStockCount} stock(s) faible(s), ${provider.pendingOrdersCount} commande(s)',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.warningDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.adminStocks);
            },
            icon: const Icon(
              Icons.arrow_forward,
              size: 18,
              color: AppColors.warningDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TOP PRODUITS
  // ============================================

  Widget _buildTopProducts(AdminDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                'Top Produits',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.adminProducts);
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.topProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Aucun produit vendu',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...provider.topProducts.take(5).map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product['name'] as String? ?? 'Produit',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'x${product['quantity'] ?? 0}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
  // COMMANDES RÉCENTES
  // ============================================

  Widget _buildRecentOrders(AdminDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                'Commandes Récentes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.adminOrders);
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.recentOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Aucune commande récente',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...provider.recentOrders.take(5).map((order) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['order_number'] as String? ?? 'Commande',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            order['customer'] as String? ?? 'Client',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${order['total'] ?? 0} FCFA',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
  // HELPERS
  // ============================================

  /// Formate une date courte (ex: "2026-08-31" → "31/08")
  String _formatShortDate(String date) {
    if (date.isEmpty) return '';
    final parts = date.split('-');
    if (parts.length >= 3) {
      return '${parts[2]}/${parts[1]}';
    }
    return date;
  }


  // ============================================
// ACTION RAPIDE INLINE
// ============================================

Widget _buildQuickAction({
  required String label,
  required IconData icon,
  required Color color,
  required Color bgColor,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}