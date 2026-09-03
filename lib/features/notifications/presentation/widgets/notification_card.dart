// ============================================
// CARTE DE NOTIFICATION - VERSION PREMIUM
// ============================================
// Affiche le titre, le contenu et le type avec
// couleur, animations et actions. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/app_notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkUnread;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.onMarkUnread,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : Color(notification.typeColorHex).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderColor.withValues(alpha: 0.5)
                : Color(notification.typeColorHex).withValues(alpha: 0.3),
          ),
          boxShadow: notification.isRead ? null : AppColors.softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // ICÔNE DU TYPE
            // ============================================
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Color(notification.typeColorHex).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  notification.typeEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ============================================
            // CONTENU
            // ============================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + Badge non lu
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(notification.typeColorHex),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Color(notification.typeColorHex).withValues(alpha: 0.4),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Corps
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Type + Temps
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Color(notification.typeColorHex)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          notification.typeLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(notification.typeColorHex),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 10,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        notification.relativeTime,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ============================================
            // ACTIONS
            // ============================================
            Column(
              children: [
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                  ),
                if (onMarkUnread != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onMarkUnread,
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}