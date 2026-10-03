// ============================================
// PAGE : AdminOrderDetailScreen (MOBILE SENIOR)
// ============================================
// Écran de détail d'une commande - Admin.
//
// Approche MOBILE-FIRST :
// - AppBar native avec actions
// - Hero status banner en haut
// - Sections expandables (accordéon)
// - Bottom action sheet pour les actions
// - Pull-to-refresh
// - Animations subtiles
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../providers/admin_order_provider.dart';
import '../widgets/admin_confirm_dialog.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() =>
      _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetail();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetail() async {
    final provider = context.read<AdminOrderProvider>();
    await provider.loadOrderDetail(widget.orderId);
    if (mounted) {
      _entryController.forward();
    }
  }

  Future<void> _reload() async {
    final provider = context.read<AdminOrderProvider>();
    await provider.loadOrderDetail(widget.orderId);
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminOrderProvider>(
      builder: (context, provider, _) {
        final order = provider.currentOrder;

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: _buildAppBar(provider, order),
          body: _buildBody(provider, order),
          bottomNavigationBar: order != null
              ? _buildBottomActions(provider, order)
              : null,
        );
      },
    );
  }

  // ============================================
  // APPBAR NATIVE
  // ============================================

  PreferredSizeWidget _buildAppBar(
    AdminOrderProvider provider,
    Order? order,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commande',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (order != null)
            Text(
              order.orderNumber,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
          },
        ),
        IconButton(
          tooltip: 'Rafraîchir',
          icon: provider.isUpdating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(
                  Icons.refresh,
                  color: AppColors.textPrimary,
                ),
          onPressed: provider.isUpdating ? null : _reload,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody(AdminOrderProvider provider, Order? order) {
    if (provider.isLoadingDetail && order == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.hasError && order == null) {
      return _buildErrorState(provider.errorMessage);
    }

    if (order == null) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _reload,
      color: AppColors.primary,
      child: FadeTransition(
        opacity: _fadeIn,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildHeroBanner(order),
            const SizedBox(height: 16),
            _buildQuickStats(order),
            const SizedBox(height: 12),
            _buildItemsAccordion(order),
            const SizedBox(height: 12),
            _buildTimelineAccordion(provider, order),
            const SizedBox(height: 12),
            _buildCustomerAccordion(order),
            const SizedBox(height: 12),
            _buildShippingAccordion(order),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HERO BANNER (statut + total)
  // ============================================

  Widget _buildHeroBanner(Order order) {
    final info = _getStatusInfo(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            info['color']!.withValues(alpha: 0.12),
            info['color']!.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: info['color']!.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: info['color']!.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  info['icon'] as IconData,
                  color: info['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: info['color'],
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.formattedFullDate,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Colors.white54),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildHeroStat(
                'Articles',
                '${order.totalItems}',
                Icons.shopping_bag_outlined,
              ),
              const SizedBox(width: 12),
              _buildHeroStat(
                'Total',
                order.formattedTotal,
                Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
  // QUICK STATS (paiement + livraison)
  // ============================================

  Widget _buildQuickStats(Order order) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatTile(
            icon: order.isPaid ? Icons.check_circle : Icons.pending_outlined,
            label: 'Paiement',
            value: order.paymentStatusLabel,
            color: order.isPaid ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickStatTile(
            icon: Icons.local_shipping_outlined,
            label: 'Livraison',
            value: order.shippingMethod ?? 'Standard',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
  // ACCORDÉON : ARTICLES
  // ============================================

  Widget _buildItemsAccordion(Order order) {
    return _buildAccordion(
      title: 'Articles',
      count: order.totalItems,
      icon: Icons.shopping_bag_outlined,
      color: AppColors.primary,
      initiallyExpanded: true,
      child: Column(
        children: [
          if (order.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Aucun article',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            )
          else
            ...order.items.asMap().entries.map((entry) {
              final isLast = entry.key == order.items.length - 1;
              return Column(
                children: [
                  _buildOrderItemTile(entry.value),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      color: AppColors.borderColor,
                      indent: 62,
                    ),
                ],
              );
            }),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 14),
          _buildAmountRow('Sous-total', order.formattedSubtotal),
          if (order.discount > 0 || order.couponDiscount > 0) ...[
            const SizedBox(height: 6),
            _buildAmountRow(
              'Remise',
              '- ${order.formattedDiscount}',
              isGreen: true,
            ),
          ],
          const SizedBox(height: 6),
          _buildAmountRow(
            'Livraison',
            order.formattedShippingFee,
            isGreen: order.shippingFee == 0,
          ),
          if (order.tax > 0) ...[
            const SizedBox(height: 6),
            _buildAmountRow('Taxes', order.formattedTax),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 10),
          _buildAmountRow('TOTAL', order.formattedTotal, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.surfaceAlt,
              child: item.productImage != null && item.productImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.productImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image_outlined,
                        size: 22,
                        color: AppColors.textLight,
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      size: 22,
                      color: AppColors.textTertiary,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.hasVariant) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variantLabel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.quantity} × ${item.formattedPrice}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.formattedSubtotal,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isTotal ? 15 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isGreen
                  ? AppColors.success
                  : isTotal
                      ? AppColors.primary
                      : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // ACCORDÉON : TIMELINE
  // ============================================

  Widget _buildTimelineAccordion(
    AdminOrderProvider provider,
    Order order,
  ) {
    final timeline = _buildTimelineSteps(provider, order);

    return _buildAccordion(
      title: 'Suivi',
      count: timeline.length,
      icon: Icons.timeline_outlined,
      color: AppColors.info,
      child: Column(
        children: List.generate(
          timeline.length,
          (index) => _buildTimelineItem(
            icon: timeline[index]['icon'] as IconData,
            label: timeline[index]['label'] as String,
            date: timeline[index]['date'] as String,
            status: timeline[index]['status'] as String,
            isLast: index == timeline.length - 1,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimelineSteps(
    AdminOrderProvider provider,
    Order order,
  ) {
    final steps = <Map<String, dynamic>>[];

    steps.add({
      'icon': Icons.receipt_long_outlined,
      'label': 'Commande passée',
      'date': order.formattedFullDate,
      'status': 'done',
    });

    final reachedStatuses = <String>{};
    for (final entry in provider.currentOrderHistory) {
      final newStatus = entry['new_status']?.toString();
      if (newStatus != null) reachedStatuses.add(newStatus);
    }
    reachedStatuses.add(order.status);

    final statusFlow = ['confirmed', 'processing', 'shipped', 'delivered'];
    final statusLabels = {
      'confirmed': 'Confirmée',
      'processing': 'En préparation',
      'shipped': 'Expédiée',
      'delivered': 'Livrée',
    };
    final statusIcons = {
      'confirmed': Icons.check_circle_outline,
      'processing': Icons.settings_outlined,
      'shipped': Icons.local_shipping_outlined,
      'delivered': Icons.home_outlined,
    };

    for (final status in statusFlow) {
      final reached = reachedStatuses.contains(status);
      final isCurrent = order.status == status;

      steps.add({
        'icon': statusIcons[status],
        'label': statusLabels[status],
        'date': reached ? 'Effectué' : 'À venir',
        'status': reached ? (isCurrent ? 'current' : 'done') : 'pending',
      });
    }

    if (['cancelled', 'returned', 'refunded'].contains(order.status)) {
      final specialLabels = {
        'cancelled': 'Annulée',
        'returned': 'Retournée',
        'refunded': 'Remboursée',
      };
      final specialIcons = {
        'cancelled': Icons.cancel_outlined,
        'returned': Icons.assignment_return_outlined,
        'refunded': Icons.money_off_outlined,
      };
      steps.add({
        'icon': specialIcons[order.status] ?? Icons.info_outline,
        'label': specialLabels[order.status] ?? 'Statut',
        'date': order.formattedFullDate,
        'status': 'current',
      });
    }

    return steps;
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String date,
    required String status,
    required bool isLast,
  }) {
    Color color;
    switch (status) {
      case 'done':
        color = AppColors.success;
        break;
      case 'current':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.textLight;
    }

    final isActive = status == 'done' || status == 'current';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive
                      ? color.withValues(alpha: 0.15)
                      : AppColors.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? color : AppColors.borderColor,
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: status == 'done'
                        ? AppColors.success
                        : AppColors.borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACCORDÉON : CLIENT
  // ============================================

  Widget _buildCustomerAccordion(Order order) {
  final user = order.user;

  return _buildAccordion(
    title: 'Client',
    icon: Icons.person_outline,
    color: AppColors.success,
    child: user == null
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: AppColors.textLight),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Informations client non disponibles.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user.name.isNotEmpty)
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Nom',
                  value: user.name,
                ),
              if (user.email.isNotEmpty)
                _buildDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
              if (user.phone != null && user.phone!.isNotEmpty)
                _buildDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Téléphone',
                  value: user.phone!,
                ),
              if (user.id > 0)
                _buildDetailRow(
                  icon: Icons.tag,
                  label: 'ID client',
                  value: '#${user.id}',
                ),
            ],
          ),
  );
}

  // ============================================
  // ACCORDÉON : LIVRAISON
  // ============================================

  Widget _buildShippingAccordion(Order order) {
  final address = order.shippingAddress;

  return _buildAccordion(
    title: 'Livraison',
    icon: Icons.location_on_outlined,
    color: AppColors.warning,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Adresse de livraison
        if (address == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: AppColors.textLight),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Adresse de livraison non disponible.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          if (address.fullName.isNotEmpty)
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Destinataire',
              value: address.fullName,
            ),
          if (address.phone != null && address.phone!.isNotEmpty)
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: address.phone!,
            ),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value: address.fullAddress,
          ),
        ],

        const SizedBox(height: 12),

        // ✅ Mode de livraison
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                size: 14,
                color: AppColors.info,
              ),
              const SizedBox(width: 6),
              Text(
                (order.shippingMethod ?? 'Standard').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ),

        // ✅ Numéro de suivi (si disponible)
        if (order.trackingNumber != null &&
            order.trackingNumber!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'N° de suivi',
            value: order.trackingNumber!,
          ),
        ],
      ],
    ),
  );
}


/// Ligne d'information (icône + label + valeur).
Widget _buildDetailRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
  // WIDGET ACCORDÉON GÉNÉRIQUE
  // ============================================

  Widget _buildAccordion({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    int? count,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            title: Row(
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
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            iconColor: color,
            collapsedIconColor: AppColors.textTertiary,
            children: [child],
          ),
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM ACTIONS BAR
  // ============================================

  Widget? _buildBottomActions(AdminOrderProvider provider, Order order) {
    final actions = _getAvailableActions(order);
    if (actions.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Action principale (première)
            if (actions.isNotEmpty)
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: provider.isUpdating
                      ? null
                      : () => _executeAction(
                            provider,
                            actions.first['type'] as String,
                            order,
                          ),
                  icon: provider.isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          actions.first['icon'] as IconData,
                          size: 18,
                        ),
                  label: Text(
                    actions.first['shortLabel'] as String? ??
                        actions.first['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actions.first['color'] as Color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

            // Autres actions → bottom sheet
            if (actions.length > 1) ...[
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  tooltip: 'Plus d\'actions',
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: provider.isUpdating
                      ? null
                      : () => _showActionsSheet(
                            provider,
                            order,
                            actions.sublist(1),
                          ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showActionsSheet(
    AdminOrderProvider provider,
    Order order,
    List<Map<String, dynamic>> actions,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Actions disponibles',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...actions.map(
                (action) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _executeAction(
                      provider,
                      action['type'] as String,
                      order,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS DISPONIBLES
  // ============================================

  List<Map<String, dynamic>> _getAvailableActions(Order order) {
    final actions = <Map<String, dynamic>>[];

    switch (order.status) {
      case 'pending':
        actions.add({
          'type': 'confirm',
          'label': 'Confirmer la commande',
          'shortLabel': 'Confirmer',
          'icon': Icons.check_circle_outline,
          'color': AppColors.success,
        });
        actions.add({
          'type': 'cancel',
          'label': 'Annuler la commande',
          'shortLabel': 'Annuler',
          'icon': Icons.cancel_outlined,
          'color': AppColors.error,
        });
        break;
      case 'confirmed':
        actions.add({
          'type': 'process',
          'label': 'Mettre en préparation',
          'shortLabel': 'Préparer',
          'icon': Icons.settings_outlined,
          'color': AppColors.info,
        });
        actions.add({
          'type': 'cancel',
          'label': 'Annuler la commande',
          'shortLabel': 'Annuler',
          'icon': Icons.cancel_outlined,
          'color': AppColors.error,
        });
        break;
      case 'processing':
        actions.add({
          'type': 'ship',
          'label': 'Marquer comme expédiée',
          'shortLabel': 'Expédier',
          'icon': Icons.local_shipping_outlined,
          'color': AppColors.info,
        });
        break;
      case 'shipped':
        actions.add({
          'type': 'deliver',
          'label': 'Marquer comme livrée',
          'shortLabel': 'Livrer',
          'icon': Icons.home_outlined,
          'color': AppColors.primary,
        });
        break;
      case 'delivered':
        actions.add({
          'type': 'return',
          'label': 'Retourner la commande',
          'shortLabel': 'Retourner',
          'icon': Icons.assignment_return_outlined,
          'color': AppColors.warning,
        });
        break;
    }

    return actions;
  }

  // ============================================
  // EXÉCUTION
  // ============================================

  Future<void> _executeAction(
    AdminOrderProvider provider,
    String type,
    Order order,
  ) async {
    final confirmed = await _confirmAction(type);
    if (confirmed != true) return;
    if (!mounted) return;

    bool success = false;
    String successMessage = '';
    String errorMessage = '';

    switch (type) {
      case 'confirm':
        success = await provider.confirmOrder(order.id);
        successMessage = 'Commande confirmée';
        errorMessage = 'Impossible de confirmer';
        break;
      case 'process':
        success = await provider.processOrder(order.id);
        successMessage = 'Commande en préparation';
        errorMessage = 'Impossible de préparer';
        break;
      case 'ship':
        success = await provider.shipOrder(order.id);
        successMessage = 'Commande expédiée';
        errorMessage = 'Impossible d\'expédier';
        break;
      case 'deliver':
        success = await provider.deliverOrder(order.id);
        successMessage = 'Commande livrée';
        errorMessage = 'Impossible de livrer';
        break;
      case 'cancel':
        success = await provider.cancelOrder(order.id);
        successMessage = 'Commande annulée';
        errorMessage = 'Impossible d\'annuler';
        break;
      case 'return':
        success = await provider.returnOrder(order.id);
        successMessage = 'Commande retournée';
        errorMessage = 'Impossible de retourner';
        break;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMessage : errorMessage,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Future<bool?> _confirmAction(String type) async {
    String title;
    String message;
    AdminDialogType dialogType;
    String confirmLabel;

    switch (type) {
      case 'confirm':
        title = 'Confirmer cette commande ?';
        message = 'La commande sera marquée comme confirmée.';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'Confirmer';
        break;
      case 'process':
        title = 'Mettre en préparation ?';
        message = 'La commande passera en statut "En préparation".';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'En préparation';
        break;
      case 'ship':
        title = 'Expédier cette commande ?';
        message = 'La commande sera marquée comme expédiée.';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'Expédier';
        break;
      case 'deliver':
        title = 'Marquer comme livrée ?';
        message = 'La commande sera marquée comme livrée.';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'Livrer';
        break;
      case 'cancel':
        title = 'Annuler cette commande ?';
        message = 'Cette action est irréversible.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Annuler';
        break;
      case 'return':
        title = 'Retourner cette commande ?';
        message = 'La commande sera marquée comme retournée.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Retourner';
        break;
      default:
        return false;
    }

    return await AdminConfirmDialog.show(
      context: context,
      title: title,
      message: message,
      type: dialogType,
      confirmLabel: confirmLabel,
    );
  }

  // ============================================
  // ÉTATS ALTERNATIFS
  // ============================================

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Impossible de charger la commande.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'RÉESSAYER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Commande introuvable',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': 'En attente',
          'color': AppColors.warning,
          'icon': Icons.hourglass_empty,
        };
      case 'confirmed':
        return {
          'label': 'Confirmée',
          'color': AppColors.info,
          'icon': Icons.check_circle_outline,
        };
      case 'processing':
        return {
          'label': 'En préparation',
          'color': AppColors.info,
          'icon': Icons.settings_outlined,
        };
      case 'shipped':
        return {
          'label': 'Expédiée',
          'color': AppColors.primary,
          'icon': Icons.local_shipping_outlined,
        };
      case 'delivered':
        return {
          'label': 'Livrée',
          'color': AppColors.success,
          'icon': Icons.home_outlined,
        };
      case 'cancelled':
        return {
          'label': 'Annulée',
          'color': AppColors.error,
          'icon': Icons.cancel_outlined,
        };
      case 'returned':
        return {
          'label': 'Retournée',
          'color': AppColors.warning,
          'icon': Icons.assignment_return_outlined,
        };
      case 'refunded':
        return {
          'label': 'Remboursée',
          'color': AppColors.info,
          'icon': Icons.money_off_outlined,
        };
      default:
        return {
          'label': status,
          'color': AppColors.textSecondary,
          'icon': Icons.info_outline,
        };
    }
  }
}