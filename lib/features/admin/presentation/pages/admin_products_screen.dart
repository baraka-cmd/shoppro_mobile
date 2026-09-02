// ============================================
// PAGE : AdminProductsScreen
// ============================================
// Écran de gestion des produits administrés.
// Design mobile avec cartes verticales et filtres compacts.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Barre d'actions compacte
// - Liste de cartes produits verticales
// - Pagination simple
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Providers (même feature admin)
import '../providers/admin_product_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des produits mobile.
///
/// Affiche :
/// - Les produits en cartes verticales
/// - Les filtres compacts
/// - Les actions (créer, modifier, supprimer)
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProductProvider>().loadProducts();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Produits',
      subtitle: 'Gérez votre catalogue',
      currentRoute: AppRoutes.adminProducts,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () {},
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(),
        backgroundColor: AppColors.warning,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 6,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadProducts,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // BARRE DE FILTRES COMPACTE
            // ============================================
            _buildFilterBar(provider),

            // ============================================
            // LISTE DES PRODUITS EN CARTES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'Aucun produit',
                      message: 'Ajoutez votre premier produit.',
                      actionLabel: 'Ajouter un produit',
                      onAction: () => _navigateToCreate(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return _buildProductCard(product, provider);
                      },
                    ),
            ),

            // ============================================
            // PAGINATION SIMPLE
            // ============================================
            if (provider.products.isNotEmpty)
              _buildPagination(provider),
          ],
        );
      },
    );
  }

  // ============================================
  // BARRE DE FILTRES COMPACTE
  // ============================================

  Widget _buildFilterBar(AdminProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: [
          // Compteur
          Flexible(
            child: Text(
              '${provider.productsCount} produits',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          // Filtre catégorie compact
          _buildCompactFilter(
            icon: Icons.category_outlined,
            onTap: () => _showFilterSheet(provider),
          ),
        ],
      ),
    );
  }

  /// Filtre compact (chip).
  Widget _buildCompactFilter({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, size: 16, color: AppColors.textTertiary),
      ),
    );
  }

  /// Affiche le bottom sheet de filtres.
  void _showFilterSheet(AdminProductProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les produits',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Catégories en chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.categories.map((category) {
                  return InkWell(
                    onTap: () {
                      provider.filterByCategory(category.id);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.infoDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================
  // CARTE PRODUIT
  // ============================================

  Widget _buildProductCard(dynamic product, AdminProductProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // LIGNE 1 : Icône + Nom + Prix
          // ============================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Produit',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.category?.name ?? 'Sans catégorie',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${product.price} FCFA',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================
          // LIGNE 2 : Stock + Statut
          // ============================================
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildStockBadge(product),
              _buildStatusBadge(product),
            ],
          ),

          const SizedBox(height: 10),

          // Séparateur
          Container(height: 1, color: AppColors.borderColor),

          const SizedBox(height: 8),

          // ============================================
          // LIGNE 3 : Actions
          // ============================================
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                label: 'Modifier',
                icon: Icons.edit_outlined,
                color: AppColors.info,
                onTap: () => _navigateToEdit(product),
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                label: 'Supprimer',
                icon: Icons.delete_outline,
                color: AppColors.error,
                onTap: () => _confirmDelete(provider, product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Badge de stock.
  Widget _buildStockBadge(dynamic product) {
    final stock = product.stock as int? ?? 0;
    final minStock = product.minStock as int? ?? 5;

    Color color;
    Color bgColor;
    String label;
    IconData icon;

    if (stock <= 0) {
      color = AppColors.errorDark;
      bgColor = AppColors.errorLight;
      label = 'Rupture';
      icon = Icons.cancel_outlined;
    } else if (stock <= minStock) {
      color = AppColors.warningDark;
      bgColor = AppColors.warningLight;
      label = 'Faible: $stock';
      icon = Icons.warning_amber_rounded;
    } else {
      color = AppColors.successDark;
      bgColor = AppColors.successLight;
      label = 'Stock: $stock';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Badge de statut.
  Widget _buildStatusBadge(dynamic product) {
    final isActive = product.isActive as bool? ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Actif' : 'Inactif',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.successDark : AppColors.statusInactiveText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Petit bouton d'action.
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PAGINATION SIMPLE
  // ============================================

  Widget _buildPagination(AdminProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1 ? provider.loadProducts : null,
            icon: const Icon(Icons.chevron_left, size: 20),
          ),
          Text(
            'Page ${provider.currentPage}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: provider.hasMore ? provider.loadMoreProducts : null,
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  // ============================================
  // NAVIGATION ET ACTIONS
  // ============================================

  void _navigateToCreate() {
    Navigator.of(context).pushNamed(AppRoutes.adminProductForm);
  }

  void _navigateToEdit(dynamic product) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminProductForm,
      arguments: {'product_id': product.id},
    );
  }

  Future<void> _confirmDelete(AdminProductProvider provider, dynamic product) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer ce produit ?',
      message: 'Cette action est irréversible.',
      type: AdminDialogType.danger,
      confirmLabel: 'Supprimer',
    );

    if (result == true) {
      await provider.deleteProduct(product.id);
    }
  }
}