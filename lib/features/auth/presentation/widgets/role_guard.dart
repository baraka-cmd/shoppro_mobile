// Garde de rôle - Widget conditionnel selon le rôle
// Affiche ou masque des widgets selon le rôle de l'utilisateur

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/user_role.dart';
import '../providers/auth_provider.dart';
import '../../../../routes/app_routes.dart';

class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final bool redirectIfDenied;
  final String? redirectTo;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.redirectIfDenied = false,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);

    // Vérifier si le rôle est autorisé
    final isAllowed = allowedRoles.contains(currentRole);

    if (isAllowed) {
      return child;
    }

    // Rediriger si nécessaire
    if (redirectIfDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(
            redirectTo ?? AppRoutes.home,
          );
        }
      });
    }

    // Afficher le fallback ou rien
    return fallback ?? const SizedBox.shrink();
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

// Variante : Garde admin uniquement
class AdminGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.admin],
      child: child,
      fallback: fallback,
    );
  }
}

// Variante : Garde vendeur et admin
class SellerGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const SellerGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.admin, UserRole.seller],
      child: child,
      fallback: fallback,
    );
  }
}

// Variante : Garde client et plus
class ClientGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ClientGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.admin, UserRole.seller, UserRole.client],
      child: child,
      fallback: fallback,
    );
  }
}

// Variante : Garde authentifié (tout sauf guest)
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final bool redirectToLogin;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
    this.redirectToLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [
        UserRole.admin,
        UserRole.seller,
        UserRole.client,
      ],
      child: child,
      fallback: fallback,
      redirectIfDenied: redirectToLogin,
      redirectTo: AppRoutes.login,
    );
  }
}

// Variante : Garde invité uniquement (non connecté)
class GuestGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const GuestGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.guest],
      child: child,
      fallback: fallback,
    );
  }
}

// Widget de redirection selon le rôle
class RoleBasedRedirect extends StatelessWidget {
  final Map<UserRole, String> roleRoutes;
  final String defaultRoute;

  const RoleBasedRedirect({
    super.key,
    required this.roleRoutes,
    this.defaultRoute = AppRoutes.home,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);

    // Trouver la route selon le rôle
    final targetRoute = roleRoutes[currentRole] ?? defaultRoute;

    // Rediriger
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(targetRoute);
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  UserRole _getCurrentRole(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return UserRole.guest;
    }
    final userRoles = authProvider.user?.roles ?? [];
    return UserRole.fromList(userRoles);
  }
}

// Menu conditionnel selon le rôle
class RoleBasedMenu extends StatelessWidget {
  final Map<UserRole, List<Widget>> roleMenus;
  final List<Widget>? defaultMenu;

  const RoleBasedMenu({
    super.key,
    required this.roleMenus,
    this.defaultMenu,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentRole = _getCurrentRole(authProvider);

    // Récupérer le menu selon le rôle
    final menuItems = roleMenus[currentRole] ?? defaultMenu ?? [];

    return Column(
      children: menuItems,
    );
  }

  UserRole _getCurrentRole(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return UserRole.guest;
    }
    final userRoles = authProvider.user?.roles ?? [];
    return UserRole.fromList(userRoles);
  }
}