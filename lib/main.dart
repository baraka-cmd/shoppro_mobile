// ============================================
// POINT D'ENTRÉE DE L'APPLICATION SHOPPRO
// ============================================
// Configuration initiale de Flutter, des providers et du thème.
// ============================================

// ============================================
// IMPORTS FLUTTER & PACKAGES
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================
// IMPORTS CORE
// ============================================
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

// ============================================
// IMPORTS PROVIDERS - AUTH
// ============================================
import 'features/auth/presentation/providers/auth_provider.dart';

// ============================================
// IMPORTS PROVIDERS - PRODUITS & CATÉGORIES
// ============================================
import 'features/products/presentation/providers/product_provider.dart';
import 'features/products/presentation/providers/category_provider.dart';
import 'features/products/presentation/providers/brand_provider.dart';

// ============================================
// IMPORTS PROVIDERS - RECHERCHE
// ============================================
import 'features/search/presentation/providers/search_provider.dart';

// ============================================
// IMPORTS PROVIDERS - PANIER & FAVORIS
// ============================================
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/favorites/presentation/providers/favorite_provider.dart';

// ============================================
// IMPORTS PROVIDERS - COMMANDES & ADRESSES
// ============================================
import 'features/orders/presentation/providers/order_provider.dart';
import 'features/addresses/presentation/providers/address_provider.dart';

// ============================================
// IMPORTS PROVIDERS - PAIEMENT & NOTIFICATIONS
// ============================================
import 'features/payment/presentation/providers/payment_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';

// ============================================
// IMPORTS PROVIDERS - BANNIÈRES & STOCK
// ============================================
import 'features/home/presentation/providers/banner_provider.dart';
import 'features/stock/presentation/providers/stock_provider.dart';

// ============================================
// IMPORTS PROVIDERS - ADMIN
// ============================================
import 'features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'features/admin/presentation/providers/admin_product_provider.dart';
import 'features/admin/presentation/providers/admin_category_provider.dart';
import 'features/admin/presentation/providers/admin_brand_provider.dart';
import 'features/admin/presentation/providers/admin_order_provider.dart';
import 'features/admin/presentation/providers/admin_user_provider.dart';
import 'features/admin/presentation/providers/admin_stock_provider.dart';
import 'features/admin/presentation/providers/admin_promotion_provider.dart';
import 'features/admin/presentation/providers/admin_review_provider.dart';
import 'features/admin/presentation/providers/admin_setting_provider.dart';
import 'features/admin/presentation/providers/admin_stats_provider.dart';
import 'features/admin/presentation/providers/admin_notification_provider.dart';

// ============================================
// POINT D'ENTRÉE
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le client HTTP
  ApiClient().init();

  // Initialiser le provider d'authentification
  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        // ============================================
        // PROVIDERS PRINCIPAUX
        // ============================================
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider<BrandProvider>(
          create: (_) => BrandProvider(),
        ),
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider<AddressProvider>(
          create: (_) => AddressProvider(),
        ),
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<BannerProvider>(
          create: (_) => BannerProvider(),
        ),
        ChangeNotifierProvider<StockProvider>(
          create: (_) => StockProvider(),
        ),

        // ============================================
        // PROVIDERS ADMIN
        // ============================================
        ChangeNotifierProvider<AdminDashboardProvider>(
          create: (_) => AdminDashboardProvider(),
        ),
        ChangeNotifierProvider<AdminProductProvider>(
          create: (_) => AdminProductProvider(),
        ),
        ChangeNotifierProvider<AdminCategoryProvider>(
          create: (_) => AdminCategoryProvider(),
        ),
        ChangeNotifierProvider<AdminBrandProvider>(
          create: (_) => AdminBrandProvider(),
        ),
        ChangeNotifierProvider<AdminOrderProvider>(
          create: (_) => AdminOrderProvider(),
        ),
        ChangeNotifierProvider<AdminUserProvider>(
          create: (_) => AdminUserProvider(),
        ),
        ChangeNotifierProvider<AdminStockProvider>(
          create: (_) => AdminStockProvider(),
        ),
        ChangeNotifierProvider<AdminPromotionProvider>(
          create: (_) => AdminPromotionProvider(),
        ),
        ChangeNotifierProvider<AdminReviewProvider>(
          create: (_) => AdminReviewProvider(),
        ),
        ChangeNotifierProvider<AdminSettingProvider>(
          create: (_) => AdminSettingProvider(),
        ),
        ChangeNotifierProvider<AdminStatsProvider>(
          create: (_) => AdminStatsProvider(),
        ),
        ChangeNotifierProvider<AdminNotificationProvider>(
          create: (_) => AdminNotificationProvider(),
        ),
      ],
      child: const ShopProApp(),
    ),
  );
}

// ============================================
// APPLICATION PRINCIPALE
// ============================================

class ShopProApp extends StatelessWidget {
  const ShopProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generate,
    );
  }
}