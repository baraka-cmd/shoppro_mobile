// ============================================
// PAGE : SellerProductsScreen
// ============================================
// Écran de gestion des produits du vendeur.
//
// Structure :
//   - AppBar avec recherche + filtres + bouton refresh
//   - Barre de filtres horizontale (statuts)
//   - Compteur de produits + tri
//   - Liste paginée avec scroll infini
//   - Pull-to-refresh
//   - FAB "Nouveau produit"
//   - États : loading, empty, error, forbidden
//
// UX :
//   - Skeleton loading au premier chargement
//   - Scroll infini pour la pagination
//   - Actions rapides sur chaque produit
//   - Confirmations avant actions destructives
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// Providers
import '../providers/seller_product_provider.dart';

// Widgets
import '../widgets/seller_product_tile.dart';
import '../widgets/seller_scaffold.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // État local
  bool _showSearch = false;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();

    // Charger les produits au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerProductProvider>();
      if (provider.listStatus == SellerProductListStatus.initial) {
        provider.loadProducts();
      }
    });

    // Écouter le scroll pour la pagination infinie
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ============================================
  // SCROLL INFINI
  // ============================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Charger plus quand on approche du bas (à 200px)
    if (currentScroll >= maxScroll - 200) {
      final provider = context.read<SellerProductProvider>();
      if (provider.hasMore && !provider.isLoadingMore && !provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SellerScaffold(
      currentIndex: 1,
      title: 'Mes produits',
      subtitle: _buildSubtitle(),
      showBackButton: false,
      extraActions: [
        IconButton(
          icon: Icon(
            _showSearch ? Icons.close_rounded : Icons.search_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
          onPressed: _toggleSearch,
          tooltip: _showSearch ? 'Fermer' : 'Rechercher',
        ),
        IconButton(
          icon: const Icon(
            Icons.filter_list_rounded,
            size: 22,
            color: AppColors.textPrimary,
          ),
          onPressed: _showFiltersBottomSheet,
          tooltip: 'Filtrer',
        ),
      ],
      floatingActionButton: _buildFab(),
      child: Consumer<SellerProductProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Barre de recherche (si activée)
              if (_showSearch) _buildSearchBar(provider),

              // Barre de filtres horizontale
              _buildFiltersBar(provider),

              // Compteur + Tri
              _buildCounterAndSort(provider),

              // Contenu principal
              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // SUBTITLE
  // ============================================

  String _buildSubtitle() {
    final provider = context.watch<SellerProductProvider>();
    if (provider.total == 0) return 'Aucun produit';
    return '${provider.total} produit${provider.total > 1 ? 's' : ''}';
  }

  // ============================================
  // BARRE DE RECHERCHE
  // ============================================

  Widget _buildSearchBar(SellerProductProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: AppColors.background,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit ou SKU...',
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          suffixIcon: provider.search.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        onSubmitted: (value) => provider.setSearch(value),
      ),
    );
  }

  // ============================================
  // BARRE DE FILTRES
  // ============================================

  Widget _buildFiltersBar(SellerProductProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildFilterChip(
              label: 'Tous',
              isActive: provider.filterStatus == 'all',
              onTap: () => provider.setStatusFilter('all'),
            ),
            _buildFilterChip(
              label: 'Publiés',
              isActive: provider.filterStatus == 'active',
              onTap: () => provider.setStatusFilter('active'),
            ),
            _buildFilterChip(
              label: 'Brouillons',
              isActive: provider.filterStatus == 'draft',
              onTap: () => provider.setStatusFilter('draft'),
            ),
            _buildFilterChip(
              label: 'Rupture',
              isActive: provider.filterStatus == 'out_of_stock',
              onTap: () => provider.setStatusFilter('out_of_stock'),
            ),
            _buildFilterChip(
              label: 'Stock faible',
              isActive: provider.filterStatus == 'low_stock',
              onTap: () => provider.setStatusFilter('low_stock'),
            ),
            _buildFilterChip(
              label: 'Archivés',
              isActive: provider.filterStatus == 'archived',
              onTap: () => provider.setStatusFilter('archived'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.warning : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // COMPTEUR + TRI
  // ============================================

  Widget _buildCounterAndSort(SellerProductProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              provider.total > 0
                  ? '${provider.total} produit${provider.total > 1 ? 's' : ''}'
                  : 'Aucun produit',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showSortBottomSheet,
            child: Row(
              children: [
                const Icon(
                  Icons.sort_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _getSortLabel(provider.sortBy, provider.sortDir),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy, String sortDir) {
    switch (sortBy) {
      case 'price':
        return sortDir == 'asc' ? 'Prix ↑' : 'Prix ↓';
      case 'sales_count':
        return 'Ventes';
      case 'views_count':
        return 'Vues';
      case 'stock':
        return 'Stock';
      default:
        return sortDir == 'asc' ? 'Anciens' : 'Récents';
    }
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(SellerProductProvider provider) {
    // Loading initial
    if (provider.isLoading && provider.products.isEmpty) {
      return _buildSkeleton();
    }

    // Forbidden (KYC)
    if (provider.isForbidden) {
      return _buildKycBlockedState(provider);
    }

    // Unauthorized
    if (provider.isUnauthorized) {
      return _buildUnauthorizedState();
    }

    // Erreur
    if (provider.hasError && provider.products.isEmpty) {
      return _buildErrorState(provider);
    }

    // Liste vide
    if (provider.products.isEmpty) {
      return _buildEmptyState(provider);
    }

    // Liste
    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppColors.warning,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loader en bas
          if (index == provider.products.length) {
            return _buildLoadMoreIndicator();
          }

          final product = provider.products[index];
          return SellerProductTile(
            product: product,
            isProcessing: provider.isPerformingAction &&
                provider.lastAffectedProduct?.id == product.id,
            onTap: () => _navigateToDetail(product),   // 👈 NOUVEAU
            onEdit: () => _navigateToEdit(product),
            onPublish: () => _handlePublish(provider, product),
            onUnpublish: () => _handleUnpublish(provider, product),
            onDuplicate: () => _handleDuplicate(provider, product),
            onDelete: () => _handleDelete(provider, product),
          );
        },
      ),
    );
  }

  // ============================================
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================
  // LOAD MORE INDICATOR
  // ============================================

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.warning,
          ),
        ),
      ),
    );
  }

  // ============================================
  // EMPTY STATE
  // ============================================

  Widget _buildEmptyState(SellerProductProvider provider) {
    final hasFilters = provider.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 42,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters
                  ? 'Aucun résultat'
                  : 'Aucun produit pour l\'instant',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Essayez de modifier vos filtres ou votre recherche.'
                  : 'Commencez par créer votre premier produit pour commencer à vendre.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: () => provider.clearFilters(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Effacer les filtres',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Créer un produit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ERROR STATE
  // ============================================

  Widget _buildErrorState(SellerProductProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              provider.listError ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadProducts(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Réessayer',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // KYC BLOCKED STATE
  // ============================================

  Widget _buildKycBlockedState(SellerProductProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty_rounded,
                size: 45,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'KYC en attente',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              provider.listError ?? 'Votre KYC doit être validé.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushNamed(AppRoutes.sellerProfile),
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: const Text(
                'Voir mon profil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // UNAUTHORIZED STATE
  // ============================================

  Widget _buildUnauthorizedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Session expirée',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez vous reconnecter pour continuer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Se reconnecter',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FAB
  // ============================================

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreate,
      backgroundColor: AppColors.warning,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        'Nouveau',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _searchFocus.requestFocus();
        });
      } else {
        _searchController.clear();
        context.read<SellerProductProvider>().setSearch('');
      }
    });
  }

  void _navigateToCreate() {
    Navigator.of(context).pushNamed(AppRoutes.sellerProductForm);
  }

  void _navigateToEdit(SellerProduct product) {
    Navigator.of(context).pushNamed(
      AppRoutes.sellerProductForm,
      arguments: {'product': product},
    );
  }

  void _navigateToDetail(SellerProduct product) {
    Navigator.of(context).pushNamed(
      AppRoutes.sellerProductDetail,
      arguments: {'product_id': product.id},
    );
  }
  Future<void> _handlePublish(
    SellerProductProvider provider,
    SellerProduct product,
  ) async {
    // Vérifications préalables
    if (!product.canBePublished) {
      final reason = product.price <= 0
          ? 'Le prix doit être supérieur à 0.'
          : product.categoryId == null
              ? 'La catégorie est obligatoire.'
              : product.imagesCount == 0
                  ? 'Ajoutez au moins une image avant de publier.'
                  : 'Le produit ne peut pas être publié.';

      _showSnackBar(reason, isError: true);
      return;
    }

    final confirmed = await _showConfirmation(
      title: 'Publier le produit ?',
      message:
          'Le produit sera visible par les clients après publication.',
      confirmLabel: 'Publier',
      confirmColor: AppColors.success,
    );

    if (confirmed != true) return;

    final result = await provider.publishProduct(product.id);

    if (!mounted) return;

    if (result != null) {
      _showSnackBar('Produit publié avec succès', isSuccess: true);
    } else {
      _showSnackBar(provider.actionError ?? 'Erreur', isError: true);
    }
  }

  Future<void> _handleUnpublish(
    SellerProductProvider provider,
    SellerProduct product,
  ) async {
    final confirmed = await _showConfirmation(
      title: 'Dépublier le produit ?',
      message:
          'Le produit ne sera plus visible par les clients mais restera dans vos données.',
      confirmLabel: 'Dépublier',
      confirmColor: AppColors.warning,
    );

    if (confirmed != true) return;

    final result = await provider.unpublishProduct(product.id);

    if (!mounted) return;

    if (result != null) {
      _showSnackBar('Produit dépublié', isSuccess: true);
    } else {
      _showSnackBar(provider.actionError ?? 'Erreur', isError: true);
    }
  }

  Future<void> _handleDuplicate(
    SellerProductProvider provider,
    SellerProduct product,
  ) async {
    final confirmed = await _showConfirmation(
      title: 'Dupliquer le produit ?',
      message:
          'Une copie sera créée en brouillon. Vous pourrez la modifier avant de la publier.',
      confirmLabel: 'Dupliquer',
      confirmColor: AppColors.warning,
    );

    if (confirmed != true) return;

    final result = await provider.duplicateProduct(product.id);

    if (!mounted) return;

    if (result != null) {
      _showSnackBar('Produit dupliqué', isSuccess: true);
    } else {
      _showSnackBar(provider.actionError ?? 'Erreur', isError: true);
    }
  }

  Future<void> _handleDelete(
    SellerProductProvider provider,
    SellerProduct product,
  ) async {
    final confirmed = await _showConfirmation(
      title: 'Archiver le produit ?',
      message:
          'Le produit sera archivé et ne sera plus visible. Cette action est réversible.',
      confirmLabel: 'Archiver',
      confirmColor: AppColors.error,
    );

    if (confirmed != true) return;

    final success = await provider.deleteProduct(product.id);

    if (!mounted) return;

    if (success) {
      _showSnackBar('Produit archivé', isSuccess: true);
    } else {
      _showSnackBar(provider.actionError ?? 'Erreur', isError: true);
    }
  }

  // ============================================
  // BOTTOM SHEETS
  // ============================================

  




// ============================================
// BOTTOM SHEETS (FILTRES & TRI)
// ============================================

void _showFiltersBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _buildFiltersSheet(sheetContext);
    },
  );
}

Widget _buildFiltersSheet(BuildContext sheetContext) {
  final provider = sheetContext.read<SellerProductProvider>();

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Filtres',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Statut',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'all', 'active', 'draft', 'out_of_stock', 'low_stock', 'archived'
            ].map((status) {
              final labels = {
                'all': 'Tous',
                'active': 'Publiés',
                'draft': 'Brouillons',
                'out_of_stock': 'Rupture',
                'low_stock': 'Stock faible',
                'archived': 'Archivés',
              };
              return _buildFilterChip(
                label: labels[status] ?? status,
                isActive: provider.filterStatus == status,
                onTap: () {
                  provider.setStatusFilter(status);
                  Navigator.pop(sheetContext);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              provider.clearFilters();
              Navigator.pop(sheetContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceAlt,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Effacer les filtres',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showSortBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _buildSortSheet(sheetContext);
    },
  );
}

Widget _buildSortSheet(BuildContext sheetContext) {
  final provider = sheetContext.read<SellerProductProvider>();

  final options = [
    {'label': 'Plus récents', 'sortBy': 'created_at', 'sortDir': 'desc'},
    {'label': 'Plus anciens', 'sortBy': 'created_at', 'sortDir': 'asc'},
    {'label': 'Prix croissant', 'sortBy': 'price', 'sortDir': 'asc'},
    {'label': 'Prix décroissant', 'sortBy': 'price', 'sortDir': 'desc'},
    {'label': 'Plus vendus', 'sortBy': 'sales_count', 'sortDir': 'desc'},
    {'label': 'Plus vus', 'sortBy': 'views_count', 'sortDir': 'desc'},
    {'label': 'Stock faible', 'sortBy': 'stock', 'sortDir': 'asc'},
  ];

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Trier par',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final isSelected = provider.sortBy == option['sortBy'] &&
                provider.sortDir == option['sortDir'];

            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                provider.setSort(
                  option['sortBy'] as String,
                  sortDir: option['sortDir'] as String,
                );
                Navigator.pop(sheetContext);
              },
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: isSelected ? AppColors.warning : AppColors.textTertiary,
              ),
              title: Text(
                option['label'] as String,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}




  // ============================================
  // HELPERS UI
  // ============================================

  Future<bool?> _showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: confirmColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: isError
            ? AppColors.error
            : isSuccess
                ? AppColors.success
                : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}