// Écran de détails du produit - Version complète
// Assemble galerie, infos, variations, quantité, specs, avis et produits similaires

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_info_section.dart';
import '../widgets/variation_selector.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/specifications_section.dart';
import '../widgets/reviews_section.dart';
import '../widgets/share_button.dart';
import '../widgets/recently_viewed_section.dart';
import '../widgets/shimmer_product_card.dart';
import '../widgets/product_card.dart';
import '../widgets/add_review_sheet.dart';  // ✅ AJOUTER
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../favorites/domain/entities/favorite.dart';


class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isLoading = true;
  String? _errorMessage;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  // Charger le produit
  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<ProductProvider>();

      Product? product;
      try {
        product = provider.products.firstWhere((p) => p.id == widget.productId);
      } catch (e) {
        product = null;
      }

      if (product == null) {
        setState(() {
          _errorMessage = 'Produit introuvable';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _product = product;
        _isLoading = false;
      });

      // Ajouter aux récemment consultés
      await RecentlyViewedSection.addToRecentlyViewed(product);

      // Charger les produits similaires
      await provider.loadSimilarProducts(widget.productId);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildProductDetails(),
      bottomNavigationBar: _product != null && !_isLoading
          ? _buildBottomBar()
          : null,
    );
  }

  // État de chargement
  Widget _buildLoadingState() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Expanded(child: ShimmerProductGrid(itemCount: 2)),
      ],
    );
  }

  // État d'erreur
  Widget _buildErrorState() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 15),
                Text(
                  _errorMessage ?? 'Erreur',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('RÉESSAYER'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Détails du produit
  Widget _buildProductDetails() {
    final product = _product!;
    final imageUrls = _buildImageUrls(product);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galerie + boutons superposés
          Stack(
            children: [
              ProductGallery(
                imageUrls: imageUrls,
                height: 320,
                showThumbnails: imageUrls.length > 1,
                showDots: true,
                showCounter: imageUrls.length > 1,
                enableZoom: true,
              ),

              // Boutons retour + actions
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Retour
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // Favori + Partager
                      Row(
                        children: [
                          // Favori
                          GestureDetector(
                            onTap: () => _toggleFavorite(product),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: _isFavorite ? AppColors.error : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Partager
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: ShareButton(product: product),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations produit
                ProductInfoSection(product: product),

                const SizedBox(height: 20),
                const Divider(height: 1),

                const SizedBox(height: 15),

                // Variations
                if (product.images.isNotEmpty || true)
                  VariationSelector(
                    variants: _buildVariants(product),
                    onVariantSelected: (variant) {
                      // Mise à jour du prix selon la variante
                    },
                  ),

                const SizedBox(height: 15),
                const Divider(height: 1),

                const SizedBox(height: 15),

                // Quantité
                QuantitySelector(
                  initialQuantity: _quantity,
                  maxQuantity: product.stock > 0 ? product.stock : 99,
                  minQuantity: 1,
                  onQuantityChanged: (qty) {
                    setState(() {
                      _quantity = qty;
                    });
                  },
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),

                const SizedBox(height: 15),

                // Spécifications
                SpecificationsSection(
                  specifications: _buildSpecifications(product),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),

                const SizedBox(height: 15),

                // Avis
                ReviewsSection(
                  averageRating: product.averageRating,
                  totalReviews: product.reviewsCount,
                  ratingDistribution: const {5: 2, 4: 3, 3: 1, 2: 0, 1: 0},
                  reviews: _buildReviews(product),
                  onSeeAllReviews: () {},
                  onAddReview: () {
                    showAddReviewSheet(context);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Produits similaires
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.similarProducts.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'PRODUITS SIMILAIRES',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.similarProducts.length,
                      itemBuilder: (context, index) {
                        final similarProduct = provider.similarProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 150,
                            child: ProductCard(
                              product: similarProduct,
                              onTap: (p) {
                                Navigator.of(context).pushReplacementNamed(
                                  '/product/detail',
                                  arguments: {'product_id': p.id},
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // Récemment consultés
          RecentlyViewedSection(
            onProductTap: (product) {
              Navigator.of(context).pushReplacementNamed(
                '/product/detail',
                arguments: {'product_id': product.id},
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Bottom bar avec favori + panier
  Widget _buildBottomBar() {
    final product = _product!;

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
            // Favori
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _toggleFavorite(product),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isFavorite
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFavorite ? AppColors.error : AppColors.borderColor,
                    ),
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppColors.error : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Ajouter au panier
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: product.isInStock
                    ? () => _addToCart(product)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  product.isInStock ? 'AJOUTER AU PANIER' : 'RUPTURE DE STOCK',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construire les URLs des images
  List<String> _buildImageUrls(Product product) {
    final urls = <String>[];

    final mainUrl = product.fullImageUrl;
    if (mainUrl.isNotEmpty) {
      urls.add(mainUrl);
    }

    for (final img in product.images) {
      final url = (img as dynamic).thumbnailUrl ?? img.url ?? '';
      if (url.isNotEmpty && !urls.contains(url)) {
        urls.add(url);
      }
    }

    return urls;
  }

  // Ajouter au panier
Future<void> _addToCart(Product product) async {
  final cartProvider = context.read<CartProvider>();

  final cartItem = CartItem(
    id: DateTime.now().millisecondsSinceEpoch,  // ID unique
    productId: product.id,
    name: product.name,
    imageUrl: (product as dynamic).fullImageUrl ?? product.mainImage,
    sku: product.sku,
    unitPrice: product.currentPrice,
    discountPrice: product.hasDiscount ? product.discountPrice : null,
    quantity: _quantity,
    maxQuantity: product.stock > 0 ? product.stock : 99,
    stock: product.stock,
  );

  final success = await cartProvider.addItem(cartItem);

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produit ajouté au panier !'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cartProvider.errorMessage ?? 'Erreur'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
      ),
    );
  }
}

// Toggle favori
Future<void> _toggleFavorite(Product product) async {
  final favoriteProvider = context.read<FavoriteProvider>();

  final favorite = Favorite(
    id: DateTime.now().millisecondsSinceEpoch,
    productId: product.id,
    productName: product.name,
    productImage: (product as dynamic).fullImageUrl ?? product.mainImage,
    productSku: product.sku,
    productPrice: product.price,
    productDiscountPrice: product.hasDiscount ? product.discountPrice : null,
    isInStock: product.isInStock,
    stock: product.stock,
    averageRating: product.averageRating,
    addedAt: DateTime.now(),
  );

  final result = await favoriteProvider.toggleFavorite(favorite);

  if (!mounted) return;

  setState(() {
    _isFavorite = result ?? false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        _isFavorite ? 'Ajouté aux favoris !' : 'Retiré des favoris',
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      ),
      backgroundColor: _isFavorite ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
    ),
  );
}
  // Construire les variantes
  List<ProductVariant> _buildVariants(Product product) {
    // Placeholder - à remplacer par les vraies variantes de l'API
    return const [];
  }

  // Construire les spécifications
  List<SpecificationItem> _buildSpecifications(Product product) {
    return [
      SpecificationItem(label: 'SKU', value: product.sku, icon: Icons.qr_code),
      SpecificationItem(label: 'Stock', value: '${product.stock} unités', icon: Icons.inventory),
      if (product.category != null)
        SpecificationItem(label: 'Catégorie', value: product.category!.name, icon: Icons.category),
      if (product.brand != null)
        SpecificationItem(label: 'Marque', value: product.brand!.name, icon: Icons.storefront),
    ];
  }

  // Construire les avis
  List<ReviewCardData> _buildReviews(Product product) {
    // Placeholder - à remplacer par les vrais avis de l'API
    return const [];
  }
}