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
// IMPORTS PROVIDERS - LEGAL
// ============================================
// Provider utilisé par :
// - AboutScreen
// - TermsConditionsScreen
// - PrivacyPolicyScreen
// ============================================
import 'features/legal/presentation/providers/legal_provider.dart';

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
import 'features/support/presentation/providers/support_provider.dart';

// ============================================
// POINT D'ENTRÉE
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // INITIALISATION DU CLIENT HTTP
  // ============================================
  ApiClient().init();

  // ============================================
  // INITIALISATION DU PROVIDER D'AUTHENTIFICATION
  // ============================================
  final authProvider = AuthProvider();

  await authProvider.init();

  // ============================================
  // LANCEMENT DE L'APPLICATION
  // ============================================
  runApp(
    MultiProvider(
      providers: [
        // ============================================
        // PROVIDERS PRINCIPAUX
        // ============================================

        // Authentification
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
        ),

        // Produits
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),

        // Catégories
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),

        // Marques
        ChangeNotifierProvider<BrandProvider>(
          create: (_) => BrandProvider(),
        ),

        // Recherche
        ChangeNotifierProvider<SearchProvider>(
          create: (_) => SearchProvider(),
        ),

        // Panier
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),

        // Favoris
        ChangeNotifierProvider<FavoriteProvider>(
          create: (_) => FavoriteProvider(),
        ),

        // Commandes
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),

        // Adresses
        ChangeNotifierProvider<AddressProvider>(
          create: (_) => AddressProvider(),
        ),

        // Paiement
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),

        // Notifications
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),

        // Bannières
        ChangeNotifierProvider<BannerProvider>(
          create: (_) => BannerProvider(),
        ),

        // Stock
        ChangeNotifierProvider<StockProvider>(
          create: (_) => StockProvider(),
        ),

        ChangeNotifierProvider<SupportProvider>(
          create: (_) => SupportProvider(),
        ),

        // ============================================
        // PROVIDER - LEGAL
        // ============================================
        // Utilisé par :
        // - AboutScreen
        // - TermsConditionsScreen
        // - PrivacyPolicyScreen
        //
        // AVANT :
        // LegalProvider n'était pas enregistré ici.
        //
        // CONSÉQUENCE :
        // context.read<LegalProvider>()
        // et Consumer<LegalProvider>
        // provoquaient ProviderNotFoundException.
        // ============================================
        ChangeNotifierProvider<LegalProvider>(
          create: (_) => LegalProvider(),
        ),

        // ============================================
        // PROVIDERS ADMIN
        // ============================================

        // Dashboard administrateur
        ChangeNotifierProvider<AdminDashboardProvider>(
          create: (_) => AdminDashboardProvider(),
        ),

        // Produits administrateur
        ChangeNotifierProvider<AdminProductProvider>(
          create: (_) => AdminProductProvider(),
        ),

        // Catégories administrateur
        ChangeNotifierProvider<AdminCategoryProvider>(
          create: (_) => AdminCategoryProvider(),
        ),

        // Marques administrateur
        ChangeNotifierProvider<AdminBrandProvider>(
          create: (_) => AdminBrandProvider(),
        ),

        // Commandes administrateur
        ChangeNotifierProvider<AdminOrderProvider>(
          create: (_) => AdminOrderProvider(),
        ),

        // Utilisateurs administrateur
        ChangeNotifierProvider<AdminUserProvider>(
          create: (_) => AdminUserProvider(),
        ),

        // Stock administrateur
        ChangeNotifierProvider<AdminStockProvider>(
          create: (_) => AdminStockProvider(),
        ),

        // Promotions administrateur
        ChangeNotifierProvider<AdminPromotionProvider>(
          create: (_) => AdminPromotionProvider(),
        ),

        // Avis administrateur
        ChangeNotifierProvider<AdminReviewProvider>(
          create: (_) => AdminReviewProvider(),
        ),

        // Paramètres administrateur
        ChangeNotifierProvider<AdminSettingProvider>(
          create: (_) => AdminSettingProvider(),
        ),

        // Statistiques administrateur
        ChangeNotifierProvider<AdminStatsProvider>(
          create: (_) => AdminStatsProvider(),
        ),

        // Notifications administrateur
        ChangeNotifierProvider<AdminNotificationProvider>(
          create: (_) => AdminNotificationProvider(),
        ),
      ],

      // ============================================
      // APPLICATION SHOPPRO
      // ============================================
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

      // Supprime la bannière DEBUG
      debugShowCheckedModeBanner: false,

      // Thème principal
      theme: AppTheme.lightTheme,

      // Route initiale
      initialRoute: AppRoutes.splash,

      // Générateur de routes
      onGenerateRoute: RouteGenerator.generate,
    );
  }
}