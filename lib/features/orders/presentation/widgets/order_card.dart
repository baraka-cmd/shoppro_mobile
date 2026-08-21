// Carte de commande
// Affiche le résumé d'une commande avec statut et actions

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

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onTrack,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : Numéro + Statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Numéro de commande
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Statut
                OrderStatusBadge(status: order.status, compact: true),
              ],
            ),

            const SizedBox(height: 10),

            // Articles (mini images)
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  // Images des articles (max 3)
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
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.image,
                                  size: 20,
                                  color: AppColors.textLight,
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 20,
                                color: AppColors.textLight,
                              ),
                      ),
                    );
                  }),

                  // +N articles
                  if (order.totalItems > 3)
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
            Divider(height: 1, color: AppColors.borderColor.withValues(alpha: 0.3)),

            const SizedBox(height: 8),

            // Footer : Date + Actions
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
                  children: [
                    // Suivre
                    if (onTrack != null && order.status != 'delivered' && order.status != 'cancelled')
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
                    // Annuler
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}