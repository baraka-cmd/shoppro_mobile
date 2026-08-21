// Point d'entrée de l'application ShopPro
// Configuration initiale de Flutter, des providers et du thème

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
// ✅ Vérifie l'import
import 'features/orders/presentation/providers/order_provider.dart';



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