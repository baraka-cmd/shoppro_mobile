// ============================================
// WIDGET : AdminScaffold
// ============================================
// Wrapper principal du backoffice admin mobile.
// Combine AppBar + Drawer + BottomNavBar + Contenu.
// Respecte la SafeArea (barre de statut du téléphone).
// Utilise GlobalKey<ScaffoldState> pour ouvrir le Drawer.
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Widgets (même feature admin)
import 'admin_app_bar.dart';
import 'admin_drawer.dart';
import 'admin_bottom_nav_bar.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Scaffold admin mobile avec navigation complète.
///
/// Combine :
/// - [AdminAppBar] : barre supérieure avec hamburger (dans SafeArea)
/// - [AdminDrawer] : menu latéral complet
/// - [AdminBottomNavBar] : barre inférieure 5 onglets (dans SafeArea)
/// - Contenu de la page
class AdminScaffold extends StatelessWidget {
  // ============================================
  // CLÉ SCAFFOLD (pour ouvrir le Drawer)
  // ============================================

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Titre de la page
  final String title;

  /// Sous-titre optionnel
  final String? subtitle;

  /// Route actuellement active
  final String currentRoute;

  /// Contenu de la page
  final Widget child;

  /// Nom de l'administrateur
  final String adminName;

  /// Email de l'administrateur
  final String adminEmail;

  /// Avatar de l'administrateur
  final String? adminAvatar;

  /// Nombre de notifications
  final int notificationCount;

  /// Callback pour la navigation
  final ValueChanged<String>? onNavigate;

  /// Callback pour les notifications
  final VoidCallback? onNotificationsTap;

  /// Callback pour la déconnexion
  final VoidCallback? onLogout;

  /// Actions supplémentaires dans l'AppBar
  final List<Widget>? appBarActions;

  /// Flottant action button
  final FloatingActionButton? floatingActionButton;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentRoute,
    required this.child,
    this.adminName = 'Admin',
    this.adminEmail = 'admin@shoppro.com',
    this.adminAvatar,
    this.notificationCount = 0,
    this.onNavigate,
    this.onNotificationsTap,
    this.onLogout,
    this.appBarActions,
    this.floatingActionButton,
  });

  // ============================================
  // MÉTHODE POUR OUVRIR LE DRAWER
  // ============================================

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,

      // ============================================
      // APP BAR (dans SafeArea pour respecter la barre de statut)
      // ============================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          child: AdminAppBar(
            title: title,
            subtitle: subtitle,
            notificationCount: notificationCount,
            adminName: adminName,
            adminAvatar: adminAvatar,
            onMenuTap: _openDrawer,
            onNotificationsTap: onNotificationsTap,
            onProfileTap: () {
              onNavigate?.call('/admin/profile');
            },
            actions: appBarActions,
          ),
        ),
      ),

      // ============================================
      // DRAWER
      // ============================================
      drawer: AdminDrawer(
        currentRoute: currentRoute,
        adminName: adminName,
        adminEmail: adminEmail,
        adminAvatar: adminAvatar,
        onNavigate: (route) {
          // Fermer le drawer
          Navigator.of(context).pop();
          // Naviguer
          onNavigate?.call(route);
        },
        onLogout: onLogout,
      ),

      // ============================================
      // CONTENU
      // ============================================
      body: SafeArea(
        top: false,
        bottom: false,
        child: child,
      ),

      // ============================================
      // FAB (optionnel)
      // ============================================
      floatingActionButton: floatingActionButton,

      // ============================================
      // BOTTOM NAVIGATION BAR (dans SafeArea)
      // ============================================
      bottomNavigationBar: SafeArea(
        top: false,
        child: AdminBottomNavBar(
          currentRoute: currentRoute,
          notificationCount: notificationCount,
          onNavigate: (route) {
            if (route.isEmpty) {
              // Ouvrir le drawer pour "Plus"
              _openDrawer();
            } else {
              onNavigate?.call(route);
            }
          },
        ),
      ),
    );
  }
}