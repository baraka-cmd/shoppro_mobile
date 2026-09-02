// ============================================
// PAGE : AdminNotificationsScreen
// ============================================
// Écran des notifications système - Design mobile.
// Liste verticale avec filtres et actions compactes.
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
import '../providers/admin_notification_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran des notifications système mobile.
///
/// Affiche :
/// - Statistiques rapides (total, non lues)
/// - Filtres par statut
/// - Liste des notifications en cartes
/// - Actions (marquer lu, archiver, supprimer)
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNotificationProvider>().loadNotifications();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Notifications',
      subtitle: 'Alertes système',
      currentRoute: AppRoutes.adminNotifications,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {},
      onLogout: () {},
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminNotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 8,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadNotifications,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // STATISTIQUES + ACTIONS
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  _buildCompactStat(
                    label: 'Total',
                    value: provider.totalCount,
                    color: AppColors.info,
                  ),
                  _buildCompactStat(
                    label: 'Non lues',
                    value: provider.unreadCount,
                    color: AppColors.warning,
                  ),
                  _buildCompactStat(
                    label: 'Lues',
                    value: provider.readCount,
                    color: AppColors.success,
                  ),
                  if (provider.hasUnread)
                    InkWell(
                      onTap: () => provider.markAllAsRead(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.done_all, size: 13, color: AppColors.info),
                            SizedBox(width: 4),
                            Text(
                              'Tout lu',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ============================================
            // FILTRES
            // ============================================
            _buildFilters(provider),

            const SizedBox(height: 6),

            // ============================================
            // LISTE DES NOTIFICATIONS
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.notifications_none,
                      title: 'Aucune notification',
                      message: 'Les notifications apparaîtront ici.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = provider.notifications[index];
                        return _buildNotificationCard(notification, provider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Statistique compacte.
  Widget _buildCompactStat({
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
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
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTRES
  // ============================================

  Widget _buildFilters(AdminNotificationProvider provider) {
    return Container(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildFilterChip(
            label: 'Non lues',
            icon: Icons.mark_email_unread_outlined,
            isActive: provider.filterIsRead == false,
            onTap: () => provider.filterByReadStatus(false),
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: 'Lues',
            icon: Icons.done_all,
            isActive: provider.filterIsRead == true,
            onTap: () => provider.filterByReadStatus(true),
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: 'Archivées',
            icon: Icons.archive_outlined,
            isActive: provider.filterIsArchived == true,
            onTap: () => provider.filterByArchivedStatus(true),
          ),
          const SizedBox(width: 6),
          if (provider.filterIsRead != null || provider.filterIsArchived != null)
            _buildFilterChip(
              label: 'Effacer',
              icon: Icons.close,
              isActive: false,
              onTap: () => provider.clearFilters(),
            ),
        ],
      ),
    );
  }

  /// Chip de filtre.
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primary : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: isActive ? Colors.white : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
  // CARTE NOTIFICATION
  // ============================================

  Widget _buildNotificationCard(dynamic notification, AdminNotificationProvider provider) {
    final isUnread = notification.isRead == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.infoLight.withValues(alpha: 0.3) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.softShadow,
        border: isUnread
            ? Border.all(color: AppColors.info.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // LIGNE 1 : Icône + Titre + Temps
          // ============================================
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification),
                  size: 18,
                  color: _getNotificationColor(notification),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? 'Notification',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      notification.timeAgo ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.info,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 2 : Corps
          // ============================================
          Text(
            notification.body ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Séparateur
          Container(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 6),

          // ============================================
          // LIGNE 3 : Actions compactes
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUnread)
                _buildSmallAction(
                  label: 'Lu',
                  icon: Icons.done,
                  color: AppColors.success,
                  onTap: () => provider.markAsRead(notification.id),
                ),
              if (notification.isArchived == false) ...[
                const SizedBox(width: 6),
                _buildSmallAction(
                  label: 'Archiver',
                  icon: Icons.archive_outlined,
                  color: AppColors.textTertiary,
                  onTap: () => provider.archiveNotification(notification.id),
                ),
              ],
              const SizedBox(width: 6),
              _buildSmallAction(
                label: '',
                icon: Icons.delete_outline,
                color: AppColors.error,
                onTap: () => provider.deleteNotification(notification.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Petit bouton d'action.
  Widget _buildSmallAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================
  // ICÔNES ET COULEURS PAR TYPE
  // ============================================

  IconData _getNotificationIcon(dynamic notification) {
    final type = notification.type?.code ?? '';
    switch (type) {
      case 'new_order':
        return Icons.receipt_long_outlined;
      case 'low_stock':
        return Icons.warning_amber_rounded;
      case 'out_of_stock':
        return Icons.cancel_outlined;
      case 'new_review':
        return Icons.star_outline;
      case 'new_user':
        return Icons.person_add_outlined;
      case 'payment_received':
        return Icons.payments_outlined;
      case 'payment_failed':
        return Icons.error_outline;
      case 'order_cancelled':
        return Icons.cancel_outlined;
      case 'system':
        return Icons.settings_outlined;
      case 'security':
        return Icons.security_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(dynamic notification) {
    final type = notification.type?.code ?? '';
    switch (type) {
      case 'new_order':
        return AppColors.info;
      case 'low_stock':
        return AppColors.warning;
      case 'out_of_stock':
        return AppColors.error;
      case 'new_review':
        return AppColors.success;
      case 'new_user':
        return const Color(0xFF8B5CF6);
      case 'payment_received':
        return AppColors.success;
      case 'payment_failed':
        return AppColors.error;
      case 'order_cancelled':
        return AppColors.error;
      case 'system':
        return AppColors.textTertiary;
      case 'security':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}