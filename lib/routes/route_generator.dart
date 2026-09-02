// ============================================
// GÉNÉRATEUR DE ROUTES AVEC PROTECTION
// ============================================
// Gère la navigation, les paramètres et la
// protection des routes selon le rôle utilisateur.
// ============================================

// ============================================
// IMPORTS FLUTTER
// ============================================
import 'package:flutter/material.dart';

// ============================================
// IMPORTS ROUTES
// ============================================
import 'app_routes.dart';

// ============================================
// IMPORTS AUTH
// ============================================
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/forgot_password_screen.dart';

// ============================================
// IMPORTS HOME
// ============================================
import '../features/home/presentation/pages/home_screen.dart';

// ============================================
// IMPORTS PRODUITS
// ============================================
import '../features/products/presentation/pages/product_detail_screen.dart';
import '../features/products/presentation/pages/product_list_screen.dart';
import '../features/products/presentation/pages/product_grid_screen.dart';

// ============================================
// IMPORTS CATÉGORIES
// ============================================
import '../features/categories/presentation/pages/category_detail_screen.dart';
import '../features/categories/presentation/pages/category_list_screen.dart';

// ============================================
// IMPORTS RECHERCHE
// ============================================
import '../features/search/presentation/pages/search_screen.dart';

// ============================================
// IMPORTS PANIER & COMMANDES
// ============================================
import '../features/cart/presentation/pages/cart_screen.dart';
import '../features/favorites/presentation/pages/favorites_screen.dart';
import '../features/orders/presentation/pages/orders_screen.dart';
import '../features/orders/presentation/pages/order_detail_screen.dart';
import '../features/orders/presentation/pages/checkout_screen.dart';

// ============================================
// IMPORTS PROFIL
// ============================================
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/profile/presentation/pages/edit_profile_screen.dart';
import '../features/profile/presentation/pages/change_password_screen.dart';

// ============================================
// IMPORTS ADRESSES & PAIEMENT
// ============================================
import '../features/addresses/presentation/pages/address_list_screen.dart';
import '../features/addresses/presentation/pages/address_form_screen.dart';
import '../features/payment/presentation/pages/payment_screen.dart';

// ============================================
// IMPORTS NOTIFICATIONS & STOCK
// ============================================
import '../features/notifications/presentation/pages/notifications_screen.dart';
import '../features/stock/presentation/pages/stock_detail_screen.dart';

// ============================================
// IMPORTS ADMIN - DASHBOARD
// ============================================
import '../features/admin/presentation/pages/admin_dashboard_screen.dart';
import '../features/admin/presentation/pages/admin_stats_screen.dart';
import '../features/admin/presentation/pages/admin_sales_report_screen.dart';
import '../features/admin/presentation/pages/admin_notifications_screen.dart';

// ============================================
// IMPORTS ADMIN - PRODUITS & CATÉGORIES & MARQUES
// ============================================
import '../features/admin/presentation/pages/admin_products_screen.dart';
import '../features/admin/presentation/pages/admin_product_form_screen.dart';
import '../features/admin/presentation/pages/admin_categories_screen.dart';
import '../features/admin/presentation/pages/admin_category_form_screen.dart';
import '../features/admin/presentation/pages/admin_brands_screen.dart';
import '../features/admin/presentation/pages/admin_brand_form_screen.dart';

// ============================================
// IMPORTS ADMIN - COMMANDES & UTILISATEURS
// ============================================
import '../features/admin/presentation/pages/admin_orders_screen.dart';
import '../features/admin/presentation/pages/admin_order_detail_screen.dart';
import '../features/admin/presentation/pages/admin_users_screen.dart';
import '../features/admin/presentation/pages/admin_user_detail_screen.dart';

// ============================================
// IMPORTS ADMIN - STOCKS & PROMOTIONS
// ============================================
import '../features/admin/presentation/pages/admin_stocks_screen.dart';
import '../features/admin/presentation/pages/admin_promotions_screen.dart';
import '../features/admin/presentation/pages/admin_promotion_form_screen.dart';

// ============================================
// IMPORTS ADMIN - AVIS & BANNIÈRES & PARAMÈTRES
// ============================================
import '../features/admin/presentation/pages/admin_reviews_screen.dart';
import '../features/admin/presentation/pages/admin_banners_screen.dart';
import '../features/admin/presentation/pages/admin_banner_form_screen.dart';
import '../features/admin/presentation/pages/admin_settings_screen.dart';

// ============================================
// IMPORTS SERVICES
// ============================================
import '../core/services/token_service.dart';
import '../core/services/navigation_service.dart';

// ============================================
// CLASSE PRINCIPALE
// ============================================

class RouteGenerator {
  // ============================================
  // GÉNÉRATION DES ROUTES
  // ============================================

  static Route<dynamic>? generate(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments as Map<String, dynamic>?;

    switch (routeName) {
      // ============================================
      // 🚀 ROUTES DE DÉMARRAGE (publiques)
      // ============================================
      case AppRoutes.splash:
        return _buildRoute(settings: settings, page: const SplashScreen());

      case AppRoutes.onboarding:
        return _buildRoute(settings: settings, page: const OnboardingScreen());

      // ============================================
      // 🔐 ROUTES AUTHENTIFICATION (publiques)
      // ============================================
      case AppRoutes.login:
        return _buildRoute(settings: settings, page: const LoginScreen());

      case AppRoutes.register:
        return _buildRoute(settings: settings, page: const RegisterScreen());

      case AppRoutes.forgotPassword:
        return _buildRoute(settings: settings, page: const ForgotPasswordScreen());

      // ============================================
      // 🏠 ROUTES CLIENT (protégées)
      // ============================================
      case AppRoutes.home:
        return _buildProtectedRoute(
          settings: settings,
          page: const HomeScreen(),
        );

      case AppRoutes.explore:
        return _buildProtectedRoute(
          settings: settings,
          page: const CategoryListScreen(),
        );

      case AppRoutes.cart:
        return _buildProtectedRoute(
          settings: settings,
          page: const CartScreen(),
        );

      case AppRoutes.checkout:
        return _buildProtectedRoute(
          settings: settings,
          page: const CheckoutScreen(),
        );

      case AppRoutes.orders:
        return _buildProtectedRoute(
          settings: settings,
          page: const OrdersScreen(),
        );

      case AppRoutes.orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildProtectedRoute(
          settings: settings,
          page: OrderDetailScreen(orderId: args?['order_id'] as int? ?? 0),
        );

      // ============================================
      // ❤️ ROUTES FAVORIS (protégées)
      // ============================================
      case AppRoutes.favorites:
        return _buildProtectedRoute(
          settings: settings,
          page: const FavoritesScreen(),
        );

      // ============================================
      // 👤 ROUTES PROFIL (protégées)
      // ============================================
      case AppRoutes.profile:
        return _buildProtectedRoute(
          settings: settings,
          page: const ProfileScreen(),
        );

      case AppRoutes.editProfile:
        return _buildProtectedRoute(
          settings: settings,
          page: const EditProfileScreen(),
        );

      case AppRoutes.changePassword:
        return _buildProtectedRoute(
          settings: settings,
          page: const ChangePasswordScreen(),
        );

      // ============================================
      // 📍 ROUTES ADRESSES (protégées)
      // ============================================
      case AppRoutes.addresses:
        return _buildProtectedRoute(
          settings: settings,
          page: const AddressListScreen(),
        );

      case AppRoutes.addressForm:
        return _buildProtectedRoute(
          settings: settings,
          page: const AddressFormScreen(),
        );

      // ============================================
      // 💳 ROUTE PAIEMENT (protégée)
      // ============================================
      case AppRoutes.payment:
        return _buildProtectedRoute(
          settings: settings,
          page: PaymentScreen(order: arguments?['order']),
        );

      // ============================================
      // 🔔 ROUTE NOTIFICATIONS (protégée)
      // ============================================
      case AppRoutes.notifications:
        return _buildProtectedRoute(
          settings: settings,
          page: const NotificationsScreen(),
        );

      // ============================================
      // 📦 ROUTE STOCK (protégée)
      // ============================================
      case AppRoutes.stockDetail:
        return _buildProtectedRoute(
          settings: settings,
          page: StockDetailScreen(stockId: arguments?['stock_id'] as int? ?? 0),
        );

      // ============================================
      // 📦 ROUTES PRODUITS & CATÉGORIES (publiques)
      // ============================================
      case AppRoutes.productDetail:
        final productId = arguments?['product_id'] ?? arguments?['id'] ?? 0;
        return _buildRoute(
          settings: settings,
          page: ProductDetailScreen(productId: productId as int),
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

      case AppRoutes.productGrid:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings: settings,
          page: ProductGridScreen(
            title: args?['title'] ?? 'Produits',
            categoryId: args?['category_id'] as int?,
            brandId: args?['brand_id'] as int?,
            searchQuery: args?['search_query'] as String?,
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

      case AppRoutes.categoryList:
        return _buildRoute(
          settings: settings,
          page: const CategoryListScreen(),
        );

      // ============================================
      // 🔍 ROUTE RECHERCHE (publique)
      // ============================================
      case AppRoutes.search:
        return _buildRoute(
          settings: settings,
          page: const SearchScreen(),
        );

      // ============================================
      // 👑 ROUTES ADMIN (protégées - admin uniquement)
      // ============================================
      case AppRoutes.adminDashboard:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminDashboardScreen(),
        );

      case AppRoutes.adminStats:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminStatsScreen(),
        );

      case AppRoutes.adminSalesReport:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminSalesReportScreen(),
        );

      case AppRoutes.adminNotifications:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminNotificationsScreen(),
        );

      case AppRoutes.adminProducts:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminProductsScreen(),
        );

      case AppRoutes.adminProductForm:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminProductFormScreen(productId: arguments?['product_id'] as int?),
        );

      case AppRoutes.adminCategories:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminCategoriesScreen(),
        );

      case AppRoutes.adminCategoryForm:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminCategoryFormScreen(categoryId: arguments?['category_id'] as int?),
        );

      case AppRoutes.adminBrands:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminBrandsScreen(),
        );

      case AppRoutes.adminBrandForm:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminBrandFormScreen(brandId: arguments?['brand_id'] as int?),
        );

      case AppRoutes.adminOrders:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminOrdersScreen(),
        );

      case AppRoutes.adminOrderDetail:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminOrderDetailScreen(orderId: arguments?['order_id'] as int? ?? 0),
        );

      case AppRoutes.adminUsers:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminUsersScreen(),
        );

      case AppRoutes.adminUserDetail:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminUserDetailScreen(userId: arguments?['user_id'] as int? ?? 0),
        );

      case AppRoutes.adminStocks:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminStocksScreen(),
        );

      case AppRoutes.adminPromotions:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminPromotionsScreen(),
        );

      case AppRoutes.adminPromotionForm:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminPromotionFormScreen(promotionId: arguments?['promotion_id'] as int?),
        );

      case AppRoutes.adminReviews:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminReviewsScreen(),
        );

      case AppRoutes.adminBanners:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminBannersScreen(),
        );

      case AppRoutes.adminBannerForm:
        return _buildProtectedRoute(
          settings: settings,
          page: AdminBannerFormScreen(bannerId: arguments?['banner_id'] as int?),
        );

      case AppRoutes.adminSettings:
        return _buildProtectedRoute(
          settings: settings,
          page: const AdminSettingsScreen(),
        );

      // ============================================
      // 🏪 ROUTES VENDEUR
      // ============================================
      case AppRoutes.sellerDashboard:
        return _buildProtectedRoute(
          settings: settings,
          page: const SplashScreen(), // À remplacer par SellerDashboardScreen
        );

      case AppRoutes.sellerProducts:
        return _buildProtectedRoute(
          settings: settings,
          page: const SplashScreen(), // À remplacer par SellerProductsScreen
        );

      case AppRoutes.sellerOrders:
        return _buildProtectedRoute(
          settings: settings,
          page: const SplashScreen(), // À remplacer par SellerOrdersScreen
        );

      case AppRoutes.sellerStats:
        return _buildProtectedRoute(
          settings: settings,
          page: const SplashScreen(), // À remplacer par SellerStatsScreen
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

  // ============================================
  // CONSTRUCTION DE ROUTE SIMPLE
  // ============================================

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
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }

  // ============================================
  // CONSTRUCTION DE ROUTE PROTÉGÉE
  // ============================================

  static Route<dynamic> _buildProtectedRoute({
    required RouteSettings settings,
    required Widget page,
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

            // Non authentifié → rediriger vers login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.login,
                  arguments: {'redirect_to': settings.name},
                );
              }
            });

            return const Scaffold(body: SizedBox.shrink());
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  // ============================================
  // VÉRIFICATION DE L'AUTHENTIFICATION
  // ============================================

  static Future<bool> _checkAuthentication() async {
    final tokenService = TokenService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    return await tokenService.isTokenValid();
  }
}