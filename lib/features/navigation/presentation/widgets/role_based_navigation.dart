// ============================================
// NAVIGATION INFÉRIEURE FLOTTANTE SELON LE RÔLE
// ============================================
// Affiche les onglets adaptés au rôle de l'utilisateur.
// Design : Floating Bottom Navigation avec capsule
// coulissante, animations fluides et badges dynamiques.
// ============================================

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
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

  // ============================================
  // CONSTRUIRE UN ÉLÉMENT DE NAVIGATION
  // ============================================
  Widget _buildNavItem({
    required NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: item.label,
        selected: isSelected,
        button: true,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône avec badge éventuel
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Capsule de sélection
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: isSelected ? 52 : 44,
                    height: 36,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item.selectedColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        key: ValueKey<bool>(isSelected),
                        size: 22,
                        color: isSelected
                            ? item.selectedColor
                            : item.unselectedColor,
                      ),
                    ),
                  ),

                  // Badge
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
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
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // RÉCUPÉRER LE RÔLE ACTUEL
  // ============================================
  UserRole _getCurrentRole(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return UserRole.guest;
    }
    final userRoles = authProvider.user?.roles ?? [];
    return UserRole.fromList(userRoles);
  }
}

// ============================================
// CLASSE NAVIGATION ITEM
// ============================================
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
    this.unselectedColor = const Color(0xFF68756F),
    this.badgeCount,
    this.onTap,
  });
}

// ============================================
// ITEMS PRÉDÉFINIS POUR CHAQUE RÔLE
// ============================================
class RoleNavigationItems {
  /// Items pour le client
  static List<NavigationItem> get clientItems => [
        const NavigationItem(
          label: 'Accueil',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Explorer',
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Favoris',
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Panier',
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Profil',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
      ];

  /// Items pour le vendeur
  static List<NavigationItem> get sellerItems => [
        const NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          selectedColor: AppColors.warning,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Produits',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          selectedColor: AppColors.warning,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Commandes',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          selectedColor: AppColors.warning,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Stats',
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
          selectedColor: AppColors.warning,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Profil',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          selectedColor: AppColors.warning,
          unselectedColor: Color(0xFF68756F),
        ),
      ];

  /// Items pour l'admin
  static List<NavigationItem> get adminItems => [
        const NavigationItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          selectedColor: AppColors.primaryDark,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Produits',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          selectedColor: AppColors.primaryDark,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Commandes',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
          selectedColor: AppColors.primaryDark,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Utilisateurs',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          selectedColor: AppColors.primaryDark,
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Paramètres',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          selectedColor: AppColors.primaryDark,
          unselectedColor: Color(0xFF68756F),
        ),
      ];

  /// Items pour l'invité
  static List<NavigationItem> get guestItems => [
        const NavigationItem(
          label: 'Accueil',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Explorer',
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Favoris',
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Panier',
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
        ),
        const NavigationItem(
          label: 'Connexion',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          selectedColor: Color(0xFF087F5B),
          unselectedColor: Color(0xFF68756F),
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