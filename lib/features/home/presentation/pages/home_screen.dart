// ============================================
// ÉCRAN D'ACCUEIL - VERSION FINALE PRO
// ============================================
// Assemble toutes les sections :
// - HomeAppBar (salutation + recherche + badges)
// - BannerCarousel (hero auto-play)
// - CategoryGrid (navigation rapide)
// - FlashSaleSection (urgence avec timer)
// - BestSellersSection (confiance)
// - RecommendedSection (personnalisation)
// - BlogSection (inspiration)
// - AdBanner (publicités intégrées)
// - Bottom Navigation flottante
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/presentation/providers/category_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../favorites/domain/entities/favorite.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../navigation/presentation/widgets/role_based_navigation.dart';
import '../providers/banner_provider.dart';
import '../widgets/home_appbar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_grid.dart';
import '../widgets/flash_sale_section.dart';
import '../widgets/best_sellers_section.dart';
import '../widgets/recommended_section.dart';
import '../widgets/blog_section.dart';
import '../widgets/ad_banner.dart';

// ============================================
// ÉCRAN PRINCIPAL
// ============================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================
// STATE
// ============================================

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ============================================
  // CHARGEMENT DES DONNÉES
  // ============================================

  Future<void> _loadAllData() async {
    // Charger en parallèle pour plus de rapidité
    await Future.wait([
      context.read<BannerProvider>().loadBanners(),
      context.read<ProductProvider>().loadFeaturedProducts(),
      context.read<ProductProvider>().loadPopularProducts(),
      context.read<ProductProvider>().loadOnSaleProducts(),
      context.read<CategoryProvider>().loadCategories(),
      context.read<CartProvider>().loadCart(),
      context.read<FavoriteProvider>().loadFavorites(),
      context.read<NotificationProvider>().loadNotifications(),
    ]);
  }

  // ============================================
  // REFRESH (PULL-TO-REFRESH)
  // ============================================

  Future<void> _refreshHome() async {
    await _loadAllData();
  }

  // ============================================
  // NAVIGATION PRINCIPALE
  // ============================================

  void _onNavItemSelected(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0: // Accueil
        // Déjà sur l'accueil, ne rien faire
        break;
      case 1: // Explorer
        Navigator.of(context).pushNamed(AppRoutes.categoryList);
        _resetNavIndex();
        break;
      case 2: // Favoris
        Navigator.of(context).pushNamed(AppRoutes.favorites);
        _resetNavIndex();
        break;
      case 3: // Panier
        Navigator.of(context).pushNamed(AppRoutes.cart);
        _resetNavIndex();
        break;
      case 4: // Profil
        Navigator.of(context).pushNamed(AppRoutes.profile);
        _resetNavIndex();
        break;
    }
  }

  void _resetNavIndex() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentNavIndex = 0;
        });
      }
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final bannerProvider = context.watch<BannerProvider>();
    final cartProvider = context.watch<CartProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ============================================
            // CONTENU PRINCIPAL (SCROLLABLE)
            // ============================================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshHome,
                color: AppColors.primary,
                backgroundColor: Colors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ============================================
                    // APP BAR (STICKY)
                    // ============================================
                    SliverToBoxAdapter(
                      child: HomeAppBar(
                        userName: authProvider.user?.fullName ?? 'Client',
                      ),
                    ),

                    // ============================================
                    // CONTENU PRINCIPAL
                    // ============================================
                    SliverToBoxAdapter(
                      child: _buildContent(
                        productProvider,
                        categoryProvider,
                        bannerProvider,
                      ),
                    ),

                    // ============================================
                    // ESPACE EN BAS (pour la barre flottante)
                    // ============================================
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================================
      // BOTTOM NAVIGATION FLOTTANTE
      // ============================================
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ============================================
  // BOTTOM NAVIGATION
  // ============================================

  Widget _buildBottomNavigation(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();

    final items = RoleNavigationItems.clientItems.map((item) {
      // Mettre à jour les badges dynamiquement
      if (item.label == 'Panier') {
        return NavigationItem(
          label: item.label,
          icon: item.icon,
          selectedIcon: item.selectedIcon,
          selectedColor: item.selectedColor,
          unselectedColor: item.unselectedColor,
          badgeCount: cartProvider.totalQuantity,
          onTap: item.onTap,
        );
      }
      if (item.label == 'Favoris') {
        return NavigationItem(
          label: item.label,
          icon: item.icon,
          selectedIcon: item.selectedIcon,
          selectedColor: item.selectedColor,
          unselectedColor: item.unselectedColor,
          badgeCount: favoriteProvider.favoritesCount,
          onTap: item.onTap,
        );
      }
      return item;
    }).toList();

    return RoleBasedNavigation(
      roleItems: {
        UserRole.client: items,
        UserRole.guest: items,
      },
      onItemSelected: _onNavItemSelected,
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(
    ProductProvider productProvider,
    CategoryProvider categoryProvider,
    BannerProvider bannerProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ============================================
        // 1. BANNER CAROUSEL (HERO)
        // ============================================
        if (bannerProvider.banners.isNotEmpty)
          BannerCarousel(
            banners: bannerProvider.banners,
            height: 170,
            onBannerTap: (banner) {
              _handleBannerTap(banner);
            },
          ),

        const SizedBox(height: 15),

        // ============================================
        // 2. CATEGORY GRID
        // ============================================
        if (categoryProvider.categories.isNotEmpty)
          CategoryGrid(
            categories: categoryProvider.categories.take(8).toList(),
            onCategoryTap: (category) {
              Navigator.of(context).pushNamed(
                AppRoutes.categoryDetail,
                arguments: {
                  'category_id': category.id,
                  'category_name': category.name,
                },
              );
            },
          ),

        const SizedBox(height: 15),

        // ============================================
        // 3. FLASH SALE
        // ============================================
        if (productProvider.onSaleProducts.isNotEmpty)
          FlashSaleSection(
            products: productProvider.onSaleProducts.take(6).toList(),
            endTime: DateTime.now().add(const Duration(hours: 5)),
            onSeeAllTap: () {
              Navigator.of(context).pushNamed(AppRoutes.productList, arguments: {
                'title': 'Ventes Flash',
                'on_sale': true,
              });
            },
            onProductTap: (product) => _navigateToProduct(product.id),
          ),

        const SizedBox(height: 15),

        // ============================================
        // 4. MEILLEURES VENTES
        // ============================================
        if (productProvider.popularProducts.isNotEmpty)
          BestSellersSection(
            products: productProvider.popularProducts.take(6).toList(),
            onSeeAllTap: () {
              Navigator.of(context).pushNamed(AppRoutes.productList, arguments: {
                'title': 'Meilleures ventes',
              });
            },
            onProductTap: (product) => _navigateToProduct(product.id),
            onToggleFavorite: (product) => _toggleFavorite(product),
          ),

        const SizedBox(height: 15),

        // ============================================
        // 5. BANNIÈRE PUBLICITAIRE
        // ============================================
        const AdBanner(
          title: 'Livraison gratuite',
          subtitle: 'Dès 50 000 FCFA d\'achat',
          icon: Icons.local_shipping_outlined,
          backgroundColor: AppColors.success,
          buttonText: 'En savoir plus',
        ),

        const SizedBox(height: 15),

        // ============================================
        // 6. RECOMMANDÉS
        // ============================================
        if (productProvider.featuredProducts.isNotEmpty)
          RecommendedSection(
            products: productProvider.featuredProducts.take(4).toList(),
            contextMessage: 'Sélection personnalisée pour vous',
            onSeeAllTap: () {
              Navigator.of(context).pushNamed(AppRoutes.productList, arguments: {
                'title': 'Pour vous',
              });
            },
            onProductTap: (product) => _navigateToProduct(product.id),
            onToggleFavorite: (product) => _toggleFavorite(product),
          ),

        const SizedBox(height: 15),

        // ============================================
        // 7. BLOG
        // ============================================
        BlogSection(
          articles: const [
            {
              'title': 'Comment choisir la meilleure montre connectée ?',
              'category': 'Conseils',
              'author': 'Équipe ShopPro',
              'readTime': 5,
            },
            {
              'title': 'Les tendances mode 2026 à ne pas manquer',
              'category': 'Tendances',
              'author': 'Équipe ShopPro',
              'readTime': 4,
            },
            {
              'title': '5 astuces pour économiser sur vos achats',
              'category': 'Astuces',
              'author': 'Équipe ShopPro',
              'readTime': 3,
            },
          ],
        ),
      ],
    );
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void _navigateToProduct(int productId) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetail,
      arguments: {'product_id': productId},
    );
  }

  void _handleBannerTap(dynamic banner) {
    // Navigation selon le type de cible du banner
    if (banner.targetType == 'product' && banner.targetId != null) {
      _navigateToProduct(banner.targetId as int);
    } else if (banner.targetType == 'category' && banner.targetId != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.categoryDetail,
        arguments: {'category_id': banner.targetId},
      );
    }
  }

  void _toggleFavorite(dynamic product) {
  final favoriteProvider = context.read<FavoriteProvider>();

  // Créer un objet Favorite à partir du Product
  final favorite = Favorite(
    id: 0, // L'ID sera généré par le backend
    productId: product.id,
    productName: product.name,
    productImage: product.mainImage,
    productSku: product.sku ?? '',
    productPrice: product.price,
    productDiscountPrice: product.discountPrice,
    isInStock: product.isInStock,
    stock: product.stock,
    averageRating: product.averageRating,
    addedAt: DateTime.now(),
  );

  favoriteProvider.toggleFavorite(favorite);
}
}