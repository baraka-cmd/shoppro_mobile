// ============================================
// WIDGET : AdminDrawer
// ============================================
// Menu latéral (Drawer) du backoffice admin mobile.
// Design moderne avec en-tête profil et sections.
//
// Structure :
// - En-tête avec avatar et infos admin
// - Sections de navigation
// - Liens avec icônes
// - Déconnexion en bas
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
// MODÈLE D'ÉLÉMENT DE MENU
// ============================================

/// Élément du menu du drawer
class AdminDrawerItem {
  final String label;
  final IconData icon;
  final String route;
  final Color? color;

  const AdminDrawerItem({
    required this.label,
    required this.icon,
    required this.route,
    this.color,
  });
}

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Drawer de navigation de l'administration mobile.
///
/// Affiche :
/// - Le profil de l'administrateur
/// - Les sections de navigation
/// - Le bouton de déconnexion
class AdminDrawer extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Route actuellement active
  final String currentRoute;

  /// Nom de l'administrateur
  final String adminName;

  /// Email de l'administrateur
  final String adminEmail;

  /// Avatar de l'administrateur
  final String? adminAvatar;

  /// Callback quand un lien est sélectionné
  final ValueChanged<String>? onNavigate;

  /// Callback pour la déconnexion
  final VoidCallback? onLogout;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminDrawer({
    super.key,
    required this.currentRoute,
    this.adminName = 'Admin',
    this.adminEmail = 'admin@shoppro.com',
    this.adminAvatar,
    this.onNavigate,
    this.onLogout,
  });

  // ============================================
  // SECTIONS DU MENU
  // ============================================

  static final List<Map<String, dynamic>> _sections = [
    {
      'title': 'Navigation',
      'items': [
        AdminDrawerItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          route: AppRoutes.adminDashboard,
        ),
        AdminDrawerItem(
          label: 'Statistiques',
          icon: Icons.bar_chart_outlined,
          route: AppRoutes.adminStats,
        ),
      ],
    },
    {
      'title': 'Catalogue',
      'items': [
        AdminDrawerItem(
          label: 'Produits',
          icon: Icons.inventory_2_outlined,
          route: AppRoutes.adminProducts,
        ),
        AdminDrawerItem(
          label: 'Catégories',
          icon: Icons.category_outlined,
          route: AppRoutes.adminCategories,
        ),
        AdminDrawerItem(
          label: 'Marques',
          icon: Icons.storefront_outlined,
          route: AppRoutes.adminBrands,
        ),
        AdminDrawerItem(
          label: 'Stocks',
          icon: Icons.warehouse_outlined,
          route: AppRoutes.adminStocks,
        ),
      ],
    },
    {
      'title': 'Gestion',
      'items': [
        AdminDrawerItem(
          label: 'Commandes',
          icon: Icons.receipt_long_outlined,
          route: AppRoutes.adminOrders,
        ),
        AdminDrawerItem(
          label: 'Utilisateurs',
          icon: Icons.people_outline,
          route: AppRoutes.adminUsers,
        ),
        AdminDrawerItem(
          label: 'Promotions',
          icon: Icons.local_offer_outlined,
          route: AppRoutes.adminPromotions,
        ),
      ],
    },
    {
      'title': 'Contenu',
      'items': [
        AdminDrawerItem(
          label: 'Avis clients',
          icon: Icons.star_outline,
          route: AppRoutes.adminReviews,
        ),
        AdminDrawerItem(
          label: 'Bannières',
          icon: Icons.image_outlined,
          route: AppRoutes.adminBanners,
        ),
      ],
    },
    {
      'title': 'Système',
      'items': [
        AdminDrawerItem(
          label: 'Paramètres',
          icon: Icons.settings_outlined,
          route: AppRoutes.adminSettings,
        ),
        AdminDrawerItem(
          label: 'Notifications',
          icon: Icons.notifications_outlined,
          route: AppRoutes.adminNotifications,
        ),
      ],
    },
  ];

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // ============================================
          // EN-TÊTE PROFIL
          // ============================================
          _buildHeader(),

          // ============================================
          // SECTIONS DE NAVIGATION
          // ============================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _sections.map((section) {
                return _buildSection(section);
              }).toList(),
            ),
          ),

          // ============================================
          // SÉPARATEUR
          // ============================================
          Container(
            height: 1,
            color: AppColors.borderColor,
          ),

          // ============================================
          // DÉCONNEXION
          // ============================================
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // ============================================
  // EN-TÊTE PROFIL
  // ============================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: adminAvatar != null && adminAvatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        adminAvatar!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitials();
                        },
                      ),
                    )
                  : _buildInitials(),
            ),
          ),
          const SizedBox(width: 12),
          // Nom et email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  adminName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  adminEmail,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB0C4DE),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit les initiales pour l'avatar.
  Widget _buildInitials() {
    return Text(
      _getInitials(adminName),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Extrait les initiales du nom.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  // ============================================
  // SECTION DE MENU
  // ============================================

  Widget _buildSection(Map<String, dynamic> section) {
    final title = section['title'] as String;
    final items = section['items'] as List<AdminDrawerItem>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.textLight,
            ),
          ),
        ),
        // Items
        ...items.map((item) => _buildMenuItem(item)),
      ],
    );
  }

  // ============================================
  // ÉLÉMENT DE MENU
  // ============================================

  Widget _buildMenuItem(AdminDrawerItem item) {
    final isActive = currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isActive ? AppColors.infoLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onNavigate?.call(item.route),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Icône
                Icon(
                  item.icon,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: 12),
                // Label
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                // Indicateur actif
                if (isActive)
                  Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
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

  // ============================================
  // BOUTON DÉCONNEXION
  // ============================================

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: const [
                Icon(
                  Icons.logout,
                  size: 20,
                  color: AppColors.error,
                ),
                SizedBox(width: 12),
                Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
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