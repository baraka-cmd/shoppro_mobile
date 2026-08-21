// Barre d'application selon le rôle
// Affiche un AppBar adapté au rôle avec les actions appropriées

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/role_badge.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: _getGradientForRole(currentRole),
        boxShadow: [
          BoxShadow(
            color: _getColorForRole(currentRole).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              // Menu (drawer)
              if (onMenuTap != null)
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              
              // Logo ou titre
              Expanded(
                child: Row(
                  children: [
                    // Icône du rôle
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        currentRole.icon,
                        size: 18,
                        color: Colors.white,
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
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Badge de rôle
              if (showRoleBadge && currentRole != UserRole.guest)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          currentRole.icon,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currentRole.shortLabel,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              
              // Notifications
              if (showNotifications)
                Stack(
                  children: [
                    IconButton(
                      onPressed: onNotificationTap,
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (notificationCount != null && notificationCount! > 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            notificationCount! > 99
                                ? '99+'
                                : '$notificationCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 7,
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
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    if (cartCount != null && cartCount! > 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            cartCount! > 99 ? '99+' : '$cartCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 7,
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
        return AppColors.error;
      case UserRole.seller:
        return AppColors.secondary;
      case UserRole.client:
        return AppColors.primary;
      case UserRole.guest:
        return AppColors.textSecondary;
    }
  }

  // Dégradé selon le rôle
  LinearGradient _getGradientForRole(UserRole role) {
    final color = _getColorForRole(role);
    return LinearGradient(
      colors: [
        color,
        color.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}