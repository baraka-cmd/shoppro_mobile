// ============================================
// ÉCRAN DE L'HISTORIQUE DES COMMANDES - PREMIUM
// ============================================
// Affiche la liste des commandes avec filtres
// par statut et actions rapides. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../providers/order_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/empty_orders.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadOrders() async {
    final provider = context.read<OrderProvider>();
    await provider.loadOrders();
  }

  // ============================================
  // FILTRAGE
  // ============================================

  List<dynamic> _getFilteredOrders(OrderProvider provider) {
    switch (_selectedFilter) {
      case 'active':
        return provider.activeOrders;
      case 'delivered':
        return provider.deliveredOrders;
      case 'cancelled':
        return provider.cancelledOrders;
      default:
        return provider.orders;
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty
                  ? 'Mes Commandes'
                  : 'Mes Commandes (${provider.ordersCount})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return EmptyOrders(
              onExplore: () {
                Navigator.of(context).pop();
              },
            );
          }

          final filteredOrders = _getFilteredOrders(provider);

          return Column(
            children: [
              // ============================================
              // CHIPS DE FILTRES
              // ============================================
              _buildFilterChips(provider),

              const SizedBox(height: 10),

              // ============================================
              // LISTE DES COMMANDES
              // ============================================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: AppColors.primary,
                  child: filteredOrders.isEmpty
                      ? EmptyOrders(
                          onExplore: () {
                            Navigator.of(context).pop();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderCard(
                                order: order,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.orderDetail,
                                    arguments: {'order_id': order.id},
                                  );
                                },
                                onTrack: () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.orderDetail,
                                    arguments: {'order_id': order.id},
                                  );
                                },
                                onCancel: order.canCancel
                                    ? () => _showCancelDialog(provider, order.id)
                                    : null,
                                onReorder: order.canReorder
                                    ? () => _handleReorder(provider, order.id)
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // CHIPS DE FILTRES
  // ============================================

  Widget _buildFilterChips(OrderProvider provider) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        children: [
          _buildChip(
            label: 'Toutes',
            count: provider.ordersCount,
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'En cours',
            count: provider.activeOrdersCount,
            isSelected: _selectedFilter == 'active',
            color: AppColors.warning,
            onTap: () {
              setState(() {
                _selectedFilter = 'active';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Livrées',
            count: provider.deliveredOrdersCount,
            isSelected: _selectedFilter == 'delivered',
            color: AppColors.success,
            onTap: () {
              setState(() {
                _selectedFilter = 'delivered';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Annulées',
            count: provider.cancelledOrdersCount,
            isSelected: _selectedFilter == 'cancelled',
            color: AppColors.error,
            onTap: () {
              setState(() {
                _selectedFilter = 'cancelled';
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHIP DE FILTRE
  // ============================================

  Widget _buildChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
  // RÉPÉTER UNE COMMANDE
  // ============================================

  Future<void> _handleReorder(OrderProvider provider, int orderId) async {
    final order = provider.getOrderById(orderId);
    if (order == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Commande ${order.orderNumber} répétée ! (Fonctionnalité à venir)',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  // ============================================
  // DIALOG D'ANNULATION
  // ============================================

  void _showCancelDialog(OrderProvider provider, int orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Annuler la commande ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Cette action est irréversible. Vous pourrez commander à nouveau plus tard.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Retour',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await provider.cancelOrder(
                  orderId,
                  'Annulation par le client',
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Commande annulée',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      ),
                      backgroundColor: AppColors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      action: SnackBarAction(
                        label: 'ANNULER',
                        textColor: AppColors.error,
                        onPressed: () {
                          provider.undoLastAction();
                        },
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}