// ============================================
// PAGE : AdminCategoriesScreen
// ============================================
// Écran de gestion des catégories - Design mobile.
// Cartes verticales pleine largeur + stats compactes.
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
import '../providers/admin_category_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des catégories mobile.
///
/// Affiche :
/// - Les catégories en cartes verticales pleine largeur
/// - Statistiques en barre compacte
/// - Actions (créer, modifier, supprimer)
class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCategoryProvider>().loadCategories();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Catégories',
      subtitle: 'Gérez vos catégories',
      currentRoute: AppRoutes.adminCategories,
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
    return Consumer<AdminCategoryProvider>(
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
              onRetry: provider.loadCategories,
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
                    value: provider.totalCategories,
                    color: AppColors.info,
                  ),
                  _buildCompactStat(
                    label: 'Racines',
                    value: provider.rootCategories,
                    color: AppColors.primary,
                  ),
                  _buildCompactStat(
                    label: 'Sous-cat.',
                    value: provider.subCategories,
                    color: const Color(0xFF8B5CF6),
                  ),
                  _buildCompactStat(
                    label: 'Vedette',
                    value: provider.featuredCategories,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ============================================
            // LISTE DES CATÉGORIES EN CARTES VERTICALES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.category_outlined,
                      title: 'Aucune catégorie',
                      message: 'Créez votre première catégorie.',
                      actionLabel: 'Ajouter une catégorie',
                      onAction: () => _navigateToCreate(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];
                        return _buildCategoryCard(category);
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
  // CARTE CATÉGORIE (PLEINE LARGEUR)
  // ============================================

  Widget _buildCategoryCard(dynamic category) {
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
          // LIGNE 1 : Icône + Nom + Statut + Modifier
          // ============================================
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  size: 22,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name ?? 'Catégorie',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${category.productsCount ?? 0} produits',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(category),
              IconButton(
                onPressed: () => _navigateToEdit(category),
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
              _buildCategoryBadge(
                label: (category.isActive ?? true) ? 'Active' : 'Inactive',
                isActive: category.isActive ?? true,
              ),
              if (category.isFeatured == true)
                _buildCategoryBadge(
                  label: 'Vedette',
                  isActive: true,
                  color: AppColors.warningDark,
                  bgColor: AppColors.warningLight,
                ),
              if (category.parentId != null)
                _buildCategoryBadge(
                  label: 'Sous-catégorie',
                  isActive: true,
                  color: const Color(0xFF6B21A8),
                  bgColor: const Color(0xFFF3E8FF),
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
                onTap: () => _confirmDelete(category),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Badge de statut.
  Widget _buildStatusBadge(dynamic category) {
    final isActive = category.isActive ?? true;

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

  /// Badge de catégorie.
  Widget _buildCategoryBadge({
    required String label,
    required bool isActive,
    Color? color,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor ?? (isActive ? AppColors.successLight : AppColors.statusInactiveBg),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color ?? (isActive ? AppColors.successDark : AppColors.statusInactiveText),
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
    Navigator.of(context).pushNamed(AppRoutes.adminCategoryForm);
  }

  void _navigateToEdit(dynamic category) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminCategoryForm,
      arguments: {'category_id': category.id},
    );
  }

  Future<void> _confirmDelete(dynamic category) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer cette catégorie ?',
      message: 'Les produits de cette catégorie seront également affectés.',
      type: AdminDialogType.danger,
      confirmLabel: 'Supprimer',
    );

    if (result == true) {
      // Suppression de la catégorie
    }
  }
}