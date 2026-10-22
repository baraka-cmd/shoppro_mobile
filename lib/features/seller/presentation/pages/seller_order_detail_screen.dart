// ============================================
// PAGE : SellerOrderDetailScreen
// ============================================
// Écran de détail d'une commande vendeur.
//
// Structure :
//   - AppBar avec actions dynamiques (accepter, préparer, expédier, annuler)
//   - Header commande (numéro, statut, date)
//   - Timeline de suivi
//   - Carte client + adresse de livraison
//   - Liste des articles du vendeur
//   - Récapitulatif financier (sous-total, commission, net)
//   - Bottom bar sticky avec l'action principale
//
// UX :
//   - Loading skeleton
//   - Error state
//   - BottomSheet pour expédition (tracking)
//   - BottomSheet pour annulation (motif)
//   - Confirmations avant actions critiques
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_order.dart';

// Presentation
import '../providers/seller_order_provider.dart';
import '../widgets/seller_order_timeline.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerOrderProvider>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  void dispose() {
    // Nettoyer l'ordre courant à la sortie
    Future.microtask(() {
      if (mounted) {
        context.read<SellerOrderProvider>().clearCurrentOrder();
      }
    });
    super.dispose();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOrderProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(provider),
          body: _buildBody(provider),
          bottomNavigationBar: _buildBottomBar(provider),
        );
      },
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar(SellerOrderProvider provider) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Détail commande',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (provider.currentOrder != null)
            Text(
              provider.currentOrder!.orderNumber,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
      actions: [
        if (provider.currentOrder != null &&
            provider.currentOrder!.hasItemsToCancel)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 22,
              color: AppColors.textPrimary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.background,
            elevation: 4,
            onSelected: (value) {
              if (value == 'cancel') {
                _handleCancel(provider);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'cancel',
                height: 44,
                child: Row(
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Annuler la commande',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody(SellerOrderProvider provider) {
    if (provider.isLoadingDetail) {
      return _buildSkeleton();
    }

    if (provider.detailError != null || provider.currentOrder == null) {
      return _buildErrorState(provider);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(provider.currentOrder!),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SellerOrderTimeline(order: provider.currentOrder!),
          ),
          const SizedBox(height: 12),
          _buildCustomerCard(provider.currentOrder!),
          const SizedBox(height: 12),
          _buildItemsCard(provider.currentOrder!),
          const SizedBox(height: 12),
          _buildTotalsCard(provider.currentOrder!),
          if (provider.currentOrder!.customerNote != null) ...[
            const SizedBox(height: 12),
            _buildCustomerNoteCard(provider.currentOrder!),
          ],
        ],
      ),
    );
  }

  // ============================================
  // HEADER CARD
  // ============================================

  Widget _buildHeaderCard(SellerOrder order) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.1),
            AppColors.warning.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.createdAtHuman ?? '—',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(order),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildHeaderInfo(
                icon: Icons.payments_outlined,
                label: 'Paiement',
                value: order.paymentStatusLabel,
                color: order.isPaid ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 12),
              _buildHeaderInfo(
                icon: Icons.shopping_bag_outlined,
                label: 'Articles',
                value: '${order.itemsCount}',
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SellerOrder order) {
    Color color;
    Color bgColor;

    switch (order.status) {
      case 'pending':
      case 'confirmed':
        color = AppColors.statusPendingText;
        bgColor = AppColors.statusPendingBg;
        break;
      case 'processing':
        color = AppColors.statusConfirmedText;
        bgColor = AppColors.statusConfirmedBg;
        break;
      case 'shipped':
        color = AppColors.statusConfirmedText;
        bgColor = AppColors.statusConfirmedBg;
        break;
      case 'delivered':
        color = AppColors.statusDeliveredText;
        bgColor = AppColors.statusDeliveredBg;
        break;
      case 'cancelled':
      case 'refunded':
      case 'returned':
        color = AppColors.statusCancelledText;
        bgColor = AppColors.statusCancelledBg;
        break;
      default:
        color = AppColors.statusInactiveText;
        bgColor = AppColors.statusInactiveBg;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ============================================
  // CARTE CLIENT
  // ============================================

  Widget _buildCustomerCard(SellerOrder order) {
    final customer = order.customer;
    final address = order.shippingAddress;

    return _buildSectionCard(
      icon: Icons.person_outline_rounded,
      title: 'Client & Livraison',
      children: [
        if (customer != null) ...[
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.initials,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (customer.hasLocation)
                      Text(
                        customer.formattedLocation,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
        if (address != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 14),
          _buildAddressRow(
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value: address.fullAddress,
          ),
          const SizedBox(height: 10),
          _buildAddressRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: address.phone,
          ),
          if (address.hasDeliveryInstructions) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.deliveryInstructions!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.info,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // CARTE ITEMS
  // ============================================

  Widget _buildItemsCard(SellerOrder order) {
    return _buildSectionCard(
      icon: Icons.shopping_bag_outlined,
      title: 'Articles (${order.itemsCount})',
      children: [
        ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildItemRow(item),
            )),
      ],
    );
  }

  Widget _buildItemRow(SellerOrderItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.hasImage
                ? Image.network(
                    item.productImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_outlined,
                      size: 24,
                      color: AppColors.textTertiary,
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    size: 24,
                    color: AppColors.textTertiary,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.hasVariant)
                Text(
                  item.variantLabel,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${item.quantity} × ${item.unitPriceFormatted}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.totalPriceFormatted,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildItemStatusBadge(item),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemStatusBadge(SellerOrderItem item) {
    final color = _parseHexColor(item.sellerStatusColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        item.sellerStatusLabel,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      final cleaned = hex.replaceFirst('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return AppColors.textTertiary;
    }
  }

  // ============================================
  // CARTE TOTAUX
  // ============================================

  Widget _buildTotalsCard(SellerOrder order) {
    final totals = order.totals;

    return _buildSectionCard(
      icon: Icons.payments_outlined,
      title: 'Récapitulatif',
      children: [
        _buildTotalRow(
          label: 'Sous-total',
          value: totals.subtotalFormatted,
        ),
        const SizedBox(height: 8),
        _buildTotalRow(
          label: 'Commission (${totals.commissionRate.toStringAsFixed(1)}%)',
          value: '-${totals.commissionFormatted}',
          valueColor: AppColors.error,
        ),
        const SizedBox(height: 10),
        const Divider(height: 1, color: AppColors.borderColor),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'Net à percevoir',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              totals.netAmountFormatted,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================
  // CARTE NOTE CLIENT
  // ============================================

  Widget _buildCustomerNoteCard(SellerOrder order) {
    return _buildSectionCard(
      icon: Icons.note_outlined,
      title: 'Note du client',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_quote_rounded,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerNote!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.info,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // SECTION CARD HELPER
  // ============================================

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ============================================
  // BOTTOM BAR (Actions dynamiques)
  // ============================================

  Widget? _buildBottomBar(SellerOrderProvider provider) {
    final order = provider.currentOrder;

    if (order == null) return null;

    // Déterminer l'action principale à afficher
    Widget? primaryAction;
    VoidCallback? onAction;

    if (order.hasItemsToAccept) {
      primaryAction = _buildActionButton(
        label: 'Accepter la commande',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
        isLoading: provider.isAccepting,
        onTap: () => _handleAccept(provider),
      );
    } else if (order.hasItemsToPrepare) {
      primaryAction = _buildActionButton(
        label: 'Passer en préparation',
        icon: Icons.inventory_2_outlined,
        color: AppColors.info,
        isLoading: provider.isPreparing,
        onTap: () => _handlePrepare(provider),
      );
    } else if (order.hasItemsToShip) {
      primaryAction = _buildActionButton(
        label: 'Expédier la commande',
        icon: Icons.local_shipping_outlined,
        color: AppColors.warning,
        isLoading: provider.isShipping,
        onTap: () => _handleShip(provider),
      );
    } else if (order.isDelivered) {
      primaryAction = Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.successDark,
            ),
            SizedBox(width: 8),
            Text(
              'Commande livrée',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successDark,
              ),
            ),
          ],
        ),
      );
    } else if (order.isCancelled) {
      primaryAction = Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_rounded,
              size: 18,
              color: AppColors.errorDark,
            ),
            SizedBox(width: 8),
            Text(
              'Commande annulée',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.errorDark,
              ),
            ),
          ],
        ),
      );
    }

    if (primaryAction == null) return null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: primaryAction,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          isLoading ? 'En cours...' : label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // ============================================
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
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
              provider.detailError ?? 'Impossible de charger la commande',
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
              onPressed: () => provider.loadOrderDetail(widget.orderId),
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
  // ACTIONS : ACCEPT
  // ============================================

  Future<void> _handleAccept(SellerOrderProvider provider) async {
    final confirmed = await _showConfirmation(
      title: 'Accepter la commande ?',
      message:
          'Vous vous engagez à préparer et expédier cette commande dans les délais.',
      confirmLabel: 'Accepter',
      confirmColor: AppColors.success,
    );

    if (confirmed != true || !mounted) return;

    final result = await provider.acceptOrder(widget.orderId);

    if (!mounted) return;

    if (result != null) {
      _showSuccess('Commande acceptée');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  // ============================================
  // ACTIONS : PREPARE
  // ============================================

  Future<void> _handlePrepare(SellerOrderProvider provider) async {
    final confirmed = await _showConfirmation(
      title: 'Passer en préparation ?',
      message: 'Vous pouvez maintenant préparer le colis.',
      confirmLabel: 'Confirmer',
      confirmColor: AppColors.info,
    );

    if (confirmed != true || !mounted) return;

    final result = await provider.prepareOrder(widget.orderId);

    if (!mounted) return;

    if (result != null) {
      _showSuccess('Commande en préparation');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  // ============================================
  // ACTIONS : SHIP
  // ============================================

  Future<void> _handleShip(SellerOrderProvider provider) async {
    final shipData = await _showShipSheet();

    if (shipData == null || !mounted) return;

    final result = await provider.shipOrder(
      widget.orderId,
      trackingNumber: shipData['tracking_number'] as String,
      carrier: shipData['carrier'] as String,
      trackingUrl: shipData['tracking_url'] as String?,
      sellerNote: shipData['seller_note'] as String?,
    );

    if (!mounted) return;

    if (result != null) {
      _showSuccess('Commande expédiée');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  Future<Map<String, dynamic>?> _showShipSheet() async {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _ShipSheet(),
    );
  }

  // ============================================
  // ACTIONS : CANCEL
  // ============================================

  Future<void> _handleCancel(SellerOrderProvider provider) async {
    final cancelData = await _showCancelSheet();

    if (cancelData == null || !mounted) return;

    final result = await provider.cancelOrder(
      widget.orderId,
      reason: cancelData['reason'] as String,
      reasonDetails: cancelData['reason_details'] as String?,
      restock: cancelData['restock'] as bool? ?? true,
    );

    if (!mounted) return;

    if (result != null) {
      _showSuccess('Commande annulée');
    } else {
      _showError(provider.actionError ?? 'Erreur');
    }
  }

  Future<Map<String, dynamic>?> _showCancelSheet() async {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _CancelSheet(),
    );
  }

  // ============================================
  // HELPERS UI
  // ============================================

  Future<bool?> _showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
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
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: confirmColor,
              ),
            ),
          ),
        ],
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
}

// ============================================
// BOTTOM SHEET : _ShipSheet
// ============================================
// Formulaire d'expédition avec tracking + carrier.
// ============================================

class _ShipSheet extends StatefulWidget {
  @override
  State<_ShipSheet> createState() => _ShipSheetState();
}

class _ShipSheetState extends State<_ShipSheet> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCarrier;

  static const _carriers = [
    {'value': 'dhl', 'label': 'DHL'},
    {'value': 'fedex', 'label': 'FedEx'},
    {'value': 'ups', 'label': 'UPS'},
    {'value': 'chronopost', 'label': 'Chronopost'},
    {'value': 'colissimo', 'label': 'Colissimo'},
    {'value': 'la_poste', 'label': 'La Poste'},
    {'value': 'mtn_delivery', 'label': 'MTN Delivery'},
    {'value': 'orange_delivery', 'label': 'Orange Delivery'},
    {'value': 'cameroon_express', 'label': 'Cameroon Express'},
    {'value': 'local_courier', 'label': 'Livreur local'},
    {'value': 'pickup_station', 'label': 'Point relais'},
    {'value': 'other', 'label': 'Autre'},
  ];

  @override
  void dispose() {
    _trackingController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Expédier la commande',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Renseignez les informations de suivi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Transporteur'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCarrier,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Sélectionner un transporteur',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: _carriers
                      .map((c) => DropdownMenuItem<String>(
                            value: c['value'],
                            child: Text(
                              c['label']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCarrier = v),
                  validator: (v) => v == null ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Numéro de suivi'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _trackingController,
                  decoration: InputDecoration(
                    hintText: 'Ex: 1Z-ABC123-XYZ',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requis';
                    if (v.trim().length < 5) return 'Au moins 5 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLabel('Note (optionnel)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Instructions spéciales...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop({
                          'carrier': _selectedCarrier,
                          'tracking_number': _trackingController.text.trim(),
                          'seller_note': _noteController.text.trim().isEmpty
                              ? null
                              : _noteController.text.trim(),
                        });
                      }
                    },
                    icon: const Icon(Icons.local_shipping_outlined, size: 18),
                    label: const Text(
                      'Confirmer l\'expédition',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ============================================
// BOTTOM SHEET : _CancelSheet
// ============================================
// Formulaire d'annulation avec motif.
// ============================================

class _CancelSheet extends StatefulWidget {
  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  String? _selectedReason;
  bool _restock = true;

  static const _reasons = [
    {'value': 'out_of_stock', 'label': 'Rupture de stock'},
    {'value': 'damaged', 'label': 'Produit endommagé'},
    {'value': 'customer_request', 'label': 'Demande du client'},
    {'value': 'pricing_error', 'label': 'Erreur de prix'},
    {'value': 'cannot_deliver', 'label': 'Zone non livrable'},
    {'value': 'seller_unavailable', 'label': 'Je ne peux pas honorer'},
    {'value': 'duplicate_order', 'label': 'Commande en doublon'},
    {'value': 'suspected_fraud', 'label': 'Suspicion de fraude'},
    {'value': 'other', 'label': 'Autre raison'},
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Annuler la commande',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cette action est irréversible. Le client sera remboursé.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Motif de l\'annulation'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Sélectionner un motif',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: _reasons
                      .map((r) => DropdownMenuItem<String>(
                            value: r['value'],
                            child: Text(
                              r['label']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedReason = v),
                  validator: (v) => v == null ? 'Requis' : null,
                ),
                if (_selectedReason == 'other') ...[
                  const SizedBox(height: 16),
                  _buildLabel('Précisez la raison'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _detailsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Expliquez la raison...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (v) {
                      if (_selectedReason == 'other' &&
                          (v == null || v.trim().isEmpty)) {
                        return 'Requis';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SwitchListTile.adaptive(
                    value: _restock,
                    onChanged: (v) => setState(() => _restock = v),
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.warning,
                    title: const Text(
                      'Remettre en stock',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Réintégrer le stock des produits annulés',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop({
                          'reason': _selectedReason,
                          'reason_details':
                              _detailsController.text.trim().isEmpty
                                  ? null
                                  : _detailsController.text.trim(),
                          'restock': _restock,
                        });
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(
                      'Confirmer l\'annulation',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}