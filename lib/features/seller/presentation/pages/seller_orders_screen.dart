// ============================================
// PAGE : SellerOrdersScreen
// ============================================
// Écran de gestion des commandes vendeur.
//
// Structure :
//   - AppBar avec recherche
//   - Tabs horizontaux (À accepter, En préparation, etc.)
//   - Compteur + Pull-to-refresh
//   - Liste paginée avec scroll infini
//   - FAB ou actions flottantes (optionnel)
//
// UX :
//   - Skeleton loading
//   - Empty state par tab
//   - Error state avec retry
//   - KYC blocked state
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_order.dart';

// Presentation
import '../providers/seller_order_provider.dart';
import '../widgets/seller_order_tile.dart';
import '../widgets/seller_scaffold.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerOrderProvider>();
      if (provider.listStatus == SellerOrderListStatus.initial) {
        provider.loadOrders();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ============================================
  // SCROLL INFINI
  // ============================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final provider = context.read<SellerOrderProvider>();
      if (provider.hasMore && !provider.isLoadingMore && !provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SellerScaffold(
      currentIndex: 2,
      title: 'Mes commandes',
      subtitle: _buildSubtitle(),
      showBackButton: false,
      extraActions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
          onPressed: _toggleSearch,
          tooltip: _showSearch ? 'Fermer' : 'Rechercher',
        ),
        IconButton(
          icon: const Icon(
            Icons.refresh_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            context.read<SellerOrderProvider>().refresh();
          },
          tooltip: 'Rafraîchir',
        ),
      ],
      child: Consumer<SellerOrderProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (_showSearch) _buildSearchBar(provider),

              _buildTabsBar(provider),

              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // SUBTITLE
  // ============================================

  String _buildSubtitle() {
    final provider = context.watch<SellerOrderProvider>();
    if (provider.totalPendingActions > 0) {
      return '${provider.totalPendingActions} action${provider.totalPendingActions > 1 ? 's' : ''} en attente';
    }
    return '${provider.total} commande${provider.total > 1 ? 's' : ''}';
  }

  // ============================================
  // BARRE DE RECHERCHE
  // ============================================

  Widget _buildSearchBar(SellerOrderProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: AppColors.background,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Rechercher par n° de commande...',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          suffixIcon: provider.search.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        onSubmitted: (value) => provider.setSearch(value),
      ),
    );
  }

  // ============================================
  // BARRE D'ONGLETS (TABS)
  // ============================================

  Widget _buildTabsBar(SellerOrderProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: SellerOrderTab.values.map((tab) {
            final isActive = provider.activeTab == tab;
            final count = provider.getCountForTab(tab);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTabChip(
                tab: tab,
                isActive: isActive,
                count: count,
                onTap: () => provider.setActiveTab(tab),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabChip({
    required SellerOrderTab tab,
    required bool isActive,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.warning : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: isActive
              ? null
              : Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppColors.warning,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(SellerOrderProvider provider) {
    // Loading initial
    if (provider.isLoading && provider.orders.isEmpty) {
      return _buildSkeleton();
    }

    // KYC blocked
    if (provider.isForbidden) {
      return _buildKycBlockedState(provider);
    }

    // Unauthorized
    if (provider.isUnauthorized) {
      return _buildUnauthorizedState();
    }

    // Erreur
    if (provider.hasError && provider.orders.isEmpty) {
      return _buildErrorState(provider);
    }

    // Liste vide
    if (provider.orders.isEmpty) {
      return _buildEmptyState(provider);
    }

    // Liste
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppColors.warning,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount: provider.orders.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.orders.length) {
            return _buildLoadMoreIndicator();
          }

          final order = provider.orders[index];
          return SellerOrderTile(
            order: order,
            onTap: () => _navigateToDetail(order),
          );
        },
      ),
    );
  }

  // ============================================
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================
  // LOAD MORE
  // ============================================

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
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

  // ============================================
  // EMPTY STATE
  // ============================================

  Widget _buildEmptyState(SellerOrderProvider provider) {
    final tab = provider.activeTab;

    final IconData icon;
    final String title;
    final String subtitle;

    switch (tab) {
      case SellerOrderTab.toAccept:
        icon = Icons.pending_actions_rounded;
        title = 'Aucune commande à accepter';
        subtitle = 'Toutes vos commandes ont été traitées. Bravo !';
        break;
      case SellerOrderTab.preparing:
        icon = Icons.inventory_2_outlined;
        title = 'Aucune commande en préparation';
        subtitle = 'Acceptez des commandes pour les préparer ici.';
        break;
      case SellerOrderTab.shipped:
        icon = Icons.local_shipping_outlined;
        title = 'Aucune commande expédiée';
        subtitle = 'Expédiez vos colis pour les voir apparaître ici.';
        break;
      case SellerOrderTab.delivered:
        icon = Icons.check_circle_outline_rounded;
        title = 'Aucune commande livrée';
        subtitle = 'Vos commandes livrées apparaîtront ici.';
        break;
      case SellerOrderTab.cancelled:
        icon = Icons.cancel_outlined;
        title = 'Aucune commande annulée';
        subtitle = 'Excellent ! Aucune annulation récente.';
        break;
      default:
        icon = Icons.receipt_long_outlined;
        title = 'Aucune commande';
        subtitle = 'Vous n\'avez pas encore de commandes.';
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                child: Icon(icon, size: 42, color: AppColors.warning),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ERROR STATE
  // ============================================

  Widget _buildErrorState(SellerOrderProvider provider) {
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
              provider.listError ?? 'Une erreur est survenue',
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
              onPressed: () => provider.loadOrders(forceRefresh: true),
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

  // ============================================
  // KYC BLOCKED
  // ============================================

  Widget _buildKycBlockedState(SellerOrderProvider provider) {
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
              provider.listError ?? 'Votre KYC doit être validé.',
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
              onPressed: () => Navigator.of(context)
                  .pushNamed(AppRoutes.sellerProfile),
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

  // ============================================
  // UNAUTHORIZED
  // ============================================

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
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
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
  // ACTIONS
  // ============================================

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocus.requestFocus();
        });
      } else {
        _searchController.clear();
        context.read<SellerOrderProvider>().clearSearch();
      }
    });
  }

  void _navigateToDetail(SellerOrder order) {
    Navigator.of(context).pushNamed(
      AppRoutes.sellerOrderDetail,
      arguments: {'order_id': order.id},
    );
  }
}