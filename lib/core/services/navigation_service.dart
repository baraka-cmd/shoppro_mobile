// Service de navigation global
// Permet de naviguer sans contexte et gère les redirections

import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Clé de navigation globale
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Contexte actuel
  BuildContext? get context => navigatorKey.currentContext;

  // NavigatorState actuel
  NavigatorState? get navigator => navigatorKey.currentState;

  // ============================================
  // NAVIGATION SIMPLE
  // ============================================

  /// Naviguer vers une route nommée
  Future<void> navigateTo(String routeName, {Object? arguments}) async {
    await navigator?.pushNamed(routeName, arguments: arguments);
  }

  /// Remplacer la route actuelle
  Future<void> replaceTo(String routeName, {Object? arguments}) async {
    await navigator?.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Naviguer et supprimer toutes les routes précédentes
  Future<void> navigateAndRemoveUntil(String routeName) async {
    await navigator?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  /// Remplacer et supprimer toutes les routes
  Future<void> replaceAndRemoveUntil(String routeName) async {
    await navigator?.pushReplacementNamed(routeName);
  }

  /// Retourner à la page précédente
  void goBack() {
    navigator?.pop();
  }

  /// Retourner avec un résultat
  void goBackWithResult<T>(T result) {
    navigator?.pop(result);
  }

  // ============================================
  // NAVIGATION AVEC VÉRIFICATION
  // ============================================

  /// Naviguer vers une route protégée
  Future<void> navigateToProtected(
    String routeName, {
    required bool isAuthenticated,
    Object? arguments,
  }) async {
    if (isAuthenticated) {
      await navigateTo(routeName, arguments: arguments);
    } else {
      await navigateToLogin(redirectTo: routeName);
    }
  }

  /// Naviguer vers le login avec redirection
  Future<void> navigateToLogin({String? redirectTo}) async {
    await navigator?.pushNamed(
      AppRoutes.login,
      arguments: {'redirect_to': redirectTo},
    );
  }

  /// Naviguer vers le login (remplacement)
  Future<void> replaceToLogin({String? redirectTo}) async {
    await navigator?.pushReplacementNamed(
      AppRoutes.login,
      arguments: {'redirect_to': redirectTo},
    );
  }

  /// Naviguer vers le home après connexion
  Future<void> navigateToHome() async {
    await replaceAndRemoveUntil(AppRoutes.home);
  }

  /// Naviguer vers le splash (déconnexion)
  Future<void> navigateToSplash() async {
    await navigateAndRemoveUntil(AppRoutes.splash);
  }

  // ============================================
  // NAVIGATION PAR RÔLE
  // ============================================

  /// Naviguer selon le rôle de l'utilisateur
  Future<void> navigateByRole({
    required bool isAdmin,
    required bool isSeller,
    required bool isClient,
  }) async {
    if (isAdmin) {
      await navigateToHome();
    } else if (isSeller) {
      await navigateToHome();
    } else if (isClient) {
      await navigateToHome();
    } else {
      await navigateToLogin();
    }
  }

  // ============================================
  // NAVIGATION AVEC PARAMÈTRES
  // ============================================

  /// Naviguer vers les détails d'un produit
  Future<void> navigateToProductDetail(int productId) async {
    await navigateTo(
      AppRoutes.productDetail,
      arguments: {'product_id': productId},
    );
  }

  /// Naviguer vers les détails d'une commande
  Future<void> navigateToOrderDetail(int orderId) async {
    await navigateTo(
      AppRoutes.orderDetail,
      arguments: {'order_id': orderId},
    );
  }

  /// Naviguer vers les détails d'une catégorie
  Future<void> navigateToCategoryDetail(int categoryId) async {
    await navigateTo(
      AppRoutes.categoryDetail,
      arguments: {'category_id': categoryId},
    );
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Vérifier si on peut retourner en arrière
  bool canGoBack() {
    return navigator?.canPop() ?? false;
  }

  /// Récupérer la route actuelle
  String? get currentRoute {
    if (context == null) return null;
    final route = ModalRoute.of(context!);
    return route?.settings.name;
  }

  /// Récupérer les arguments de la route actuelle
  Object? get currentArguments {
    if (context == null) return null;
    final route = ModalRoute.of(context!);
    return route?.settings.arguments;
  }

  /// Afficher un SnackBar global
  void showSnackBar(
    String message, {
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (context == null) return;

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  /// Afficher un SnackBar de succès
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Afficher un SnackBar d'erreur
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }
}