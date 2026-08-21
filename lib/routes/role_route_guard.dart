// Garde de routes par rôle
// Protège les routes selon le rôle de l'utilisateur et redirige si nécessaire

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/domain/entities/user_role.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'app_routes.dart';

class RoleRouteGuard {
  // ============================================
  // NAVIGATION PROTÉGÉE
  // ============================================

  /// Naviguer vers une route protégée par rôle
  static Future<void> navigateTo({
    required BuildContext context,
    required String route,
    required UserRole requiredRole,
    Object? arguments,
  }) async {
    final hasAccess = await checkAccess(
      context: context,
      requiredRole: requiredRole,
    );

    if (!context.mounted) return;

    if (hasAccess) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
    } else {
      _redirectToHome(context);
    }
  }

  /// Naviguer vers une route admin
  static Future<void> navigateToAdmin({
    required BuildContext context,
    required String route,
    Object? arguments,
  }) async {
    await navigateTo(
      context: context,
      route: route,
      requiredRole: UserRole.admin,
      arguments: arguments,
    );
  }

  /// Naviguer vers une route vendeur
  static Future<void> navigateToSeller({
    required BuildContext context,
    required String route,
    Object? arguments,
  }) async {
    await navigateTo(
      context: context,
      route: route,
      requiredRole: UserRole.seller,
      arguments: arguments,
    );
  }

  /// Naviguer vers une route client
  static Future<void> navigateToClient({
    required BuildContext context,
    required String route,
    Object? arguments,
  }) async {
    await navigateTo(
      context: context,
      route: route,
      requiredRole: UserRole.client,
      arguments: arguments,
    );
  }

  // ============================================
  // VÉRIFICATION D'ACCÈS
  // ============================================

  /// Vérifier si l'utilisateur a accès à une route
  static Future<bool> checkAccess({
    required BuildContext context,
    required UserRole requiredRole,
  }) async {
    final authProvider = context.read<AuthProvider>();

    // Vérifier l'authentification
    if (!authProvider.isAuthenticated) {
      return false;
    }

    // Récupérer le rôle actuel
    final currentRole = _getCurrentRole(authProvider);

    // Vérifier si le rôle est suffisant
    return currentRole.isAtLeast(requiredRole);
  }

  /// Vérifier l'accès admin
  static Future<bool> checkAdminAccess(BuildContext context) async {
    return await checkAccess(
      context: context,
      requiredRole: UserRole.admin,
    );
  }

  /// Vérifier l'accès vendeur
  static Future<bool> checkSellerAccess(BuildContext context) async {
    return await checkAccess(
      context: context,
      requiredRole: UserRole.seller,
    );
  }

  /// Vérifier l'accès client
  static Future<bool> checkClientAccess(BuildContext context) async {
    return await checkAccess(
      context: context,
      requiredRole: UserRole.client,
    );
  }

  // ============================================
  // ROUTES PROTÉGÉES (pour RouteGenerator)
  // ============================================

  /// Construire une route protégée par rôle
  static Route<dynamic> protectedRoute({
    required RouteSettings settings,
    required Widget page,
    required UserRole requiredRole,
    String redirectRoute = AppRoutes.home,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FutureBuilder<bool>(
          future: checkAccess(
            context: context,
            requiredRole: requiredRole,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.data == true) {
              return page;
            }

            // Rediriger
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(redirectRoute);
              }
            });

            return const Scaffold(
              body: SizedBox.shrink(),
            );
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Route admin uniquement
  static Route<dynamic> adminRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return protectedRoute(
      settings: settings,
      page: page,
      requiredRole: UserRole.admin,
      redirectRoute: AppRoutes.home,
    );
  }

  /// Route vendeur (admin + vendeur)
  static Route<dynamic> sellerRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return protectedRoute(
      settings: settings,
      page: page,
      requiredRole: UserRole.seller,
      redirectRoute: AppRoutes.home,
    );
  }

  /// Route client (tous les connectés)
  static Route<dynamic> clientRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return protectedRoute(
      settings: settings,
      page: page,
      requiredRole: UserRole.client,
      redirectRoute: AppRoutes.login,
    );
  }

  // ============================================
  // REDIRECTION SELON LE RÔLE
  // ============================================

  /// Rediriger selon le rôle de l'utilisateur
  static Future<void> redirectByRole(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    final currentRole = _getCurrentRole(authProvider);

    switch (currentRole) {
      case UserRole.admin:
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
        break;
      case UserRole.seller:
        Navigator.of(context).pushReplacementNamed(AppRoutes.sellerDashboard);
        break;
      case UserRole.client:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case UserRole.guest:
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        break;
    }
  }

  /// Rediriger vers le dashboard selon le rôle
  static Future<void> redirectToDashboard(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);

    switch (currentRole) {
      case UserRole.admin:
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
        break;
      case UserRole.seller:
        Navigator.of(context).pushReplacementNamed(AppRoutes.sellerDashboard);
        break;
      default:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Récupérer le rôle actuel
  static UserRole _getCurrentRole(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return UserRole.guest;
    }

    final userRoles = authProvider.user?.roles ?? [];
    return UserRole.fromList(userRoles);
  }

  /// Récupérer le rôle actuel (public)
  static UserRole getCurrentRole(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return _getCurrentRole(authProvider);
  }

  /// Vérifier si l'utilisateur est admin
  static bool isAdmin(BuildContext context) {
    return getCurrentRole(context) == UserRole.admin;
  }

  /// Vérifier si l'utilisateur est vendeur
  static bool isSeller(BuildContext context) {
    final role = getCurrentRole(context);
    return role == UserRole.seller || role == UserRole.admin;
  }

  /// Vérifier si l'utilisateur est client
  static bool isClient(BuildContext context) {
    final role = getCurrentRole(context);
    return role == UserRole.client || role == UserRole.seller || role == UserRole.admin;
  }

  /// Afficher un message d'accès refusé
  static void showAccessDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Accès refusé. Vous n\'avez pas les droits nécessaires.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Rediriger vers home
  static void _redirectToHome(BuildContext context) {
    showAccessDenied(context);
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }
}