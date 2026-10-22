// ============================================
// PAGE : SellerDashboardScreen
// ============================================
// Écran principal du dashboard vendeur.
//
// Structure :
//   - AppBar vendeur (badge "Vendeur" + notifications)
//   - Header boutique (logo + nom + KYC)
//   - Alertes actionnables
//   - 4 KPI cards (Revenus, Commandes, Produits, Note)
//   - Graphique de ventes (7/30/90 jours)
//   - Dernières commandes (5)
//   - Top produits (5)
//   - Bottom nav (5 onglets)
//
// UX :
//   - Pull-to-refresh
//   - Skeleton loading
//   - Empty states
//   - Error states
//   - Animations fluides
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Auth
import '../../../auth/presentation/providers/auth_provider.dart';

// Domain
import '../../domain/entities/seller_dashboard.dart';
import '../providers/seller_profile_provider.dart';
// Presentation
import '../providers/seller_dashboard_provider.dart';
import '../widgets/seller_scaffold.dart';
import '../widgets/seller_kpi_card.dart';
import '../widgets/seller_alert_banner.dart';
import '../widgets/seller_order_tile.dart';
import '../widgets/seller_order_tile.dart';
import '../widgets/seller_onboarding_checklist.dart';
// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Charger le dashboard au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerDashboardProvider>();

      if (provider.status == SellerDashboardStatus.initial) {
        provider.loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SellerScaffold(
      currentIndex: 0,
      onNavTap: (index) => _handleNavigation(index),
      child: Consumer<SellerDashboardProvider>(
        builder: (context, provider, _) {
          return _buildContent(provider);
        },
      ),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(SellerDashboardProvider provider) {
    // 1. Loading initial
    if (provider.isLoading && !provider.hasDashboard) {
      return const _DashboardSkeleton();
    }

    // 2. KYC pending / rejected
    if (provider.isForbidden) {
      return _KycBlockedState(
        message: provider.errorMessage ?? 'Accès refusé',
        kycStatus: provider.kycStatus,
        onGoToProfile: () => _navigateTo(AppRoutes.sellerProfile),
      );
    }

    // 3. Erreur
    if (provider.hasError && !provider.hasDashboard) {
      return _ErrorState(
        message: provider.errorMessage ?? 'Une erreur est survenue',
        onRetry: () => provider.loadDashboard(),
      );
    }

    // 4. Unauthorized (token expiré)
    if (provider.isUnauthorized) {
      return _UnauthorizedState(
        onLogin: () => _handleLogout(),
      );
    }

    // 5. Loaded (avec ou sans données)
    if (provider.hasDashboard) {
      return RefreshIndicator(
        onRefresh: () => provider.refresh(),
        color: AppColors.warning,
        backgroundColor: AppColors.background,
        child: _buildDashboardBody(provider),
      );
    }

    // 6. Fallback (ne devrait pas arriver)
    return const SizedBox.shrink();
  }

  // ============================================
  // BODY DU DASHBOARD
  // ============================================

  Widget _buildDashboardBody(SellerDashboardProvider provider) {
    final dashboard = provider.dashboard!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ============================================
          // ONBOARDING CHECKLIST (NOUVEAU)
          // ============================================
          SellerOnboardingChecklist(
            onDismiss: () {
              context.read<SellerProfileProvider>().dismissOnboarding();
            },
          ),

          // ============================================
          // HEADER BOUTIQUE
          // ============================================
          _ShopHeader(
            seller: dashboard.seller,
            onTap: () => _navigateTo(AppRoutes.sellerProfile),
          ),
          // ============================================
          // HEADER BOUTIQUE
          // ============================================
          _ShopHeader(
            seller: dashboard.seller,
            onTap: () => _navigateTo(AppRoutes.sellerProfile),
          ),

          const SizedBox(height: 8),

          // ============================================
          // ALERTES
          // ============================================
          if (dashboard.hasAlerts)
            SellerAlertsList(
              alerts: dashboard.alerts,
              onAlertTap: (alert) => _handleAlertTap(alert),
              onAlertDismiss: (alert) => _handleAlertDismiss(alert),
            ),

          if (dashboard.hasAlerts) const SizedBox(height: 12),

          // ============================================
          // KPI CARDS
          // ============================================
          _buildKpiGrid(provider),

          const SizedBox(height: 20),

          // ============================================
          // GRAPHIQUE
          // ============================================
          _SalesChartSection(
            provider: provider,
            onPeriodChange: (period) =>
                provider.loadSalesChart(period: period),
          ),

          const SizedBox(height: 20),

          // ============================================
          // DERNIÈRES COMMANDES
          // ============================================
          _SectionHeader(
            title: 'Commandes récentes',
            actionLabel: 'Voir tout',
            onAction: () => _navigateTo(AppRoutes.sellerOrders),
          ),

          const SizedBox(height: 8),

            if (dashboard.hasRecentOrders)
              Column(
                children: dashboard.recentOrders.map((order) {
                  return SellerDashboardOrderTile(
                    order: order,
                    onTap: () => _navigateToOrder(order),
                  );
                }).toList(),
              )
            else
              const _EmptySection(
                icon: Icons.receipt_long_outlined,
                message: 'Aucune commande pour le moment',
              ),

          const SizedBox(height: 20),

          // ============================================
          // TOP PRODUITS
          // ============================================
          _SectionHeader(
            title: 'Top produits',
            actionLabel: 'Voir tout',
            onAction: () => _navigateTo(AppRoutes.sellerProducts),
          ),

          const SizedBox(height: 8),

          if (dashboard.hasTopProducts)
            _buildTopProducts(dashboard.topProducts)
          else
            const _EmptySection(
              icon: Icons.inventory_2_outlined,
              message: 'Aucun produit vendu pour le moment',
            ),
        ],
      ),
    );
  }

  // ============================================
  // KPI GRID
  // ============================================

  Widget _buildKpiGrid(SellerDashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Revenus
          SellerKpiCard(
            icon: Icons.payments_outlined,
            color: AppColors.success,
            value: provider.revenue?.totalFormatted ?? '0 FCFA',
            label: 'Revenus totaux',
            subtitle: provider.revenue?.thisMonthFormatted != null
                ? '${provider.revenue!.thisMonthFormatted} ce mois'
                : null,
            trend: provider.revenue?.hasGrowth == true
                ? provider.revenue!.growthLabel
                : null,
            isTrendPositive: provider.revenue?.isGrowthPositive,
            onTap: () => _navigateTo(AppRoutes.sellerStats),
          ),

          // Commandes
          SellerKpiCard(
            icon: Icons.receipt_long_outlined,
            color: AppColors.warning,
            value: '${provider.orders?.total ?? 0}',
            label: 'Commandes',
            subtitle: provider.pendingOrdersCount > 0
                ? '${provider.pendingOrdersCount} à traiter'
                : null,
            trend: null,
            onTap: () => _navigateTo(AppRoutes.sellerOrders),
          ),

          // Produits
          SellerKpiCard(
            icon: Icons.inventory_2_outlined,
            color: AppColors.primary,
            value: '${provider.products?.active ?? 0}',
            label: 'Produits actifs',
            subtitle: (provider.products?.outOfStock ?? 0) > 0
                ? '${provider.products!.outOfStock} en rupture'
                : '${provider.products?.drafts ?? 0} brouillon(s)',
            onTap: () => _navigateTo(AppRoutes.sellerProducts),
          ),

          // Note
          SellerKpiCard(
            icon: Icons.star_outline_rounded,
            color: AppColors.ratingColor,
            value: provider.reviews?.averageRatingFormatted ?? '0.0/5',
            label: 'Note moyenne',
            subtitle: '${provider.reviews?.total ?? 0} avis',
            onTap: () => _navigateTo(AppRoutes.sellerReviews),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TOP PRODUITS
  // ============================================

  Widget _buildTopProducts(List<DashboardTopProduct> products) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _TopProductCard(product: products[index]);
        },
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Déjà sur le dashboard
        break;
      case 1:
        _navigateTo(AppRoutes.sellerProducts);
        break;
      case 2:
        _navigateTo(AppRoutes.sellerOrders);
        break;
      case 3:
        _navigateTo(AppRoutes.sellerStats);
        break;
      case 4:
        _navigateTo(AppRoutes.profile);
        break;
    }
  }

  void _navigateTo(String route) {
    Navigator.of(context).pushNamed(route);
  }

  void _navigateToOrder(DashboardOrderSummary order) {
    Navigator.of(context).pushNamed(
      AppRoutes.sellerOrders,
      arguments: {'order_id': order.id},
    );
  }

  void _handleAlertTap(DashboardAlert alert) {
    switch (alert.action) {
      case 'orders':
        _navigateTo(AppRoutes.sellerOrders);
        break;
      case 'products':
        _navigateTo(AppRoutes.sellerProducts);
        break;
      case 'reviews':
        _navigateTo(AppRoutes.sellerReviews);
        break;
      case 'profile':
        _navigateTo(AppRoutes.sellerProfile);
        break;
    }
  }

  void _handleAlertDismiss(DashboardAlert alert) {
    // Optionnel : marquer l'alerte comme lue côté backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alerte ignorée',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}

// ============================================
// WIDGET : ShopHeader
// ============================================
// Header boutique avec logo + nom + KYC.
// ============================================

class _ShopHeader extends StatelessWidget {
  final SellerInfo? seller;
  final VoidCallback? onTap;

  const _ShopHeader({
    this.seller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSeller = seller != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warning.withValues(alpha: 0.15),
                  AppColors.warning.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Logo / Initiales
                _buildAvatar(hasSeller),

                const SizedBox(width: 12),

                // Nom + KYC
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasSeller ? seller!.shopName : 'Ma boutique',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildKycBadge(seller),
                    ],
                  ),
                ),

                // Chevron
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool hasSeller) {
    final hasLogo = seller?.hasLogo == true;
    final initials = seller?.initials ?? 'B';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: hasLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                seller!.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsWidget(initials),
              ),
            )
          : _initialsWidget(initials),
    );
  }

  Widget _initialsWidget(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildKycBadge(SellerInfo? seller) {
    final status = seller?.kycStatus ?? 'pending';
    final label = seller?.kycStatusLabel ?? 'En attente';

    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case 'verified':
        bg = AppColors.successLight;
        text = AppColors.successDark;
        icon = Icons.verified_rounded;
        break;
      case 'rejected':
        bg = AppColors.errorLight;
        text = AppColors.errorDark;
        icon = Icons.gpp_bad_outlined;
        break;
      default:
        bg = AppColors.warningLight;
        text = AppColors.warningDark;
        icon = Icons.hourglass_empty_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: text,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGET : SectionHeader
// ============================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGET : TopProductCard
// ============================================

class _TopProductCard extends StatelessWidget {
  final DashboardTopProduct product;

  const _TopProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: _buildImage(),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 11,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${product.salesCountFormatted} ventes',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.priceFormatted,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                    height: 1.2,
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
  }

  Widget _buildImage() {
    if (product.hasImage) {
      return Image.network(
        product.mainImageUrl!,
        height: 80,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 80,
      width: double.infinity,
      color: AppColors.surfaceAlt,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: AppColors.textTertiary,
      ),
    );
  }
}

// ============================================
// WIDGET : SalesChartSection
// ============================================

class _SalesChartSection extends StatelessWidget {
  final SellerDashboardProvider provider;
  final void Function(int period) onPeriodChange;

  const _SalesChartSection({
    required this.provider,
    required this.onPeriodChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
          children: [
            // Titre + Périodes
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Ventes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildPeriodSelector(),
              ],
            ),

            const SizedBox(height: 14),

            // Graphique (placeholder simple en attendant fl_chart)
            _buildChartPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [7, 30, 90].map((period) {
          final isActive = provider.selectedPeriod == period;
          return GestureDetector(
            onTap: () => onPeriodChange(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.warning : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${period}j',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    if (provider.isLoadingChart) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.warning,
            ),
          ),
        ),
      );
    }

    final chart = provider.salesChart;

    if (chart == null || chart['data'] == null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    // Placeholder visuel (le vrai graphique viendra avec fl_chart)
    final total = chart['total_revenue_formatted'] ?? '0 FCFA';
    final items = chart['total_items'] ?? 0;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total sur la période',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total.toString(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$items article(s) vendu(s)',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGET : EmptySection
// ============================================

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySection({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// WIDGET : DashboardSkeleton
// ============================================

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _skeletonBox(height: 76, radius: 16),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              4,
              (_) => _skeletonBox(height: 100, radius: 16),
            ),
          ),
          const SizedBox(height: 20),
          _skeletonBox(height: 120, radius: 16),
          const SizedBox(height: 20),
          _skeletonBox(height: 80, radius: 16),
          const SizedBox(height: 8),
          _skeletonBox(height: 80, radius: 16),
          const SizedBox(height: 8),
          _skeletonBox(height: 80, radius: 16),
        ],
      ),
    );
  }

  Widget _skeletonBox({required double height, required double radius}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ============================================
// WIDGET : ErrorState
// ============================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
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
              message,
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
              onPressed: onRetry,
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
}

// ============================================
// WIDGET : KycBlockedState
// ============================================

class _KycBlockedState extends StatelessWidget {
  final String message;
  final String? kycStatus;
  final VoidCallback onGoToProfile;

  const _KycBlockedState({
    required this.message,
    this.kycStatus,
    required this.onGoToProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = kycStatus == 'rejected';

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
                color: isRejected ? AppColors.errorLight : AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRejected ? Icons.gpp_bad_outlined : Icons.hourglass_empty_rounded,
                size: 45,
                color: isRejected ? AppColors.error : AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isRejected ? 'KYC refusé' : 'KYC en attente',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
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
              onPressed: onGoToProfile,
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: Text(
                isRejected ? 'Corriger mon KYC' : 'Voir mon profil',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRejected ? AppColors.error : AppColors.warning,
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
}

// ============================================
// WIDGET : UnauthorizedState
// ============================================

class _UnauthorizedState extends StatelessWidget {
  final VoidCallback onLogin;

  const _UnauthorizedState({required this.onLogin});

  @override
  Widget build(BuildContext context) {
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
              onPressed: onLogin,
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
}