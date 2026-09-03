// ============================================
// CARTE DE COMMANDE - VERSION PREMIUM
// ============================================
// Affiche le résumé d'une commande avec statut,
// miniatures et actions. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onCancel;
  final VoidCallback? onReorder;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onTrack,
    this.onCancel,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.5),
            ),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // EN-TÊTE : NUMÉRO + STATUT
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  OrderStatusBadge(status: order.status, compact: true),
                ],
              ),

              const SizedBox(height: 10),

              // ============================================
              // ARTICLES (MINI IMAGES)
              // ============================================
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    ...order.items.take(3).map((item) {
                      return Container(
                        width: 45,
                        height: 45,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: item.productImage != null &&
                                  item.productImage!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.productImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 20,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 20,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surface,
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: AppColors.textLight,
                                  ),
                                ),
                        ),
                      );
                    }),

                    if (order.totalItems > 3)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '+${order.totalItems - 3}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          order.formattedTotal,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: AppColors.borderColor.withValues(alpha: 0.3),
              ),

              const SizedBox(height: 8),

              // ============================================
              // FOOTER : DATE + ACTIONS
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onTrack != null &&
                          order.status != 'delivered' &&
                          order.status != 'cancelled')
                        TextButton(
                          onPressed: onTrack,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 30),
                          ),
                          child: const Text(
                            'Suivre',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (onCancel != null && order.canCancel)
                        TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 30),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (onReorder != null && order.canReorder)
                        TextButton(
                          onPressed: onReorder,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 30),
                          ),
                          child: const Text(
                            'Commander à nouveau',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}