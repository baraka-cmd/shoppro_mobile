// ============================================
// PAGE : AdminBannersScreen
// ============================================
// Écran de gestion des bannières - Design mobile.
// Cartes verticales pleine largeur avec image.
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

// Providers (autres features - bannière existante)
import '../../../home/presentation/providers/banner_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des bannières mobile.
///
/// Affiche :
/// - Les bannières en cartes verticales pleine largeur
/// - Image + titre + badges + actions
class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerProvider>().loadBanners();
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Bannières',
      subtitle: 'Gérez vos bannières',
      currentRoute: AppRoutes.adminBanners,
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
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 5,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadBanners,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // COMPTEUR
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: AppColors.surface,
              child: Row(
                children: [
                  const Icon(Icons.image_outlined, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    '${provider.banners.length} bannières',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ============================================
            // LISTE DES BANNIÈRES EN CARTES
            // ============================================
            Expanded(
              child: provider.banners.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.image_outlined,
                      title: 'Aucune bannière',
                      message: 'Ajoutez votre première bannière.',
                      actionLabel: 'Nouvelle bannière',
                      onAction: () => _navigateToCreate(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.banners.length,
                      itemBuilder: (context, index) {
                        final banner = provider.banners[index];
                        return _buildBannerCard(banner);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // CARTE BANNIÈRE (PLEINE LARGEUR)
  // ============================================

  Widget _buildBannerCard(dynamic banner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // IMAGE DE LA BANNIÈRE (150px de hauteur)
          // ============================================
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
            ),
            child: banner.imageUrl != null
                ? Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),

          // ============================================
          // CONTENU DE LA CARTE
          // ============================================
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // LIGNE 1 : Titre + Statut
                // ============================================
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        banner.title ?? 'Bannière',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(banner.isActive),
                  ],
                ),

                const SizedBox(height: 8),

                // ============================================
                // LIGNE 2 : Position + Modifier
                // ============================================
                Row(
                  children: [
                    _buildPositionBadge(banner.position),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _navigateToEdit(banner),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.info),
                      tooltip: 'Modifier',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

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
                      onTap: () => _confirmDelete(banner),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder d'image.
  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: AppColors.textLight),
          SizedBox(height: 6),
          Text(
            'Aucune image',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de position.
  Widget _buildPositionBadge(String? position) {
    Color color;
    Color bgColor;
    String label;

    switch (position) {
      case 'home_top':
        color = AppColors.infoDark;
        bgColor = AppColors.infoLight;
        label = 'Haut';
        break;
      case 'home_middle':
        color = AppColors.warningDark;
        bgColor = AppColors.warningLight;
        label = 'Milieu';
        break;
      case 'home_bottom':
        color = AppColors.successDark;
        bgColor = AppColors.successLight;
        label = 'Bas';
        break;
      default:
        color = AppColors.textTertiary;
        bgColor = AppColors.surfaceAlt;
        label = position ?? 'Position';
    }

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

  /// Badge de statut.
  Widget _buildStatusBadge(bool? isActive) {
    final active = isActive ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.successLight : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: active ? AppColors.successDark : AppColors.statusInactiveText,
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
    Navigator.of(context).pushNamed(AppRoutes.adminBannerForm);
  }

  void _navigateToEdit(dynamic banner) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminBannerForm,
      arguments: {'banner_id': banner.id},
    );
  }

  Future<void> _confirmDelete(dynamic banner) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer cette bannière ?',
      message: 'Cette bannière sera définitivement supprimée.',
      type: AdminDialogType.danger,
      confirmLabel: 'Supprimer',
    );

    if (result == true) {
      // Suppression de la bannière
    }
  }
}