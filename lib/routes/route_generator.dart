// Générateur de routes avec protection
// Gère la navigation, les paramètres et la protection des routes

import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/forgot_password_screen.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/products/presentation/pages/product_detail_screen.dart';
import '../features/products/presentation/pages/product_list_screen.dart';
import 'app_routes.dart';
import '../features/categories/presentation/pages/category_detail_screen.dart';
import '../features/categories/presentation/pages/category_list_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
import '../features/cart/presentation/pages/cart_screen.dart';
import '../features/favorites/presentation/pages/favorites_screen.dart';

import '../features/orders/presentation/pages/orders_screen.dart';
import '../features/orders/presentation/pages/order_detail_screen.dart';
import '../features/orders/presentation/pages/checkout_screen.dart';


class RouteGenerator {
  static final RouteGenerator _instance = RouteGenerator._internal();
  factory RouteGenerator() => _instance;
  RouteGenerator._internal();

  /// Générer les routes selon le nom
  static Route<dynamic>? generate(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments as Map<String, dynamic>?;

    switch (routeName) {
      // ============================================
      // ROUTES PUBLIQUES
      // ============================================
      
      case AppRoutes.splash:
        return _buildRoute(
          settings: settings,
          page: const SplashScreen(),
        );

      case AppRoutes.onboarding:
        return _buildRoute(
          settings: settings,
          page: const OnboardingScreen(),
        );

      case AppRoutes.login:
        return _buildRoute(
          settings: settings,
          page: const LoginScreen(),
        );

      case AppRoutes.register:
        return _buildRoute(
          settings: settings,
          page: const RegisterScreen(),
        );

      case AppRoutes.forgotPassword:
        return _buildRoute(
          settings: settings,
          page: const ForgotPasswordScreen(),
        );

      case AppRoutes.home:
        return _buildRoute(
          settings: settings,
          page: const HomeScreen(),
        );

      case AppRoutes.favorites:
        return _buildRoute(
          settings: settings,
          page: const FavoritesScreen(),
        );

    // Dans le switch
    case AppRoutes.cart:
      return _buildRoute(
        settings: settings,
        page: const CartScreen(),
      );

      

// ✅ Vérifie ces cases
case AppRoutes.orders:
  return _buildRoute(
    settings: settings,
    page: const OrdersScreen(),
  );

case AppRoutes.orderDetail:
  final args = settings.arguments as Map<String, dynamic>?;
  return _buildRoute(
    settings: settings,
    page: OrderDetailScreen(orderId: args?['order_id'] as int? ?? 0),
  );

case AppRoutes.checkout:
  return _buildRoute(
    settings: settings,
    page: const CheckoutScreen(),
  );

      // ============================================
      // ROUTES PRODUITS
      // ============================================

      case AppRoutes.productDetail:
        final productId = arguments?['product_id'] ?? arguments?['id'] ?? 0;
        return _buildRoute(
          settings: settings,
          page: ProductDetailScreen(productId: productId as int),
        );

      case AppRoutes.productList:
        return _buildRoute(
          settings: settings,
          page: ProductListScreen(
            title: arguments?['title'] ?? 'Produits',
            categoryId: arguments?['category_id'] as int?,
            brandId: arguments?['brand_id'] as int?,
            searchQuery: arguments?['search_query'] as String?,
          ),
        );

        case AppRoutes.categoryDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings: settings,
          page: CategoryDetailScreen(
            categoryId: args?['category_id'] as int? ?? 0,
            categoryName: args?['category_name'] as String? ?? 'Catégorie',
          ),
        );



        // Dans le switch
        case AppRoutes.categoryList:
          return _buildRoute(
            settings: settings,
            page: const CategoryListScreen(),
          );

          case AppRoutes.productList:
          final args = settings.arguments as Map<String, dynamic>?;
          return _buildRoute(
            settings: settings,
            page: ProductListScreen(
              title: args?['title'] ?? 'Produits',
              categoryId: args?['category_id'] as int?,
              brandId: args?['brand_id'] as int?,
              searchQuery: args?['search_query'] as String?,
            ),
          );

          

        case AppRoutes.search:
          return _buildRoute(
            settings: settings,
            page: const SearchScreen(),
          );

        
      // ============================================
      // ROUTE PAR DÉFAUT
      // ============================================
      
      default:
        return _buildRoute(
          settings: settings,
          page: const SplashScreen(),
        );
    }
  }

  /// Construire une route simple avec animation
  static Route<dynamic> _buildRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }

  /// Construire une route protégée
  static Route<dynamic> _buildProtectedRoute({
    required RouteSettings settings,
    required Widget page,
    required String redirectTo,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FutureBuilder<bool>(
          future: _checkAuthentication(),
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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(
                  redirectTo,
                  arguments: {'redirect_to': settings.name},
                );
              }
            });

            return const Scaffold(
              body: SizedBox.shrink(),
            );
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Vérifier l'authentification
  static Future<bool> _checkAuthentication() async {
    return true;
  }

  // ============================================
  // ANIMATIONS PERSONNALISÉES
  // ============================================

  /// Animation de transition (fondu)
  static Route<dynamic> fadeRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// Animation de transition (glissement)
  static Route<dynamic> slideRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Animation de transition (zoom)
  static Route<dynamic> zoomRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}