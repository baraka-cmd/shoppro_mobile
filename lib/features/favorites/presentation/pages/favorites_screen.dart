// Écran des favoris
// Affiche la liste des produits favoris avec filtres et actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../providers/favorite_provider.dart';
import '../widgets/favorite_item_widget.dart';
import '../widgets/empty_favorites.dart';
import '../../../products/presentation/widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charger les favoris
  Future<void> _loadData() async {
    final favoriteProvider = context.read<FavoriteProvider>();
    await favoriteProvider.loadFavorites();

    final productProvider = context.read<ProductProvider>();
    await productProvider.loadPopularProducts();
  }

  // Filtrer les favoris
  List<dynamic> _getFilteredFavorites(FavoriteProvider provider) {
    switch (_selectedFilter) {
      case 'in_stock':
        return provider.inStockFavorites;
      case 'on_sale':
        return provider.onSaleFavorites;
      case 'price_alert':
        return provider.priceAlertFavorites;
      default:
        return provider.favorites;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Consumer<FavoriteProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty
                  ? 'Favoris'
                  : 'Favoris (${provider.favoritesCount})',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearDialog(provider),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.isEmpty) {
            return EmptyFavorites(
              onExplore: () {
                Navigator.of(context).pop();
              },
            );
          }

          final filteredFavorites = _getFilteredFavorites(provider);

          return Column(
            children: [
              // Chips de filtres
              _buildFilterChips(provider),

              const SizedBox(height: 10),

              // Liste des favoris
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: filteredFavorites.isEmpty
                      ? EmptyFavorites(
                          onExplore: () {
                            Navigator.of(context).pop();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final favorite = filteredFavorites[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FavoriteItemWidget(
                                favorite: favorite,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/product/detail',
                                    arguments: {
                                      'product_id': favorite.productId,
                                    },
                                  );
                                },
                                onAddToCart: () {
                                  _addToCart(favorite);
                                },
                                onRemove: () {
                                  provider.removeFavorite(favorite.id);
                                },
                                onTogglePriceAlert: () {
                                  provider.togglePriceAlert(favorite.id);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Chips de filtres
  Widget _buildFilterChips(FavoriteProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildChip(
            label: 'Tous',
            count: provider.favoritesCount,
            isSelected: _selectedFilter == 'all',
            onTap: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'En stock',
            count: provider.inStockFavorites.length,
            isSelected: _selectedFilter == 'in_stock',
            color: AppColors.success,
            onTap: () {
              setState(() {
                _selectedFilter = 'in_stock';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Promo',
            count: provider.onSaleFavorites.length,
            isSelected: _selectedFilter == 'on_sale',
            color: AppColors.error,
            onTap: () {
              setState(() {
                _selectedFilter = 'on_sale';
              });
            },
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'Alertes prix',
            count: provider.priceAlertFavorites.length,
            isSelected: _selectedFilter == 'price_alert',
            color: AppColors.warning,
            onTap: () {
              setState(() {
                _selectedFilter = 'price_alert';
              });
            },
          ),
        ],
      ),
    );
  }

  // Chip de filtre
  Widget _buildChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Ajouter au panier
  Future<void> _addToCart(dynamic favorite) async {
    final cartProvider = context.read<CartProvider>();

    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: favorite.productId,
      name: favorite.productName,
      imageUrl: favorite.productImage,
      sku: favorite.productSku,
      unitPrice: favorite.effectivePrice,
      discountPrice: favorite.hasDiscount ? favorite.productDiscountPrice : null,
      quantity: 1,
      maxQuantity: favorite.stock > 0 ? favorite.stock : 99,
      stock: favorite.stock,
    );

    final success = await cartProvider.addItem(cartItem);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Produit ajouté au panier !' : 'Erreur lors de l\'ajout',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // Dialog pour vider les favoris
  void _showClearDialog(FavoriteProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Vider les favoris ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Tous vos produits favoris seront supprimés.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await provider.clearFavorites();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Vider',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}