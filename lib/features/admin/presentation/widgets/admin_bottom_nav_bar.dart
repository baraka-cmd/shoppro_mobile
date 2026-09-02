// ============================================
// WIDGET : AdminBottomNavBar
// ============================================
// Barre de navigation inférieure du backoffice admin mobile.
// Design moderne avec 5 icônes principales.
//
// Structure :
// - 5 onglets avec icônes et labels
// - Indicateur d'onglet actif
// - Badge de notification sur l'onglet Plus
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// ============================================
// MODÈLE D'ONGLET
// ============================================

/// Définition d'un onglet de la barre inférieure
class AdminNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const AdminNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Barre de navigation inférieure mobile.
///
/// Affiche :
/// - 5 onglets principaux
/// - L'onglet actif en surbrillance
/// - Un badge sur l'onglet Plus
class AdminBottomNavBar extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Route actuellement active
  final String currentRoute;

  /// Callback quand un onglet est sélectionné
  final ValueChanged<String>? onNavigate;

  /// Nombre de notifications non lues (badge sur Plus)
  final int notificationCount;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminBottomNavBar({
    super.key,
    required this.currentRoute,
    this.onNavigate,
    this.notificationCount = 0,
  });

  // ============================================
  // ONGLETS
  // ============================================

  static final List<AdminNavItem> _navItems = [
    const AdminNavItem(
      label: 'Accueil',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: AppRoutes.adminDashboard,
    ),
    const AdminNavItem(
      label: 'Produits',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: AppRoutes.adminProducts,
    ),
    const AdminNavItem(
      label: 'Commandes',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      route: AppRoutes.adminOrders,
    ),
    const AdminNavItem(
      label: 'Avis',
      icon: Icons.star_outline,
      activeIcon: Icons.star,
      route: AppRoutes.adminReviews,
    ),
    const AdminNavItem(
      label: 'Plus',
      icon: Icons.more_horiz,
      activeIcon: Icons.more_horiz,
      route: '', // Route vide = ouvre le Drawer
    ),
  ];

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Expanded(
            child: _buildNavItem(item, index),
          );
        }).toList(),
      ),
    );
  }

  // ============================================
  // ÉLÉMENT D'ONGLET
  // ============================================

  Widget _buildNavItem(AdminNavItem item, int index) {
    final isActive = currentRoute == item.route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.route.isNotEmpty) {
            onNavigate?.call(item.route);
          } else {
            // Onglet "Plus" : ouvre le Drawer
            onNavigate?.call('');
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ============================================
            // ICÔNE AVEC BADGE POSSIBLE
            // ============================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 22,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                ),
                // Badge notifications sur l'onglet Plus
                if (item.route.isEmpty && notificationCount > 0)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount > 99 ? '99+' : '$notificationCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // ============================================
            // LABEL
            // ============================================
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),

            // ============================================
            // INDICATEUR ACTIF (point)
            // ============================================
            const SizedBox(height: 3),
            Container(
              width: isActive ? 16 : 4,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}