// ============================================
// PAGE : AdminOrdersScreen
// ============================================
// Écran de gestion des commandes administrées.
// Design mobile avec cartes verticales et filtres scrollables.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Filtres par statut (chips scrollables)
// - Liste de cartes commandes verticales
// - Pagination simple
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
import '../providers/admin_order_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des commandes mobile.
///
/// Affiche :
/// - Les commandes en cartes verticales
/// - Les filtres par statut en chips
/// - Les actions contextuelles
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminOrderProvider>().loadOrders();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Commandes',
      subtitle: 'Gérez vos commandes',
      currentRoute: AppRoutes.adminOrders,
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
    return Consumer<AdminOrderProvider>(
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
              onRetry: provider.loadOrders,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // FILTRES PAR STATUT (CHIPS SCROLLABLES)
            // ============================================
            _buildStatusTabs(provider),

            const SizedBox(height: 8),

            // ============================================
            // LISTE DES COMMANDES EN CARTES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Aucune commande',
                      message: 'Les commandes apparaîtront ici.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.orders.length,
                      itemBuilder: (context, index) {
                        final order = provider.orders[index];
                        return _buildOrderCard(order, provider);
                      },
                    ),
            ),

            // ============================================
            // PAGINATION SIMPLE
            // ============================================
            if (provider.orders.isNotEmpty)
              _buildPagination(provider),
          ],
        );
      },
    );
  }

  // ============================================
  // FILTRES PAR STATUT
  // ============================================

  Widget _buildStatusTabs(AdminOrderProvider provider) {
    final tabs = [
      {'label': 'Toutes', 'status': null},
      {'label': 'En attente', 'status': 'pending'},
      {'label': 'Confirmées', 'status': 'confirmed'},
      {'label': 'Expédiées', 'status': 'shipped'},
      {'label': 'Livrées', 'status': 'delivered'},
      {'label': 'Annulées', 'status': 'cancelled'},
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = provider.filterStatus == tab['status'];

          return Material(
            color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => provider.filterByStatus(tab['status'] as String?),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  tab['label'] as String,
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

  // ============================================
  // CARTE COMMANDE
  // ============================================

  Widget _buildOrderCard(dynamic order, AdminOrderProvider provider) {
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
          // LIGNE 1 : Numéro + Statut + Total
          // ============================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber ?? 'Commande',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      order.formattedDate ?? '',
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
              Text(
                order.formattedTotal ?? '0 FCFA',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================
          // LIGNE 2 : Badges
          // ============================================
          Row(
            children: [
              _buildPaymentBadge(order.paymentStatus),
              const SizedBox(width: 8),
              _buildStatusBadge(order.status),
            ],
          ),

          const SizedBox(height: 10),

          // Séparateur
          Container(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 3 : Actions contextuelles
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                label: 'Voir',
                icon: Icons.visibility_outlined,
                color: AppColors.info,
                onTap: () => _navigateToDetail(order),
              ),
              if (order.status == 'pending') ...[
                const SizedBox(width: 8),
                _buildActionButton(
                  label: 'Confirmer',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onTap: () => provider.confirmOrder(order.id),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  label: 'Annuler',
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  onTap: () => _confirmCancelOrder(provider, order),
                ),
              ],
            ],
          ),
        ],
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
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
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
  // BADGES
  // ============================================

  /// Badge de paiement.
  Widget _buildPaymentBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'paid':
        bgColor = AppColors.successLight;
        textColor = AppColors.successDark;
        label = 'Payé';
        break;
      case 'failed':
        bgColor = AppColors.errorLight;
        textColor = AppColors.errorDark;
        label = 'Échoué';
        break;
      case 'refunded':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF6B21A8);
        label = 'Remboursé';
        break;
      default:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warningDark;
        label = 'En attente';
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

  /// Badge de statut.
  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'confirmed':
        bgColor = AppColors.statusConfirmedBg;
        textColor = AppColors.statusConfirmedText;
        label = 'Confirmée';
        break;
      case 'processing':
        bgColor = AppColors.warningLight;
        textColor = AppColors.warningDark;
        label = 'Traitement';
        break;
      case 'shipped':
        bgColor = AppColors.infoLight;
        textColor = AppColors.infoDark;
        label = 'Expédiée';
        break;
      case 'delivered':
        bgColor = AppColors.statusDeliveredBg;
        textColor = AppColors.statusDeliveredText;
        label = 'Livrée';
        break;
      case 'cancelled':
        bgColor = AppColors.statusCancelledBg;
        textColor = AppColors.statusCancelledText;
        label = 'Annulée';
        break;
      default:
        bgColor = AppColors.statusPendingBg;
        textColor = AppColors.statusPendingText;
        label = 'En attente';
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

  // ============================================
  // PAGINATION
  // ============================================

  Widget _buildPagination(AdminOrderProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1 ? provider.loadOrders : null,
            icon: const Icon(Icons.chevron_left, size: 20),
          ),
          Text(
            'Page ${provider.currentPage}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: provider.hasMore ? provider.loadMoreOrders : null,
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  // ============================================
  // NAVIGATION ET ACTIONS
  // ============================================

  void _navigateToDetail(dynamic order) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminOrderDetail,
      arguments: {'order_id': order.id},
    );
  }

  Future<void> _confirmCancelOrder(AdminOrderProvider provider, dynamic order) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Annuler cette commande ?',
      message: 'Cette action est irréversible.',
      type: AdminDialogType.danger,
      confirmLabel: 'Annuler la commande',
    );

    if (result == true) {
      await provider.cancelOrder(order.id);
    }
  }
}