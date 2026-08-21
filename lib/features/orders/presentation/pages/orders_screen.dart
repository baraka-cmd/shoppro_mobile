// Écran de l'historique des commandes
// Affiche la liste des commandes avec filtres par statut

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
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
    _loadOrders();
  }

  // Charger les commandes
  Future<void> _loadOrders() async {
    final provider = context.read<OrderProvider>();
    await provider.loadOrders();
  }

  // Filtrer les commandes
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              // Chips de filtres
              _buildFilterChips(provider),

              const SizedBox(height: 10),

              // Liste des commandes
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
                                    '/order/detail',
                                    arguments: {'order_id': order.id},
                                  );
                                },
                                onTrack: () {
                                  Navigator.of(context).pushNamed(
                                    '/order/detail',
                                    arguments: {'order_id': order.id},
                                  );
                                },
                                onCancel: () {
                                  _showCancelDialog(provider, order.id);
                                },
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

  // Chips de filtres
  Widget _buildFilterChips(OrderProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
            count: provider.activeOrders.length,
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
            count: provider.deliveredOrders.length,
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
            count: provider.cancelledOrders.length,
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

  // Chip de filtre
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
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
                      : AppColors.background,
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

  // Dialog d'annulation
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
            'Cette action est irréversible.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
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
                await provider.cancelOrder(orderId, 'Annulation par le client');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
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