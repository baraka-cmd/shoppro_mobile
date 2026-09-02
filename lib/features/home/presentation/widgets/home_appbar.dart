// ============================================
// WIDGET : HomeAppBar
// ============================================
// Barre supérieure de l'accueil avec :
// - Salutation personnalisée "Bonjour 👋"
// - Barre de recherche proéminente
// - Badge panier avec compteur
// - Badge notifications
// - Design épuré et moderne
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class HomeAppBar extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final String userName;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const HomeAppBar({
    super.key,
    this.userName = 'Client',
    this.onSearchTap,
    this.onNotificationsTap,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // LIGNE 1 : Salutation + Actions
          // ============================================
          Row(
            children: [
              // Salutation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour 👋',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================
              // NOTIFICATIONS
              // ============================================
              _buildNotificationButton(context),

              const SizedBox(width: 6),

              // ============================================
              // PANIER AVEC BADGE
              // ============================================
              _buildCartButton(context),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // BARRE DE RECHERCHE (PROÉMINENTE)
          // ============================================
          _buildSearchBar(context),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON NOTIFICATIONS
  // ============================================

  Widget _buildNotificationButton(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final unreadCount = notificationProvider.unreadCount;

    return Stack(
      children: [
        IconButton(
          onPressed: onNotificationsTap ??
              () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          icon: const Icon(
            Icons.notifications_outlined,
            size: 22,
            color: AppColors.textPrimary,
          ),
          tooltip: 'Notifications',
          visualDensity: VisualDensity.compact,
        ),
        if (unreadCount > 0)
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.promo,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // BOUTON PANIER
  // ============================================

  Widget _buildCartButton(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cartCount = cartProvider.totalItems;

    return Stack(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
          icon: const Icon(
            Icons.shopping_bag_outlined,
            size: 22,
            color: AppColors.textPrimary,
          ),
          tooltip: 'Panier',
          visualDensity: VisualDensity.compact,
        ),
        if (cartCount > 0)
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // BARRE DE RECHERCHE
  // ============================================

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: onSearchTap ??
          () => Navigator.of(context).pushNamed(AppRoutes.search),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rechercher un produit...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight.withValues(alpha: 0.7),
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tune,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}