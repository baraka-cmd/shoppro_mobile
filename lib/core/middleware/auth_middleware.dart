// Middleware d'authentification et d'autorisation
// Vérifie les tokens, les rôles et redirige si nécessaire

import 'package:flutter/material.dart';
import '../../core/services/token_service.dart';
import '../../routes/app_routes.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthMiddleware {
  final TokenService _tokenService = TokenService();

  // ============================================
  // VÉRIFICATION D'AUTHENTIFICATION
  // ============================================

  /// Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    return await _tokenService.isTokenValid();
  }

  /// Vérifier si l'utilisateur n'est PAS authentifié
  Future<bool> isNotAuthenticated() async {
    return !await isAuthenticated();
  }

  /// Vérifier si le token est expiré
  Future<bool> isTokenExpired() async {
    return await _tokenService.isTokenExpired();
  }

  // ============================================
  // VÉRIFICATION DE RÔLE
  // ============================================

  /// Vérifier si l'utilisateur est admin
  Future<bool> isAdmin(BuildContext context) async {
    if (!await isAuthenticated()) return false;
    final authProvider = context.read<AuthProvider>();
    return authProvider.isAdmin;
  }

  /// Vérifier si l'utilisateur est vendeur
  Future<bool> isSeller(BuildContext context) async {
    if (!await isAuthenticated()) return false;
    final authProvider = context.read<AuthProvider>();
    return authProvider.isSeller;
  }

  /// Vérifier si l'utilisateur est client
  Future<bool> isClient(BuildContext context) async {
    if (!await isAuthenticated()) return false;
    final authProvider = context.read<AuthProvider>();
    return authProvider.isClient;
  }

  // ============================================
  // PROTECTION DES ROUTES
  // ============================================

  /// Protéger une route (authentification requise)
  Future<bool> protectRoute({
    required BuildContext context,
    String? redirectTo,
  }) async {
    if (await isAuthenticated()) {
      return true;
    }

    // Rediriger vers login
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.login,
        arguments: {'redirect_to': redirectTo},
      );
    }

    return false;
  }

  /// Protéger une route admin
  Future<bool> protectAdminRoute({
    required BuildContext context,
  }) async {
    if (!await isAuthenticated()) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
      return false;
    }

    if (!await isAdmin(context)) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
      return false;
    }

    return true;
  }

  /// Protéger une route vendeur
  Future<bool> protectSellerRoute({
    required BuildContext context,
  }) async {
    if (!await isAuthenticated()) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
      return false;
    }

    if (!await isSeller(context)) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
      return false;
    }

    return true;
  }

  /// Protéger une route client
  Future<bool> protectClientRoute({
    required BuildContext context,
  }) async {
    if (!await isAuthenticated()) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
      return false;
    }

    if (!await isClient(context)) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
      return false;
    }

    return true;
  }

  // ============================================
  // REDIRECTION
  // ============================================

  /// Rediriger selon l'état d'authentification
  Future<void> redirectBasedOnAuth({
    required BuildContext context,
  }) async {
    final isLoggedIn = await isAuthenticated();

    if (isLoggedIn) {
      // Utilisateur connecté → Home
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } else {
      // Utilisateur non connecté → Login
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  /// Gérer la redirection après connexion
  void handlePostLoginRedirect({
    required BuildContext context,
    Object? arguments,
  }) {
    String? redirectTo;

    // Extraire la route de redirection
    if (arguments is Map<String, dynamic> && arguments.containsKey('redirect_to')) {
      redirectTo = arguments['redirect_to'] as String?;
    }

    if (context.mounted) {
      if (redirectTo != null && redirectTo.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed(redirectTo);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }

  // ============================================
  // GUARD WIDGET
  // ============================================

  /// Widget de protection pour les routes
  Widget authGuard({
    required BuildContext context,
    required Widget child,
    String? redirectTo,
  }) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher un écran de chargement
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          // Authentifié → afficher l'écran
          return child;
        }

        // Non authentifié → rediriger
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.login,
              arguments: {'redirect_to': redirectTo},
            );
          }
        });

        return const Scaffold(
          body: SizedBox.shrink(),
        );
      },
    );
  }

  /// Widget de protection admin
  Widget adminGuard({
    required BuildContext context,
    required Widget child,
  }) {
    return FutureBuilder<bool>(
      future: isAdmin(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return child;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          }
        });

        return const Scaffold(
          body: SizedBox.shrink(),
        );
      },
    );
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Vérifier et nettoyer les tokens expirés
  Future<void> checkAndCleanup() async {
    if (await isTokenExpired()) {
      await _tokenService.clearAll();
    }
  }

  /// Récupérer le token actuel
  Future<String?> getToken() async {
    return await _tokenService.getAccessToken();
  }

  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await _tokenService.getRefreshToken();
  }

  /// Vérifier si le token expire bientôt
  Future<bool> isTokenExpiringSoon() async {
    return await _tokenService.isTokenExpiringSoon(minutes: 5);
  }
}