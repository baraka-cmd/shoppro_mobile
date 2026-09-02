📦 FICHIER : docs/09-fichiers-cles.md (Flutter)

---

```markdown
# 🔑 FICHIERS CLÉS - SHOPPRO MOBILE

---

## 📋 FICHIERS ESSENTIELS POUR LA REPRISE

Ce fichier contient le contenu EXACT des fichiers les plus importants pour que le nouveau chat comprenne parfaitement le projet.

---

## 1. `lib/main.dart`

```dart
// Point d'entrée de l'application ShopPro

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/products/presentation/providers/category_provider.dart';
import 'features/products/presentation/providers/brand_provider.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/favorites/presentation/providers/favorite_provider.dart';
import 'features/orders/presentation/providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  ApiClient().init();
  
  final authProvider = AuthProvider();
  await authProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
        ChangeNotifierProvider<CategoryProvider>(create: (_) => CategoryProvider()),
        ChangeNotifierProvider<BrandProvider>(create: (_) => BrandProvider()),
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<FavoriteProvider>(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
      ],
      child: const ShopProApp(),
    ),
  );
}

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
```

---

2. lib/routes/app_routes.dart

```dart
// Routes de l'application

class AppRoutes {
  // 🚀 Démarrage
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  
  // 🔐 Authentification
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // 🏠 Principal
  static const String home = '/home';
  
  // 👤 Profil
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  
  // 🛒 Panier & Commandes
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order/detail';
  
  // ❤️ Favoris
  static const String favorites = '/favorites';
  
  // 📍 Adresses
  static const String addresses = '/addresses';
  
  // 📦 Produits & Catégories
  static const String productList = '/product/list';
  static const String productDetail = '/product/detail';
  static const String productGrid = '/product/grid';
  static const String categoryDetail = '/category/detail';
  static const String categoryList = '/categories';
  
  // 🔍 Recherche
  static const String search = '/search';
  
  // 👑 Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProducts = '/admin/products';
  static const String adminUsers = '/admin/users';
  static const String adminOrders = '/admin/orders';
  static const String adminSettings = '/admin/settings';

  // 🏪 Vendeur
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String sellerOrders = '/seller/orders';
  static const String sellerStats = '/seller/stats';
}
```

---

3. lib/routes/route_generator.dart (PARTIE IMPORTANTE)

```dart
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/forgot_password_screen.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/products/presentation/pages/product_detail_screen.dart';
import '../features/products/presentation/pages/product_list_screen.dart';
import '../features/categories/presentation/pages/category_list_screen.dart';
import '../features/categories/presentation/pages/category_detail_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
import '../features/cart/presentation/pages/cart_screen.dart';
import '../features/favorites/presentation/pages/favorites_screen.dart';
import '../features/orders/presentation/pages/orders_screen.dart';
import '../features/orders/presentation/pages/order_detail_screen.dart';
import '../features/orders/presentation/pages/checkout_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic>? generate(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments as Map<String, dynamic>?;

    switch (routeName) {
      case AppRoutes.splash:
        return _buildRoute(settings: settings, page: const SplashScreen());
      case AppRoutes.onboarding:
        return _buildRoute(settings: settings, page: const OnboardingScreen());
      case AppRoutes.login:
        return _buildRoute(settings: settings, page: const LoginScreen());
      case AppRoutes.register:
        return _buildRoute(settings: settings, page: const RegisterScreen());
      case AppRoutes.forgotPassword:
        return _buildRoute(settings: settings, page: const ForgotPasswordScreen());
      case AppRoutes.home:
        return _buildRoute(settings: settings, page: const HomeScreen());
      case AppRoutes.productDetail:
        return _buildRoute(
          settings: settings,
          page: ProductDetailScreen(productId: arguments?['product_id'] as int? ?? 0),
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
      case AppRoutes.categoryList:
        return _buildRoute(settings: settings, page: const CategoryListScreen());
      case AppRoutes.categoryDetail:
        return _buildRoute(
          settings: settings,
          page: CategoryDetailScreen(
            categoryId: arguments?['category_id'] as int? ?? 0,
            categoryName: arguments?['category_name'] as String? ?? 'Catégorie',
          ),
        );
      case AppRoutes.search:
        return _buildRoute(settings: settings, page: const SearchScreen());
      case AppRoutes.cart:
        return _buildRoute(settings: settings, page: const CartScreen());
      case AppRoutes.favorites:
        return _buildRoute(settings: settings, page: const FavoritesScreen());
      case AppRoutes.orders:
        return _buildRoute(settings: settings, page: const OrdersScreen());
      case AppRoutes.orderDetail:
        return _buildRoute(
          settings: settings,
          page: OrderDetailScreen(orderId: arguments?['order_id'] as int? ?? 0),
        );
      case AppRoutes.checkout:
        return _buildRoute(settings: settings, page: const CheckoutScreen());
      default:
        return _buildRoute(settings: settings, page: const SplashScreen());
    }
  }

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
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
```

---

4. lib/core/constants/api_constants.dart

```dart
class ApiConstants {
  // Pour téléphone USB avec adb reverse
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  
  // Products
  static const String products = '/products';
  static const String featuredProducts = '/products/featured';
  static const String popularProducts = '/products/popular';
  static const String recentProducts = '/products/recent';
  static const String onSaleProducts = '/products/on-sale';
  static const String searchProducts = '/products/search';
  static const String filterProducts = '/products/filter';
  
  // Categories
  static const String categories = '/categories';
  static const String categoryProducts = '/categories/';
  
  // Brands
  static const String brands = '/brands';
  static const String brandProducts = '/brands/';
}
```

---

5. COMMANDES SPÉCIALES (Téléphone USB)

```bash
# Activer le reverse USB pour l'API
cd C:\Users\barak\AppData\Local\Android\Sdk\platform-tools
.\adb reverse tcp:8000 tcp:8000

# Vérifier le téléphone connecté
.\adb devices

# Lancer l'application
cd C:\Users\barak\shoppro_mobile
flutter run
```

---

6. BUGS CONNUS ET SOLUTIONS

Bug 1 : package_delivered n'existe pas

```dart
// ❌ Icons.package_delivered
// ✅ Icons.check_circle
```

Bug 2 : SearchBar conflit avec Flutter

```dart
// ✅ Renommer en CustomSearchBar
class CustomSearchBar extends StatefulWidget { ... }
```

Bug 3 : ProductVariant type argument

```dart
// ✅ Ajouter dans variation_selector.dart
class ProductVariant { ... }
```

Bug 4 : addToRecentlyViewed doit être static

```dart
// ✅ Dans la classe RecentlyViewedSection (pas le State)
static Future<void> addToRecentlyViewed(Product product) async { ... }
```

Bug 5 : fullImageUrl dans Product

```dart
// ✅ Ajouter le getter dans l'entité Product
String get fullImageUrl {
  if (mainImage == null || mainImage!.isEmpty) return '';
  if (mainImage!.startsWith('http')) return mainImage!;
  return 'http://127.0.0.1:8000/storage/$mainImage';
}
```

---

7. COMPTES DE TEST

Rôle Email Password
Admin admin@shoppro.com password123
Vendeur vendeur@shoppro.com password123
Client jean@example.com password123
Client marie@example.com password123

```

---

## 📋 RÉSUMÉ

Ce fichier contient :
- ✅ Le contenu exact de `main.dart`
- ✅ Le contenu exact de `app_routes.dart`
- ✅ Le contenu exact de `route_generator.dart`
- ✅ Le contenu exact de `api_constants.dart`
- ✅ Les commandes USB
- ✅ Les bugs connus et solutions
- ✅ Les comptes de test

---

**Maintenant le nouveau chat aura TOUT ce qu'il faut !** 🚀