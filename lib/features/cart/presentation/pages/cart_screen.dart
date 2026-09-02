// ============================================
// ÉCRAN DU PANIER D'ACHAT - VERSION PREMIUM
// ============================================
// Assemble tous les éléments : articles, résumé,
// coupon, suggestions et livraison gratuite.
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary.dart';
import '../widgets/coupon_field.dart';
import '../widgets/empty_cart.dart';
import '../widgets/free_shipping_progress.dart';
import '../widgets/cart_suggestions.dart';
import '../widgets/saved_for_later_section.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadCart() async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.loadCart();

    final productProvider = context.read<ProductProvider>();
    await productProvider.loadPopularProducts();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Consumer<CartProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.isEmpty ? 'Panier' : 'Panier (${provider.totalItems})',
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
          Consumer<CartProvider>(
            builder: (context, provider, child) {
              if (provider.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showClearCartDialog(provider),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
                tooltip: 'Vider le panier',
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.isEmpty) {
            return _buildEmptyCart(provider);
          }

          return _buildCartContent(provider);
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isEmpty) return const SizedBox.shrink();
          return _buildBottomBar(provider);
        },
      ),
    );
  }

  // ============================================
  // PANIER VIDE
  // ============================================

  Widget _buildEmptyCart(CartProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          EmptyCart(
            onExplore: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 30),
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return CartSuggestions(
                products: productProvider.popularProducts,
                isLoading: productProvider.isLoading,
                onProductTap: (product) {
                  Navigator.of(context).pushNamed(
                    AppRoutes.productDetail,
                    arguments: {'product_id': product.id},
                  );
                },
                onSeeAll: () {
                  Navigator.of(context).pop();
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================
  // CONTENU DU PANIER
  // ============================================

  Widget _buildCartContent(CartProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadCart,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ============================================
            // LIVRAISON GRATUITE
            // ============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FreeShippingProgress(cart: provider.cart),
            ),

            const SizedBox(height: 15),

            // ============================================
            // ARTICLES
            // ============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ARTICLES (${provider.totalItems})',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ...provider.cart.activeItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CartItemWidget(
                  item: item,
                  onIncrement: () => provider.incrementQuantity(item.id),
                  onDecrement: () => provider.decrementQuantity(item.id),
                  onRemove: () => _handleRemoveItem(provider, item.id),
                  onSaveForLater: () => provider.saveForLater(item.id),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.productDetail,
                      arguments: {'product_id': item.productId},
                    );
                  },
                ),
              );
            }),

            // ============================================
            // SAUVEGARDÉS POUR PLUS TARD
            // ============================================
            if (provider.cart.savedForLaterItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              SavedForLaterSection(
                savedItems: provider.cart.savedForLaterItems,
                onMoveToCart: () {
                  for (final item in provider.cart.savedForLaterItems) {
                    provider.moveToCart(item.id);
                  }
                },
                onRemove: () {
                  for (final item in provider.cart.savedForLaterItems) {
                    provider.removeItem(item.id);
                  }
                },
                onClearAll: () {
                  for (final item in provider.cart.savedForLaterItems) {
                    provider.removeItem(item.id);
                  }
                },
              ),
            ],

            const SizedBox(height: 20),

            // ============================================
            // RÉSUMÉ
            // ============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CartSummary(cart: provider.cart),
            ),

            const SizedBox(height: 15),

            // ============================================
            // CODE PROMO
            // ============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CouponField(
                currentCoupon: provider.cart.couponCode,
                isLoading: provider.isUpdating,
                onApply: (code) {
                  provider.applyCoupon(code).then((success) {
                    if (success) {
                      _addPromotionNotification(provider, code);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Code promo appliqué !',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(20),
                          duration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ?? 'Code invalide',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(20),
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      );
                    }
                  });
                },
                onRemove: () {
                  provider.removeCoupon();
                },
              ),
            ),

            const SizedBox(height: 20),

            // ============================================
            // SUGGESTIONS
            // ============================================
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return CartSuggestions(
                  products: productProvider.popularProducts,
                  isLoading: productProvider.isLoading,
                  onProductTap: (product) {
                    Navigator.of(context).pushNamed(
                      AppRoutes.productDetail,
                      arguments: {'product_id': product.id},
                    );
                  },
                  onSeeAll: () {
                    Navigator.of(context).pushNamed(AppRoutes.productList);
                  },
                );
              },
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SUPPRESSION AVEC ANNULATION
  // ============================================

  Future<void> _handleRemoveItem(CartProvider provider, int itemId) async {
    final success = await provider.removeItem(itemId);

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Produit supprimé',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        action: SnackBarAction(
          label: 'ANNULER',
          textColor: AppColors.primary,
          onPressed: () {
            provider.undoLastAction();
          },
        ),
      ),
    );
  }

  // ============================================
  // BOTTOM BAR
  // ============================================

  Widget _buildBottomBar(CartProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    provider.cart.formattedTotal,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.checkout);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'PAIEMENT',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // NOTIFICATION PROMOTION
  // ============================================

  Future<void> _addPromotionNotification(CartProvider provider, String code) async {
    final notificationProvider = context.read<NotificationProvider>();
    await notificationProvider.addNotification(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Promotion appliquée !',
        body: 'Le code $code vous fait économiser ${provider.cart.couponDiscount.toStringAsFixed(0)} FCFA.',
        type: 'promotion',
        createdAt: DateTime.now(),
      ),
    );
  }

  // ============================================
  // DIALOG VIDER LE PANIER
  // ============================================

  void _showClearCartDialog(CartProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Vider le panier ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Tous les articles seront supprimés de votre panier.',
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
                await provider.clearCart();
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