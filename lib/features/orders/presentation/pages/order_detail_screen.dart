// Écran de détail d'une commande
// Affiche les informations complètes avec timeline et actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../providers/order_provider.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  List<OrderTimelineEvent> _timeline = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  // Charger la commande
  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
    });

    final provider = context.read<OrderProvider>();
    final order = provider.getOrderById(widget.orderId);

    if (order != null) {
      final timeline = await provider.getOrderTimeline(widget.orderId);

      setState(() {
        _order = order;
        _timeline = timeline;
        _isLoading = false;
      });
    } else {
      await provider.loadOrders();
      final reloadedOrder = provider.getOrderById(widget.orderId);

      setState(() {
        _order = reloadedOrder;
        _isLoading = false;
      });
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
        title: const Text(
          'Détails de la commande',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _order == null
              ? const Center(
                  child: Text(
                    'Commande introuvable',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : _buildOrderDetails(),
    );
  }

  // Détails de la commande
  Widget _buildOrderDetails() {
    final order = _order!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Numéro + Statut
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      order.formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Timeline
          if (_timeline.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderColor.withValues(alpha: 0.5),
                ),
              ),
              child: OrderTimeline(events: _timeline),
            ),

          const SizedBox(height: 20),

          // Articles
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ARTICLES',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) {
                  return _buildOrderItem(item);
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Résumé des montants
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RÉSUMÉ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAmountRow('Sous-total', order.formattedSubtotal),
                if (order.discount > 0) ...[
                  const SizedBox(height: 6),
                  _buildAmountRow('Remise', '- ${order.discount.toStringAsFixed(0)} FCFA', isGreen: true),
                ],
                if (order.couponDiscount > 0) ...[
                  const SizedBox(height: 6),
                  _buildAmountRow('Code promo', '- ${order.couponDiscount.toStringAsFixed(0)} FCFA', isGreen: true),
                ],
                const SizedBox(height: 6),
                _buildAmountRow('Livraison', order.formattedShippingFee, isGreen: order.shippingFee == 0),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildAmountRow('TOTAL', order.formattedTotal, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Actions
          if (order.canCancel)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                    child: const Text(
                      'ANNULER LA COMMANDE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if (order.canReturn) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showReturnDialog(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.warning),
                      ),
                    ),
                    child: const Text(
                      'RETOURNER LA COMMANDE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Item de commande
  Widget _buildOrderItem(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.productImage != null && item.productImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.productImage!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image,
                          size: 25,
                          color: AppColors.textLight,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.background,
                      child: const Icon(
                        Icons.image,
                        size: 25,
                        color: AppColors.textLight,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.quantity} x ${item.formattedPrice}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Sous-total
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
    );
  }

  // Ligne de montant
  Widget _buildAmountRow(
    String label,
    String value, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isGreen
                ? AppColors.success
                : isBold
                    ? AppColors.primary
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Dialog d'annulation
  void _showCancelDialog(Order order) {
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
              child: const Text('Retour'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final provider = context.read<OrderProvider>();
                await provider.cancelOrder(order.id, 'Annulation par le client');
                if (mounted) {
                  await _loadOrder();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // Dialog de retour
  void _showReturnDialog(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Retourner la commande ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Vous disposez de 7 jours pour retourner votre commande.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Retour'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final provider = context.read<OrderProvider>();
                await provider.returnOrder(order.id, 'Retour client');
                if (mounted) {
                  await _loadOrder();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}