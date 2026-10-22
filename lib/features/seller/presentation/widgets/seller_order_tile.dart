// ============================================
// WIDGET : SellerOrderTile
// ============================================
// Carte de commande pour la liste vendeur.
//
// Design :
//   - Numéro de commande + date relative
//   - Badge statut coloré
//   - Nom du client + ville
//   - Résumé articles + total vendeur
//   - Indicateur "action requise" (pulse orange si à accepter)
//   - Chevron pour indiquer la navigation
//
// UX :
//   - Tap → détail
//   - Pulse animation si action urgente
//   - Highlight si action requise
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_order.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerOrderTile extends StatelessWidget {
  final SellerOrder order;
  final VoidCallback? onTap;

  const SellerOrderTile({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: order.needsAction
                    ? AppColors.warning.withValues(alpha: 0.4)
                    : AppColors.borderColor.withValues(alpha: 0.6),
                width: order.needsAction ? 1.5 : 1,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // LIGNE 1 : Numéro + Statut + Action requise
                // ============================================
                _buildHeaderRow(),

                const SizedBox(height: 10),

                // ============================================
                // LIGNE 2 : Client + Ville
                // ============================================
                _buildCustomerRow(),

                const SizedBox(height: 10),

                // ============================================
                // LIGNE 3 : Items preview + Total
                // ============================================
                _buildItemsAndTotal(),

                // ============================================
                // LIGNE 4 : Actions requises (si applicable)
                // ============================================
                if (order.needsAction) ...[
                  const SizedBox(height: 10),
                  _buildActionHints(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // HEADER
  // ============================================

  Widget _buildHeaderRow() {
    return Row(
      children: [
        // Indicateur pulse si action requise
        if (order.hasItemsToAccept) ...[
          _buildPulseDot(),
          const SizedBox(width: 8),
        ] else ...[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
        ],

        // Numéro + Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                order.createdAtHuman ?? _formatDate(order.createdAt),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Badge statut
        _buildStatusBadge(),

        const SizedBox(width: 4),

        // Chevron
        const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  // ============================================
  // CLIENT
  // ============================================

  Widget _buildCustomerRow() {
    final customer = order.customer;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              customer?.initials ?? '?',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  customer?.name ?? 'Client',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (customer?.hasLocation == true) ...[
                const SizedBox(width: 6),
                const Text(
                  '•',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer!.formattedLocation,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // ITEMS + TOTAL
  // ============================================

  Widget _buildItemsAndTotal() {
    // Construire un résumé des items (ex: "iPhone 15 + 2 autres")
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final othersCount = order.items.length - 1;

    return Row(
      children: [
        // Résumé articles
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _buildItemsSummary(firstItem, othersCount),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Total vendeur
        Text(
          order.totals.subtotalFormatted,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  String _buildItemsSummary(SellerOrderItem? first, int othersCount) {
    if (first == null) return 'Aucun article';

    final firstPart = '${first.quantity}× ${first.productName}';

    if (othersCount > 0) {
      return '$firstPart + $othersCount autre${othersCount > 1 ? 's' : ''}';
    }

    return firstPart;
  }

  // ============================================
  // ACTIONS REQUISES (HINTS)
  // ============================================

  Widget _buildActionHints() {
    final hints = <Widget>[];

    if (order.hasItemsToAccept) {
      hints.add(_buildActionHint('À accepter', AppColors.warning));
    }
    if (order.hasItemsToPrepare) {
      hints.add(_buildActionHint('À préparer', AppColors.info));
    }
    if (order.hasItemsToShip) {
      hints.add(_buildActionHint('À expédier', AppColors.primary));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: hints,
    );
  }

  Widget _buildActionHint(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
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
    );
  }

  // ============================================
  // BADGE STATUT
  // ============================================

  Widget _buildStatusBadge() {
    final color = _getStatusColor(order.status);
    final bgColor = _getStatusBgColor(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        order.statusLabel,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return AppColors.statusPendingText;
      case 'processing':
        return AppColors.statusConfirmedText;
      case 'shipped':
        return AppColors.statusConfirmedText;
      case 'delivered':
        return AppColors.statusDeliveredText;
      case 'cancelled':
      case 'refunded':
      case 'returned':
        return AppColors.statusCancelledText;
      default:
        return AppColors.statusInactiveText;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return AppColors.statusPendingBg;
      case 'processing':
        return AppColors.statusConfirmedBg;
      case 'shipped':
        return AppColors.statusConfirmedBg;
      case 'delivered':
        return AppColors.statusDeliveredBg;
      case 'cancelled':
      case 'refunded':
      case 'returned':
        return AppColors.statusCancelledBg;
      default:
        return AppColors.statusInactiveBg;
    }
  }

  // ============================================
  // PULSE DOT
  // ============================================

  Widget _buildPulseDot() {
    return const _PulseDot(
      color: AppColors.warning,
      size: 36,
      icon: Icons.pending_actions_rounded,
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ============================================
// WIDGET : _PulseDot (animation pulse)
// ============================================

class _PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final IconData icon;

  const _PulseDot({
    required this.color,
    this.size = 36,
    required this.icon,
  });

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.08);
        final opacity = 0.5 + (_controller.value * 0.5);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Halo pulsant
            Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: opacity * 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Icône
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}


// ============================================
// WIDGET : SellerDashboardOrderTile
// ============================================
// Variante de tuile adaptée au DashboardOrderSummary.
// Utilisée uniquement sur le dashboard vendeur (où on n'a pas
// encore les données complètes de SellerOrder).
// ============================================

// ignore: must_be_immutable
class SellerDashboardOrderTile extends StatelessWidget {
  final dynamic order; // DashboardOrderSummary
  final VoidCallback? onTap;

  const SellerDashboardOrderTile({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 18,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber ?? 'CMD-XXXX',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.customerName ?? 'Client',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.totalFormatted ?? '0 FCFA',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.statusLabel ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}