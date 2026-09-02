// ============================================
// PAGE : AdminStocksScreen
// ============================================
// Écran de gestion des stocks administrés mobile.
// Design avec cartes verticales et alertes compactes.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Bannière d'alertes
// - Filtres en chips
// - Liste de cartes stocks verticales
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
import '../providers/admin_stock_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des stocks mobile.
///
/// Affiche :
/// - Les alertes de stock
/// - Les stocks en cartes verticales
/// - Les actions d'ajustement
class AdminStocksScreen extends StatefulWidget {
  const AdminStocksScreen({super.key});

  @override
  State<AdminStocksScreen> createState() => _AdminStocksScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminStocksScreenState extends State<AdminStocksScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStockProvider>().loadStocks();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Stocks',
      subtitle: 'Gérez vos stocks',
      currentRoute: AppRoutes.adminStocks,
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
    return Consumer<AdminStockProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 6,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadStocks,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // ALERTES DE STOCK (si présentes)
            // ============================================
            if (provider.hasAlerts)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildAlertsBanner(provider),
              ),

            // ============================================
            // FILTRES
            // ============================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildFilters(provider),
            ),

            // ============================================
            // LISTE DES STOCKS EN CARTES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.warehouse_outlined,
                      title: 'Aucun stock',
                      message: 'Les stocks apparaîtront ici.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.filteredStocks.length,
                      itemBuilder: (context, index) {
                        final stock = provider.filteredStocks[index];
                        return _buildStockCard(stock, provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // BANNIÈRE D'ALERTES
  // ============================================

  Widget _buildAlertsBanner(AdminStockProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.alertCount} alerte(s)',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningDark,
                  ),
                ),
                Text(
                  '${provider.lowStocks} faible(s), ${provider.outOfStocks} rupture(s)',
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
        ],
      ),
    );
  }

  // ============================================
  // FILTRES
  // ============================================

  Widget _buildFilters(AdminStockProvider provider) {
    return Row(
      children: [
        _buildFilterChip(
          label: 'Faible',
          icon: Icons.warning_amber_rounded,
          isActive: provider.showLowStockOnly,
          onTap: provider.toggleLowStockFilter,
        ),
        const SizedBox(width: 6),
        _buildFilterChip(
          label: 'Rupture',
          icon: Icons.cancel_outlined,
          isActive: provider.showOutOfStockOnly,
          onTap: provider.toggleOutOfStockFilter,
        ),
        const Spacer(),
        Text(
          '${provider.stocksCount} stocks',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Chip de filtre compact.
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isActive ? Colors.white : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // CARTE STOCK
  // ============================================

  Widget _buildStockCard(dynamic stock, AdminStockProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // LIGNE 1 : Icône + Nom + Statut
          // ============================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stock.productName ?? 'Produit',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStockStatusBadge(stock),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================
          // LIGNE 2 : Quantités
          // ============================================
          Row(
            children: [
              _buildQuantityInfo(
                label: 'Quantité',
                value: stock.quantity,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              _buildQuantityInfo(
                label: 'Réservé',
                value: stock.reservedQuantity,
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              _buildQuantityInfo(
                label: 'Disponible',
                value: stock.availableQuantity,
                color: AppColors.success,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Séparateur
          Container(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 3 : Actions
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                label: 'Ajuster',
                icon: Icons.edit_outlined,
                color: AppColors.info,
                onTap: () {},
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                label: 'Historique',
                icon: Icons.history,
                color: AppColors.textTertiary,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Info de quantité compacte.
  Widget _buildQuantityInfo({
    required String label,
    required dynamic value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Petit bouton d'action.
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BADGE DE STATUT
  // ============================================

  Widget _buildStockStatusBadge(dynamic stock) {
    Color bgColor;
    Color textColor;
    String label;

    if (stock.isOutOfStock == true || (stock.quantity ?? 0) <= 0) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Rupture';
    } else if (stock.isLowStock == true || (stock.quantity ?? 0) <= (stock.minQuantity ?? 5)) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'Faible';
    } else {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'En stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}