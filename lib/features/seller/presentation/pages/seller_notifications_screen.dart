// ============================================
// PAGE : SellerNotificationsScreen
// ============================================
// Écran des notifications vendeur.
//
// Structure :
//   - AppBar avec bouton "Tout marquer comme lu"
//   - Filtres pills (Toutes / Non lues / Lues)
//   - Liste des notifications avec icônes colorées
//   - Actions : tap pour marquer lu, swipe pour supprimer
//   - Badge non lues
//
// UX :
//   - Skeleton loading
//   - Empty state par filtre
//   - Error state avec retry
//   - Pull-to-refresh
//   - Pagination infinie
//   - Swipe-to-delete
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_notification.dart';

// Presentation
import '../providers/seller_notification_provider.dart';
import '../widgets/seller_scaffold.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerNotificationsScreen extends StatefulWidget {
  const SellerNotificationsScreen({super.key});

  @override
  State<SellerNotificationsScreen> createState() =>
      _SellerNotificationsScreenState();
}

class _SellerNotificationsScreenState extends State<SellerNotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerNotificationProvider>();
      if (provider.listStatus == SellerNotificationListStatus.initial) {
        provider.loadNotifications();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final provider = context.read<SellerNotificationProvider>();
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
      currentIndex: 0,
      title: 'Notifications',
      subtitle: _buildSubtitle(),
      showBackButton: false,
      extraActions: [
        Consumer<SellerNotificationProvider>(
          builder: (context, provider, _) {
            if (provider.unreadCount == 0) return const SizedBox.shrink();

            return IconButton(
              icon: const Icon(
                Icons.done_all_rounded,
                size: 22,
                color: AppColors.textPrimary,
              ),
              onPressed: () => _handleMarkAllRead(provider),
              tooltip: 'Tout marquer comme lu',
            );
          },
        ),
      ],
      child: Consumer<SellerNotificationProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildFiltersBar(provider),

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
    final provider = context.watch<SellerNotificationProvider>();
    if (provider.hasUnread) {
      return '${provider.unreadCount} non lue${provider.unreadCount > 1 ? 's' : ''}';
    }
    return '${provider.totalCount} notification${provider.totalCount > 1 ? 's' : ''}';
  }

  // ============================================
  // FILTRES
  // ============================================

  Widget _buildFiltersBar(SellerNotificationProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: SellerNotificationFilter.values.map((filter) {
            final isActive = provider.filter == filter;

            final count = switch (filter) {
              SellerNotificationFilter.all => provider.totalCount,
              SellerNotificationFilter.unread => provider.unreadCount,
              SellerNotificationFilter.read => provider.readCount,
            };

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.warning : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
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
                              color: isActive
                                  ? Colors.white
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(SellerNotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return _buildSkeleton();
    }

    if (provider.isUnauthorized) {
      return _buildUnauthorizedState();
    }

    if (provider.hasError && provider.notifications.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.notifications.isEmpty) {
      return _buildEmptyState(provider);
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppColors.warning,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount:
            provider.notifications.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.notifications.length) {
            return _buildLoadMoreIndicator();
          }

          final notification = provider.notifications[index];
          return _buildNotificationTile(notification, provider);
        },
      ),
    );
  }

  // ============================================
  // TUILES DE NOTIFICATION
  // ============================================

  Widget _buildNotificationTile(
    SellerNotification notification,
    SellerNotificationProvider provider,
  ) {
    final color = Color(notification.colorHex);
    final isProcessing = provider.lastAffectedId == notification.id &&
        provider.isPerformingAction;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _handleDelete(provider, notification),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(notification, provider),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: notification.isUnread
                    ? color.withValues(alpha: 0.04)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: notification.isUnread
                      ? color.withValues(alpha: 0.3)
                      : AppColors.borderColor.withValues(alpha: 0.5),
                  width: notification.isUnread ? 1.2 : 1,
                ),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIcon(notification.icon),
                      size: 20,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Contenu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: notification.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (notification.isUnread) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // Type label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                notification.typeLabel,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Date
                            Icon(
                              Icons.access_time_rounded,
                              size: 10,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                notification.createdAtHuman ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Loader / Chevron
                  if (isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.warning,
                        ),
                      ),
                    )
                  else if (notification.actionUrl != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // ICÔNES
  // ============================================

  IconData _getIcon(String iconName) {
    return switch (iconName) {
      'shopping_bag' => Icons.shopping_bag_outlined,
      'rate_review' => Icons.rate_review_outlined,
      'inventory_2' => Icons.inventory_2_outlined,
      'payments' => Icons.payments_outlined,
      'verified_user' => Icons.verified_user_outlined,
      'gpp_bad' => Icons.gpp_bad_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  // ============================================
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

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

  Widget _buildEmptyState(SellerNotificationProvider provider) {
    final filter = provider.filter;

    final IconData icon;
    final String title;
    final String subtitle;

    switch (filter) {
      case SellerNotificationFilter.all:
        icon = Icons.notifications_none_rounded;
        title = 'Aucune notification';
        subtitle = 'Vous recevrez vos notifications ici.';
        break;
      case SellerNotificationFilter.unread:
        icon = Icons.check_circle_outline_rounded;
        title = 'Tout est lu !';
        subtitle = 'Vous n\'avez aucune notification non lue.';
        break;
      case SellerNotificationFilter.read:
        icon = Icons.mark_email_unread_outlined;
        title = 'Aucune notification lue';
        subtitle = 'Les notifications lues apparaîtront ici.';
        break;
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

  Widget _buildErrorState(SellerNotificationProvider provider) {
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
              onPressed: () => provider.loadNotifications(forceRefresh: true),
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

  Future<void> _handleTap(
    SellerNotification notification,
    SellerNotificationProvider provider,
  ) async {
    // Marquer comme lue
    if (notification.isUnread) {
      await provider.markAsRead(notification.id);
    }

    if (!mounted) return;

    // Naviguer vers l'action si disponible
    if (notification.actionUrl != null) {
      _handleAction(notification);
    }
  }

  void _handleAction(SellerNotification notification) {
    final url = notification.actionUrl!;

    // Mapper les URLs vers les routes Flutter
    if (url.contains('/orders')) {
      Navigator.of(context).pushNamed(AppRoutes.sellerOrders);
    } else if (url.contains('/reviews')) {
      Navigator.of(context).pushNamed(AppRoutes.sellerReviews);
    } else if (url.contains('/stocks')) {
      Navigator.of(context).pushNamed(AppRoutes.sellerStocks);
    } else if (url.contains('/payouts')) {
      Navigator.of(context).pushNamed(AppRoutes.sellerPayouts);
    } else if (url.contains('/profile')) {
      Navigator.of(context).pushNamed(AppRoutes.sellerProfile);
    }
  }

  Future<void> _handleMarkAllRead(
    SellerNotificationProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Tout marquer comme lu ?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${provider.unreadCount} notification(s) seront marquées comme lues.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Confirmer',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await provider.markAllAsRead();

    if (!mounted) return;

    if (success) {
      _showSuccess('Notifications marquées comme lues');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  Future<void> _handleDelete(
    SellerNotificationProvider provider,
    SellerNotification notification,
  ) async {
    final success = await provider.deleteNotification(notification.id);

    if (!mounted) return;

    if (success) {
      _showSuccess('Notification supprimée');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  // ============================================
  // HELPERS UI
  // ============================================

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}