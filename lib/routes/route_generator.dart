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
import 'role_route_guard.dart';

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
      // 🏠 ROUTE HOME
      // ============================================
      case AppRoutes.home:
        return _buildRoute(settings: settings, page: const HomeScreen());

      // ============================================
      // 🧭 ROUTE EXPLORER
      // ============================================
      case AppRoutes.explore:
        return _buildRoute(settings: settings, page: const CategoryListScreen());

      // ============================================
      // 🛒 ROUTE PANIER
      // ============================================
      case AppRoutes.cart:
        return _buildRoute(settings: settings, page: const CartScreen());

      // ============================================
      // 📦 ROUTE CHECKOUT
      // ============================================
      case AppRoutes.checkout:
        return _buildRoute(settings: settings, page: const CheckoutScreen());

      // ============================================
      // 📋 ROUTE COMMANDES
      // ============================================
      case AppRoutes.orders:
        return _buildRoute(settings: settings, page: const OrdersScreen());

      // ============================================
      // 📋 ROUTE DÉTAIL COMMANDE
      // ============================================
      case AppRoutes.orderDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings: settings,
          page: OrderDetailScreen(orderId: args?['order_id'] as int? ?? 0),
        );

      // ============================================
      // ❤️ ROUTE FAVORIS
      // ============================================
      case AppRoutes.favorites:
        return _buildRoute(settings: settings, page: const FavoritesScreen());

      // ============================================
      // 👤 ROUTE PROFIL
      // ============================================
      case AppRoutes.profile:
        return _buildRoute(settings: settings, page: const ProfileScreen());

      // ============================================
      // 👤 ROUTE ÉDITION PROFIL
      // ============================================
      case AppRoutes.editProfile:
        return _buildRoute(settings: settings, page: const EditProfileScreen());

      // ============================================
      // 🔒 ROUTE CHANGEMENT MOT DE PASSE
      // ============================================
      case AppRoutes.changePassword:
        return _buildRoute(settings: settings, page: const ChangePasswordScreen());

      // ============================================
      // 📍 ROUTE ADRESSES
      // ============================================
      case AppRoutes.addresses:
        return _buildRoute(settings: settings, page: const AddressListScreen());

      // ============================================
      // 📍 ROUTE FORMULAIRE ADRESSE
      // ============================================
      case AppRoutes.addressForm:
        return _buildRoute(settings: settings, page: const AddressFormScreen());

      // ============================================
      // 💳 ROUTE PAIEMENT
      // ============================================
      case AppRoutes.payment:
        return _buildRoute(
          settings: settings,
          page: PaymentScreen(order: arguments?['order']),
        );

      // ============================================
      // 🔔 ROUTE NOTIFICATIONS
      // ============================================
      case AppRoutes.notifications:
        return _buildRoute(settings: settings, page: const NotificationsScreen());

      // ============================================
      // 📦 ROUTE STOCK
      // ============================================
      case AppRoutes.stockDetail:
        return _buildRoute(
          settings: settings,
          page: StockDetailScreen(stockId: arguments?['stock_id'] as int? ?? 0),
        );

      // ============================================
      // 📦 ROUTE DÉTAIL PRODUIT
      // ============================================
      case AppRoutes.productDetail:
        final productId = arguments?['product_id'] ?? arguments?['id'] ?? 0;
        return _buildRoute(
          settings: settings,
          page: ProductDetailScreen(productId: productId as int),
        );

      // ============================================
      // 📦 ROUTE LISTE PRODUITS
      // ============================================
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

      // ============================================
      // 📦 ROUTE GRILLE PRODUITS
      // ============================================
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

      // ============================================
      // 🏷️ ROUTE DÉTAIL CATÉGORIE
      // ============================================
      case AppRoutes.categoryDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          settings: settings,
          page: CategoryDetailScreen(
            categoryId: args?['category_id'] as int? ?? 0,
            categoryName: args?['category_name'] as String? ?? 'Catégorie',
          ),
        );

      // ============================================
      // 🏷️ ROUTE LISTE CATÉGORIES
      // ============================================
      case AppRoutes.categoryList:
        return _buildRoute(settings: settings, page: const CategoryListScreen());

      // ============================================
      // 🔍 ROUTE RECHERCHE
      // ============================================
      case AppRoutes.search:
        return _buildRoute(settings: settings, page: const SearchScreen());

      // ============================================
      // 👑 ROUTE ADMIN - DASHBOARD
      // ============================================
      case AppRoutes.adminDashboard:
        return _buildRoute(settings: settings, page: const AdminDashboardScreen());

      // ============================================
      // 👑 ROUTE ADMIN - STATISTIQUES
      // ============================================
      case AppRoutes.adminStats:
        return _buildRoute(settings: settings, page: const AdminStatsScreen());

      // ============================================
      // 👑 ROUTE ADMIN - RAPPORT VENTES
      // ============================================
      case AppRoutes.adminSalesReport:
        return _buildRoute(settings: settings, page: const AdminSalesReportScreen());

      // ============================================
      // 👑 ROUTE ADMIN - NOTIFICATIONS
      // ============================================
      case AppRoutes.adminNotifications:
        return _buildRoute(settings: settings, page: const AdminNotificationsScreen());

      // ============================================
      // 👑 ROUTE ADMIN - PRODUITS
      // ============================================
      case AppRoutes.adminProducts:
        return _buildRoute(settings: settings, page: const AdminProductsScreen());

      // ============================================
      // 👑 ROUTE ADMIN - FORMULAIRE PRODUIT
      // ============================================
      case AppRoutes.adminProductForm:
        return _buildRoute(
          settings: settings,
          page: AdminProductFormScreen(productId: arguments?['product_id'] as int?),
        );

      // ============================================
      // 👑 ROUTE ADMIN - CATÉGORIES
      // ============================================
      case AppRoutes.adminCategories:
        return _buildRoute(settings: settings, page: const AdminCategoriesScreen());

      // ============================================
      // 👑 ROUTE ADMIN - FORMULAIRE CATÉGORIE
      // ============================================
      case AppRoutes.adminCategoryForm:
        return _buildRoute(
          settings: settings,
          page: AdminCategoryFormScreen(categoryId: arguments?['category_id'] as int?),
        );

      // ============================================
      // 👑 ROUTE ADMIN - MARQUES
      // ============================================
      case AppRoutes.adminBrands:
        return _buildRoute(settings: settings, page: const AdminBrandsScreen());

      // ============================================
      // 👑 ROUTE ADMIN - FORMULAIRE MARQUE
      // ============================================
      case AppRoutes.adminBrandForm:
        return _buildRoute(
          settings: settings,
          page: AdminBrandFormScreen(brandId: arguments?['brand_id'] as int?),
        );

      // ============================================
      // 👑 ROUTE ADMIN - COMMANDES
      // ============================================
      case AppRoutes.adminOrders:
        return _buildRoute(settings: settings, page: const AdminOrdersScreen());

      // ============================================
      // 👑 ROUTE ADMIN - DÉTAIL COMMANDE
      // ============================================
      case AppRoutes.adminOrderDetail:
        return _buildRoute(
          settings: settings,
          page: AdminOrderDetailScreen(orderId: arguments?['order_id'] as int? ?? 0),
        );

      // ============================================
      // 👑 ROUTE ADMIN - UTILISATEURS
      // ============================================
      case AppRoutes.adminUsers:
        return _buildRoute(settings: settings, page: const AdminUsersScreen());

      // ============================================
      // 👑 ROUTE ADMIN - DÉTAIL UTILISATEUR
      // ============================================
      case AppRoutes.adminUserDetail:
        return _buildRoute(
          settings: settings,
          page: AdminUserDetailScreen(userId: arguments?['user_id'] as int? ?? 0),
        );

      // ============================================
      // 👑 ROUTE ADMIN - STOCKS
      // ============================================
      case AppRoutes.adminStocks:
        return _buildRoute(settings: settings, page: const AdminStocksScreen());

      // ============================================
      // 👑 ROUTE ADMIN - PROMOTIONS
      // ============================================
      case AppRoutes.adminPromotions:
        return _buildRoute(settings: settings, page: const AdminPromotionsScreen());

      // ============================================
      // 👑 ROUTE ADMIN - FORMULAIRE PROMOTION
      // ============================================
      case AppRoutes.adminPromotionForm:
        return _buildRoute(
          settings: settings,
          page: AdminPromotionFormScreen(promotionId: arguments?['promotion_id'] as int?),
        );

      // ============================================
      // 👑 ROUTE ADMIN - AVIS
      // ============================================
      case AppRoutes.adminReviews:
        return _buildRoute(settings: settings, page: const AdminReviewsScreen());

      // ============================================
      // 👑 ROUTE ADMIN - BANNIÈRES
      // ============================================
      case AppRoutes.adminBanners:
        return _buildRoute(settings: settings, page: const AdminBannersScreen());

      // ============================================
      // 👑 ROUTE ADMIN - FORMULAIRE BANNIÈRE
      // ============================================
      case AppRoutes.adminBannerForm:
        return _buildRoute(
          settings: settings,
          page: AdminBannerFormScreen(bannerId: arguments?['banner_id'] as int?),
        );

      // ============================================
      // 👑 ROUTE ADMIN - PARAMÈTRES
      // ============================================
      case AppRoutes.adminSettings:
        return _buildRoute(settings: settings, page: const AdminSettingsScreen());

      // ============================================
      // 🏪 ROUTE VENDEUR - DASHBOARD
      // ============================================
      case AppRoutes.sellerDashboard:
        return _buildRoute(settings: settings, page: const SplashScreen());

      // ============================================
      // 🏪 ROUTE VENDEUR - PRODUITS
      // ============================================
      case AppRoutes.sellerProducts:
        return _buildRoute(settings: settings, page: const SplashScreen());

      // ============================================
      // 🏪 ROUTE VENDEUR - COMMANDES
      // ============================================
      case AppRoutes.sellerOrders:
        return _buildRoute(settings: settings, page: const SplashScreen());

      // ============================================
      // 🏪 ROUTE VENDEUR - STATISTIQUES
      // ============================================
      case AppRoutes.sellerStats:
        return _buildRoute(settings: settings, page: const SplashScreen());

      // ============================================
      // ROUTE PAR DÉFAUT
      // ============================================
      default:
        return _buildRoute(settings: settings, page: const SplashScreen());
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
}