// ============================================
// WIDGET : AdminSidebar
// ============================================
// Sidebar de navigation du backoffice admin.
// Design moderne avec couleur primaire bleu profond.
//
// Structure :
// - Logo ShopPro en haut
// - Menu de navigation avec icônes
// - Élément actif mis en évidence
// - Déconnexion en bas
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// MODÈLE D'ÉLÉMENT DE MENU
// ============================================

/// Élément du menu de la sidebar
class AdminMenuItem {
  final String label;
  final IconData icon;
  final String route;

  const AdminMenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Sidebar de navigation de l'administration.
///
/// Affiche :
/// - Le logo ShopPro
/// - Les liens de navigation
/// - L'élément actif en surbrillance
/// - Le bouton de déconnexion
class AdminSidebar extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Route actuellement active
  final String currentRoute;

  /// Callback quand un élément est sélectionné
  final Function(String route)? onNavigate;

  /// Callback pour la déconnexion
  final VoidCallback? onLogout;

  /// Largeur de la sidebar
  final double width;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    this.onNavigate,
    this.onLogout,
    this.width = 250,
  });

  // ============================================
  // LISTE DES MENUS
  // ============================================

  static final List<AdminMenuItem> _menuItems = [
    const AdminMenuItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: '/admin/dashboard',
    ),
    const AdminMenuItem(
      label: 'Produits',
      icon: Icons.inventory_2_outlined,
      route: '/admin/products',
    ),
    const AdminMenuItem(
      label: 'Catégories',
      icon: Icons.category_outlined,
      route: '/admin/categories',
    ),
    const AdminMenuItem(
      label: 'Marques',
      icon: Icons.storefront_outlined,
      route: '/admin/brands',
    ),
    const AdminMenuItem(
      label: 'Commandes',
      icon: Icons.receipt_long_outlined,
      route: '/admin/orders',
    ),
    const AdminMenuItem(
      label: 'Utilisateurs',
      icon: Icons.people_outline,
      route: '/admin/users',
    ),
    const AdminMenuItem(
      label: 'Stocks',
      icon: Icons.warehouse_outlined,
      route: '/admin/stocks',
    ),
    const AdminMenuItem(
      label: 'Promotions',
      icon: Icons.local_offer_outlined,
      route: '/admin/promotions',
    ),
    const AdminMenuItem(
      label: 'Avis',
      icon: Icons.star_outline,
      route: '/admin/reviews',
    ),
    const AdminMenuItem(
      label: 'Bannières',
      icon: Icons.image_outlined,
      route: '/admin/banners',
    ),
    const AdminMenuItem(
      label: 'Paramètres',
      icon: Icons.settings_outlined,
      route: '/admin/settings',
    ),
  ];

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.adminSidebarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================
          // LOGO
          // ============================================
          _buildLogo(),

          // Séparateur
          _buildSeparator(),

          // ============================================
          // MENU DE NAVIGATION
          // ============================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return _buildMenuItem(context, item);
              },
            ),
          ),

          // Séparateur
          _buildSeparator(),

          // ============================================
          // DÉCONNEXION
          // ============================================
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit le logo ShopPro.
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          // Icône logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.adminAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Texte logo
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ShopPro',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Administration',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit un séparateur.
  Widget _buildSeparator() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF2D4A6E),
    );
  }

  /// Construit un élément du menu.
  Widget _buildMenuItem(BuildContext context, AdminMenuItem item) {
    final isActive = currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavigate?.call(item.route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2D4A6E) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Icône
                Icon(
                  item.icon,
                  size: 20,
                  color: isActive
                      ? AppColors.adminAccent
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 12),
                // Label
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
                // Indicateur actif
                if (isActive)
                  Container(
                    width: 3,
                    height: 20,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.adminAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit le bouton de déconnexion.
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D4A6E).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 20,
                  color: Color(0xFFF87171),
                ),
                SizedBox(width: 12),
                Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF87171),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}