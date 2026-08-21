// Navigation inférieure selon le rôle
// Affiche les onglets adaptés au rôle de l'utilisateur

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RoleBasedNavigation extends StatefulWidget {
  final Map<UserRole, List<NavigationItem>> roleItems;
  final void Function(int index)? onItemSelected;

  const RoleBasedNavigation({
    super.key,
    required this.roleItems,
    this.onItemSelected,
  });

  @override
  State<RoleBasedNavigation> createState() => _RoleBasedNavigationState();
}

class _RoleBasedNavigationState extends State<RoleBasedNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);

    // Récupérer les items selon le rôle
    final items = widget.roleItems[currentRole] ?? [];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = _currentIndex == index;

            return Expanded(
              child: _buildNavItem(
                item: item,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                  widget.onItemSelected?.call(index);
                  item.onTap?.call();
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  // Construire un élément de navigation
  Widget _buildNavItem({
    required NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône avec badge éventuel
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.selectedColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      key: ValueKey<bool>(isSelected),
                      size: 22,
                      color: isSelected ? item.selectedColor : item.unselectedColor,
                    ),
                  ),
                ),

                // Badge
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
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
            
            const SizedBox(height: 3),
            
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? item.selectedColor : item.unselectedColor,
              ),
              child: Text(item.label),
            ),
          ],
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
}

// Classe NavigationItem
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final VoidCallback? onTap;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.selectedColor = AppColors.primary,
    this.unselectedColor = AppColors.textSecondary,
    this.badgeCount,
    this.onTap,
  });
}

// Items prédéfinis pour chaque rôle
class RoleNavigationItems {
  /// Items pour le client
  // ✅ CORRIGÉ
  static List<NavigationItem> get clientItems => [
    const NavigationItem(
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      selectedColor: AppColors.primary,
      badgeCount: 0,  // ✅ Ajouter 0 au lieu de null
    ),
    const NavigationItem(
      label: 'Catégories',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      selectedColor: AppColors.primary,
      badgeCount: 0,  // ✅ Ajouter 0
    ),
    const NavigationItem(
      label: 'Panier',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      selectedColor: AppColors.primary,
      badgeCount: 0,
    ),
    const NavigationItem(
      label: 'Favoris',
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      selectedColor: AppColors.error,
      badgeCount: 0,  // ✅ Ajouter 0
    ),
    const NavigationItem(
      label: 'Profil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      selectedColor: AppColors.primary,
      badgeCount: 0,  // ✅ Ajouter 0
    ),
  ];
  /// Items pour le vendeur
  static List<NavigationItem> get sellerItems => [
        const NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          selectedColor: AppColors.secondary,
        ),
        const NavigationItem(
          label: 'Produits',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          selectedColor: AppColors.secondary,
        ),
        const NavigationItem(
          label: 'Commandes',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          selectedColor: AppColors.secondary,
          badgeCount: 0,
        ),
        const NavigationItem(
          label: 'Stats',
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
          selectedColor: AppColors.secondary,
        ),
        const NavigationItem(
          label: 'Profil',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          selectedColor: AppColors.secondary,
        ),
      ];

  /// Items pour l'admin
  static List<NavigationItem> get adminItems => [
        const NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          selectedColor: AppColors.error,
        ),
        const NavigationItem(
          label: 'Produits',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          selectedColor: AppColors.error,
        ),
        const NavigationItem(
          label: 'Commandes',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          selectedColor: AppColors.error,
        ),
        const NavigationItem(
          label: 'Utilisateurs',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          selectedColor: AppColors.error,
        ),
        const NavigationItem(
          label: 'Paramètres',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          selectedColor: AppColors.error,
        ),
      ];

  /// Items pour l'invité
  static List<NavigationItem> get guestItems => [
        const NavigationItem(
          label: 'Accueil',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          selectedColor: AppColors.primary,
        ),
        const NavigationItem(
          label: 'Catégories',
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view,
          selectedColor: AppColors.primary,
        ),
        const NavigationItem(
          label: 'Connexion',
          icon: Icons.login_outlined,
          selectedIcon: Icons.login,
          selectedColor: AppColors.primary,
        ),
      ];

  /// Récupérer les items selon le rôle
  static List<NavigationItem> getItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return adminItems;
      case UserRole.seller:
        return sellerItems;
      case UserRole.client:
        return clientItems;
      case UserRole.guest:
        return guestItems;
    }
  }
}