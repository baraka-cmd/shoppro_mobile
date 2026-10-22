// ============================================
// WIDGET : SellerScaffold
// ============================================
// Structure de base pour toutes les pages vendeur.
//
// Responsabilités :
//   - AppBar vendeur (badge "Vendeur" + notifications + profil)
//   - Drawer vendeur (menu complet)
//   - BottomNavigationBar vendeur (5 onglets)
//   - Gestion cohérente du SafeArea
//
// Design :
//   - Couleur accent : AppColors.warning (orange)
//   - Police : Poppins
//   - Mobile-first, adapté aux petites et grandes résolutions
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Auth
import '../../../auth/presentation/providers/auth_provider.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerScaffold extends StatefulWidget {
  /// Titre affiché dans l'AppBar (optionnel).
  final String? title;

  /// Sous-titre (optionnel).
  final String? subtitle;

  /// Widget enfant (contenu de la page).
  final Widget child;

  /// Index actif de la bottom nav.
  final int currentIndex;

  /// Callback navigation bottom nav.
  final void Function(int index)? onNavTap;

  /// Afficher ou masquer la bottom nav.
  final bool showBottomNav;

  /// Actions supplémentaires dans l'AppBar.
  final List<Widget>? extraActions;

  /// Afficher le bouton retour.
  final bool showBackButton;

  /// FloatingActionButton (optionnel).
  final Widget? floatingActionButton;

  const SellerScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.currentIndex = 0,
    this.onNavTap,
    this.showBottomNav = true,
    this.extraActions,
    this.showBackButton = false,
    this.floatingActionButton,
  });

  @override
  State<SellerScaffold> createState() => _SellerScaffoldState();
}

class _SellerScaffoldState extends State<SellerScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceAlt,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        bottom: widget.showBottomNav,
        child: widget.child,
      ),
      bottomNavigationBar:
          widget.showBottomNav ? _buildBottomNav() : null,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                size: 24,
                color: AppColors.textPrimary,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
      title: _buildTitleSection(),
      actions: [
        ...?_buildAppBarActions(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTitleSection() {
    if (widget.title == null) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                SizedBox(width: 4),
                Text(
                  'Vendeur',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title!,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  List<Widget>? _buildAppBarActions() {
    final actions = <Widget>[
      IconButton(
        icon: const Icon(
          Icons.notifications_outlined,
          size: 24,
          color: AppColors.textPrimary,
        ),
        tooltip: 'Notifications',
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
        },
      ),
    ];

    if (widget.extraActions != null) {
      actions.addAll(widget.extraActions!);
    }

    return actions;
  }

  // ============================================
  // DRAWER
  // ============================================

  Widget _buildDrawer() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildDrawerHeader(user?.name ?? 'Vendeur', user?.avatar),

            const Divider(height: 1, color: AppColors.borderColor),

            // Menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Tableau de bord',
                    isActive: widget.currentIndex == 0,
                    onTap: () => _handleDrawerNavigation(0),
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Mes produits',
                    isActive: widget.currentIndex == 1,
                    onTap: () => _handleDrawerNavigation(1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Mes commandes',
                    isActive: widget.currentIndex == 2,
                    onTap: () => _handleDrawerNavigation(2),
                  ),
                  _buildDrawerItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'Statistiques',
                    isActive: widget.currentIndex == 3,
                    onTap: () => _handleDrawerNavigation(3),
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    title: 'Mon profil',
                    isActive: widget.currentIndex == 4,
                    onTap: () => _handleDrawerNavigation(4),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: AppColors.borderColor),
                  ),

                  _buildDrawerItem(
                    icon: Icons.storefront_outlined,
                    title: 'Ma boutique',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.sellerProfile);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.payments_outlined,
                    title: 'Mes gains',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(AppRoutes.sellerPayouts);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Paramètres',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: navigate to seller settings
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.borderColor),

            // Footer déconnexion
            _buildLogoutTile(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(String userName, String? avatar) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(userName),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Vendeur',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: 22,
        color: isActive ? AppColors.warning : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? AppColors.warning : AppColors.textPrimary,
        ),
      ),
      trailing: isActive
          ? Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            )
          : null,
      tileColor: isActive ? AppColors.warning.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildLogoutTile(AuthProvider authProvider) {
    return ListTile(
      onTap: () => _handleLogout(authProvider),
      leading: const Icon(
        Icons.logout_rounded,
        size: 22,
        color: AppColors.error,
      ),
      title: const Text(
        'Se déconnecter',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  // ============================================
  // BOTTOM NAVIGATION
  // ============================================

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Accueil',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: 'Produits',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Commandes',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Stats',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _handleTabNavigation(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.warning.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? AppColors.warning : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.warning : AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

    // ============================================
  // NAVIGATION PAR INDEX (gérée en interne)
  // ============================================

  /// Route correspondant à chaque onglet.
  static const Map<int, String> _tabRoutes = {
    0: AppRoutes.sellerDashboard,
    1: AppRoutes.sellerProducts,
    2: AppRoutes.sellerOrders,
    3: AppRoutes.sellerStats,
    4: AppRoutes.sellerProfile,
  };

  /// Naviguer vers l'onglet demandé.
  ///
  /// Si un `onNavTap` est fourni par le parent, on l'appelle (compatibilité).
  /// Sinon, on utilise la navigation par défaut (routes standard).
  void _handleTabNavigation(int index) {
    // 1. Si le parent a fourni un callback custom, l'appeler
    if (widget.onNavTap != null) {
      widget.onNavTap!(index);
      return;
    }

    // 2. Sinon, navigation par défaut
    // Si c'est déjà l'onglet actif, ne rien faire
    if (widget.currentIndex == index) return;

    final route = _tabRoutes[index];
    if (route == null) return;

    // Si l'onglet est "Profil" (index 4), on push (pas replace)
    // pour pouvoir revenir au dashboard
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _handleDrawerNavigation(int index) {
    Navigator.of(context).pop();
    _handleTabNavigation(index);
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    Navigator.of(context).pop();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Se déconnecter ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Vous serez redirigé vers la page de connexion.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Se déconnecter',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'V';
  }
}