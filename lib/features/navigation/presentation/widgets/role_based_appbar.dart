// ============================================
// BARRE D'APPLICATION SELON LE RÔLE
// ============================================
// AppBar adaptée au rôle avec les actions appropriées.
// Design épuré, moderne, cohérent avec la palette.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RoleBasedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showRoleBadge;
  final bool showSearch;
  final bool showNotifications;
  final bool showCart;
  final int? notificationCount;
  final int? cartCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onMenuTap;

  const RoleBasedAppBar({
    super.key,
    required this.title,
    this.showRoleBadge = true,
    this.showSearch = true,
    this.showNotifications = true,
    this.showCart = true,
    this.notificationCount,
    this.cartCount,
    this.onSearchTap,
    this.onNotificationTap,
    this.onCartTap,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);
    final roleColor = _getColorForRole(currentRole);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Menu (drawer)
              if (onMenuTap != null)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              const SizedBox(width: 4),

              // Logo ou icône
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  currentRole.icon,
                  size: 20,
                  color: roleColor,
                ),
              ),
              const SizedBox(width: 10),

              // Titre
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Badge de rôle
              if (showRoleBadge && currentRole != UserRole.guest)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: roleColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentRole.icon,
                          size: 12,
                          color: roleColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentRole.shortLabel,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Recherche
              if (showSearch)
                IconButton(
                  onPressed: onSearchTap,
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  tooltip: 'Rechercher',
                ),

              // Notifications
              if (showNotifications)
                Stack(
                  children: [
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: const Icon(
                        Icons.notifications_none,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      tooltip: 'Notifications',
                    ),
                    if (notificationCount != null && notificationCount! > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notificationCount! > 99
                                ? '99+'
                                : '$notificationCount',
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
                ),

              // Panier (client uniquement)
              if (showCart && currentRole == UserRole.client)
                Stack(
                  children: [
                    IconButton(
                      onPressed: onCartTap,
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textPrimary,
                        size: 21,
                      ),
                      tooltip: 'Panier',
                    ),
                    if (cartCount != null && cartCount! > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartCount! > 99 ? '99+' : '$cartCount',
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Récupérer le rôle actuel
  UserRole _getCurrentRole(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return UserRole.guest;
    }
    final userRoles = authProvider.user?.roles ?? [];
    return UserRole.fromList(userRoles);
  }

  // Couleur selon le rôle
  Color _getColorForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.primaryDark;
      case UserRole.seller:
        return AppColors.warning;
      case UserRole.client:
        return AppColors.primary;
      case UserRole.guest:
        return AppColors.textSecondary;
    }
  }
}