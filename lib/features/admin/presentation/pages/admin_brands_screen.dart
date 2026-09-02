// ============================================
// PAGE : AdminBrandsScreen
// ============================================
// Écran de gestion des marques - Design mobile.
// Cartes verticales pleine largeur + statistiques en Wrap.
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
import '../providers/admin_brand_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des marques mobile.
///
/// Affiche :
/// - Les marques en cartes verticales pleine largeur
/// - Statistiques en chips compactes
/// - Actions (créer, modifier, supprimer)
class AdminBrandsScreen extends StatefulWidget {
  const AdminBrandsScreen({super.key});

  @override
  State<AdminBrandsScreen> createState() => _AdminBrandsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminBrandsScreenState extends State<AdminBrandsScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBrandProvider>().loadBrands();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Marques',
      subtitle: 'Gérez vos marques',
      currentRoute: AppRoutes.adminBrands,
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
    return Consumer<AdminBrandProvider>(
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
              onRetry: provider.loadBrands,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // STATISTIQUES COMPACTES (barre horizontale)
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  _buildCompactStat(
                    label: 'Total',
                    value: provider.totalBrands,
                    color: AppColors.info,
                  ),
                  _buildCompactStat(
                    label: 'Actives',
                    value: provider.activeBrands,
                    color: AppColors.success,
                  ),
                  _buildCompactStat(
                    label: 'Vedette',
                    value: provider.featuredBrands,
                    color: AppColors.warning,
                  ),
                  _buildCompactStat(
                    label: 'Produits',
                    value: provider.brandsWithProducts,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ============================================
            // LISTE DES MARQUES EN CARTES VERTICALES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'Aucune marque',
                      message: 'Ajoutez votre première marque.',
                      actionLabel: 'Nouvelle marque',
                      onAction: () => _navigateToCreate(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.brands.length,
                      itemBuilder: (context, index) {
                        final brand = provider.brands[index];
                        return _buildBrandCard(brand);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Statistique compacte (mini carte).
  Widget _buildCompactStat({
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE MARQUE (PLEINE LARGEUR)
  // ============================================

  Widget _buildBrandCard(dynamic brand) {
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
          // LIGNE 1 : Logo + Nom + Statut + Modifier
          // ============================================
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 22,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name ?? 'Marque',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (brand.country != null && (brand.country as String).isNotEmpty)
                      Text(
                        brand.country,
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
              _buildStatusBadge(brand),
              IconButton(
                onPressed: () => _navigateToEdit(brand),
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.info),
                tooltip: 'Modifier',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ============================================
          // LIGNE 2 : Badges en Wrap
          // ============================================
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(
                label: '${brand.productsCount ?? 0} produits',
                color: AppColors.infoDark,
                bgColor: AppColors.infoLight,
              ),
              if (brand.isFeatured == true)
                _buildBadge(
                  label: 'Vedette',
                  color: AppColors.warningDark,
                  bgColor: AppColors.warningLight,
                ),
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
                label: 'Supprimer',
                icon: Icons.delete_outline,
                color: AppColors.error,
                onTap: () => _confirmDelete(brand),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Badge de statut.
  Widget _buildStatusBadge(dynamic brand) {
    final isActive = brand.isActive ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.successDark : AppColors.statusInactiveText,
        ),
      ),
    );
  }

  /// Badge générique.
  Widget _buildBadge({
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
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
            const SizedBox(width: 4),
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
  // NAVIGATION ET ACTIONS
  // ============================================

  void _navigateToCreate() {
    Navigator.of(context).pushNamed(AppRoutes.adminBrandForm);
  }

  void _navigateToEdit(dynamic brand) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminBrandForm,
      arguments: {'brand_id': brand.id},
    );
  }

  Future<void> _confirmDelete(dynamic brand) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer cette marque ?',
      message: 'Les produits de cette marque seront également affectés.',
      type: AdminDialogType.danger,
      confirmLabel: 'Supprimer',
    );

    if (result == true) {
      // Suppression de la marque
    }
  }
}