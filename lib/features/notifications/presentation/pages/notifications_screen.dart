// Écran des notifications
// Affiche la liste des notifications avec filtres

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';
import '../widgets/empty_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Charger les notifications
  Future<void> _loadNotifications() async {
    final provider = context.read<NotificationProvider>();
    await provider.loadNotifications();
  }

  // Filtrer les notifications
  List<dynamic> _getFilteredNotifications(NotificationProvider provider) {
    switch (_selectedFilter) {
      case 'order':
        return provider.getOrderNotifications();
      case 'promotion':
        return provider.getPromotionNotifications();
      case 'delivery':
        return provider.getDeliveryNotifications();
      case 'price_alert':
        return provider.getPriceAlertNotifications();
      default:
        return provider.notifications;
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
        title: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty
                  ? 'Notifications'
                  : 'Notifications (${provider.unreadCount})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty || provider.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () => provider.markAllAsRead(),
                icon: const Icon(
                  Icons.done_all,
                  color: AppColors.primary,
                  size: 22,
                ),
              );
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearDialog(provider),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return const EmptyNotifications();
          }

          final filteredNotifications = _getFilteredNotifications(provider);

          return Column(
            children: [
              // Chips de filtres
              _buildFilterChips(provider),

              const SizedBox(height: 10),

              // Liste des notifications
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: AppColors.primary,
                  child: filteredNotifications.isEmpty
                      ? const EmptyNotifications()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: NotificationCard(
                                notification: notification,
                                onTap: () {
                                  if (!notification.isRead) {
                                    provider.markAsRead(notification.id);
                                  }
                                },
                                onDelete: () {
                                  provider.removeNotification(notification.id);
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
  Widget _buildFilterChips(NotificationProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip(
            label: 'Toutes',
            count: provider.totalCount,
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Commandes',
            count: provider.getOrderNotifications().length,
            isSelected: _selectedFilter == 'order',
            color: const Color(0xFF3498DB),
            onTap: () {
              setState(() {
                _selectedFilter = 'order';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Promos',
            count: provider.getPromotionNotifications().length,
            isSelected: _selectedFilter == 'promotion',
            color: AppColors.secondary,
            onTap: () {
              setState(() {
                _selectedFilter = 'promotion';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Livraisons',
            count: provider.getDeliveryNotifications().length,
            isSelected: _selectedFilter == 'delivery',
            color: AppColors.success,
            onTap: () {
              setState(() {
                _selectedFilter = 'delivery';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Alertes prix',
            count: provider.getPriceAlertNotifications().length,
            isSelected: _selectedFilter == 'price_alert',
            color: AppColors.error,
            onTap: () {
              setState(() {
                _selectedFilter = 'price_alert';
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

  // Dialog pour tout effacer
  void _showClearDialog(NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tout effacer ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Toutes les notifications seront supprimées.',
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
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await provider.clearAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Effacer',
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