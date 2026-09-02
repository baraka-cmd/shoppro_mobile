// ============================================
// MENU LATÉRAL (DRAWER) SELON LE RÔLE
// ============================================
// Affiche les options adaptées au rôle de l'utilisateur.
// Design moderne, cohérent avec la palette ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RoleBasedDrawer extends StatelessWidget {
  const RoleBasedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);
    final user = authProvider.user;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // En-tête du drawer
            _buildDrawerHeader(currentRole, user),

            const SizedBox(height: 10),

            // Menu selon le rôle
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _buildMenuItems(context, currentRole),
              ),
            ),

            // Pied du drawer
            _buildDrawerFooter(context, currentRole),
          ],
        ),
      ),
    );
  }

  // ============================================
  // EN-TÊTE DU DRAWER
  // ============================================
  Widget _buildDrawerHeader(UserRole role, dynamic user) {
    final roleColor = _getColorForRole(role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            roleColor,
            roleColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: user?.avatar != null && user!.avatar!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitials(user.fullName ?? '?');
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildInitials(user.fullName ?? '?');
                      },
                    ),
                  )
                : _buildInitials(user?.fullName ?? '?'),
          ),

          const SizedBox(height: 12),

          // Nom
          Text(
            user?.fullName ?? 'Utilisateur',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 3),

          // Email
          Text(
            user?.email ?? 'email@example.com',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Badge rôle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(role.icon, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  role.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ITEMS DU MENU SELON LE RÔLE
  // ============================================
  List<Widget> _buildMenuItems(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.admin:
        return _buildAdminMenu(context);
      case UserRole.seller:
        return _buildSellerMenu(context);
      case UserRole.client:
        return _buildClientMenu(context);
      case UserRole.guest:
        return _buildGuestMenu(context);
    }
  }

  // Menu Admin
  List<Widget> _buildAdminMenu(BuildContext context) {
    return [
      _buildSectionLabel('GESTION'),
      _buildDrawerItem(
        context: context,
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        route: AppRoutes.adminDashboard,
        color: AppColors.primaryDark,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.inventory_2_outlined,
        title: 'Produits',
        route: AppRoutes.adminProducts,
        color: AppColors.primaryDark,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.receipt_long_outlined,
        title: 'Commandes',
        route: AppRoutes.adminOrders,
        color: AppColors.primaryDark,
        badge: '12',
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.people_outline,
        title: 'Utilisateurs',
        route: AppRoutes.adminUsers,
        color: AppColors.primaryDark,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.storefront_outlined,
        title: 'Marques',
        route: AppRoutes.adminBrands,
        color: AppColors.primaryDark,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.category_outlined,
        title: 'Catégories',
        route: AppRoutes.adminCategories,
        color: AppColors.primaryDark,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.local_offer_outlined,
        title: 'Promotions',
        route: AppRoutes.adminPromotions,
        color: AppColors.primaryDark,
      ),

      _buildSectionLabel('SYSTÈME'),
      _buildDrawerItem(
        context: context,
        icon: Icons.star_outline,
        title: 'Avis clients',
        route: AppRoutes.adminReviews,
        color: AppColors.warning,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.image_outlined,
        title: 'Bannières',
        route: AppRoutes.adminBanners,
        color: AppColors.info,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.settings_outlined,
        title: 'Paramètres',
        route: AppRoutes.adminSettings,
        color: AppColors.textSecondary,
      ),
    ];
  }

  // Menu Vendeur
  List<Widget> _buildSellerMenu(BuildContext context) {
    return [
      _buildSectionLabel('MA BOUTIQUE'),
      _buildDrawerItem(
        context: context,
        icon: Icons.dashboard_outlined,
        title: 'Dashboard',
        route: AppRoutes.sellerDashboard,
        color: AppColors.warning,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.inventory_2_outlined,
        title: 'Mes Produits',
        route: AppRoutes.sellerProducts,
        color: AppColors.warning,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.receipt_long_outlined,
        title: 'Commandes',
        route: AppRoutes.sellerOrders,
        color: AppColors.warning,
        badge: '5',
      ),

      _buildSectionLabel('ANALYSE'),
      _buildDrawerItem(
        context: context,
        icon: Icons.bar_chart_outlined,
        title: 'Statistiques',
        route: AppRoutes.sellerStats,
        color: AppColors.warning,
      ),
    ];
  }

  // Menu Client
  List<Widget> _buildClientMenu(BuildContext context) {
    return [
      _buildSectionLabel('MES ACTIVITÉS'),
      _buildDrawerItem(
        context: context,
        icon: Icons.shopping_bag_outlined,
        title: 'Mes commandes',
        route: AppRoutes.orders,
        color: AppColors.primary,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.favorite_outline,
        title: 'Mes favoris',
        route: AppRoutes.favorites,
        color: AppColors.error,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.star_outline,
        title: 'Mes avis',
        route: AppRoutes.home,
        color: AppColors.warning,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.location_on_outlined,
        title: 'Mes adresses',
        route: AppRoutes.addresses,
        color: AppColors.info,
      ),

      _buildSectionLabel('PARAMÈTRES'),
      _buildDrawerItem(
        context: context,
        icon: Icons.person_outline,
        title: 'Mon profil',
        route: AppRoutes.profile,
        color: AppColors.primary,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.notifications_none,
        title: 'Notifications',
        route: AppRoutes.notifications,
        color: AppColors.info,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.help_outline,
        title: 'Aide & Support',
        route: AppRoutes.home,
        color: AppColors.textSecondary,
      ),
    ];
  }

  // Menu Invité
  List<Widget> _buildGuestMenu(BuildContext context) {
    return [
      _buildDrawerItem(
        context: context,
        icon: Icons.login,
        title: 'Se connecter',
        route: AppRoutes.login,
        color: AppColors.primary,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.person_add_alt,
        title: 'S\'inscrire',
        route: AppRoutes.register,
        color: AppColors.success,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.home_outlined,
        title: 'Accueil',
        route: AppRoutes.home,
        color: AppColors.textSecondary,
      ),
      _buildDrawerItem(
        context: context,
        icon: Icons.help_outline,
        title: 'Aide & Support',
        route: AppRoutes.home,
        color: AppColors.textSecondary,
      ),
    ];
  }

  // ============================================
  // PIED DU DRAWER
  // ============================================
  Widget _buildDrawerFooter(BuildContext context, UserRole role) {
    if (role == UserRole.guest) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: AppColors.error,
              ),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppColors.error.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ITEM DE MENU
  // ============================================
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required Color color,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textLight,
            ),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hoverColor: color.withValues(alpha: 0.05),
    );
  }

  // ============================================
  // LABEL DE SECTION
  // ============================================
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.textTertiary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  // ============================================
  // INITIALES
  // ============================================
  Widget _buildInitials(String name) {
    final initials = _getInitials(name);
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // ============================================
  // DIALOG DÉCONNEXION
  // ============================================
  void _showLogoutDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Se déconnecter ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Vous devrez vous reconnecter pour accéder à votre compte.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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

  // ============================================
  // COULEUR SELON LE RÔLE
  // ============================================
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