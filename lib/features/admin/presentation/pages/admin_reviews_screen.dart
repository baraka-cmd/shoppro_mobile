// ============================================
// PAGE : AdminReviewsScreen (MOBILE SENIOR)
// ============================================
// Écran de modération des avis clients.
// - Vue liste OU groupée par produit
// - Filtres : statut, note, photos, vérifiés
// - Photos miniatures
// - Actions de modération contextuelles
// - Pull-to-refresh + scroll infini
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Providers
import '../providers/admin_review_provider.dart';

// Entities
import '../../domain/entities/admin_review.dart';

// Widgets
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final provider = context.read<AdminReviewProvider>();
    await provider.loadReviews();
    await provider.loadStatsByProduct();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Avis clients',
      subtitle: 'Modérez les avis',
      currentRoute: AppRoutes.adminReviews,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () {},
      child: _buildContent(),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminReviewProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.reviews.isEmpty && provider.groupedByProduct.isEmpty) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: AdminLoadingState(
              type: AdminLoadingType.list,
              itemCount: 6,
            ),
          );
        }

        if (provider.hasError && provider.reviews.isEmpty && provider.groupedByProduct.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: _loadReviews,
            ),
          );
        }

        return Column(
          children: [
            // Stats rapides
            _buildQuickStats(provider),

            // Filtres par statut
            _buildStatusTabs(provider),

            const SizedBox(height: 6),

            // Filtres secondaires (photos, vérifiés, groupé)
            _buildSecondaryFilters(provider),

            const SizedBox(height: 6),

            // Contenu : liste OU groupé
            Expanded(
              child: provider.isGroupedByProduct
                  ? _buildGroupedList(provider)
                  : _buildFlatList(provider),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // STATS RAPIDES
  // ============================================

  Widget _buildQuickStats(AdminReviewProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          _buildStatTile(
            label: 'Total',
            value: '${provider.statusCounts.values.fold(0, (a, b) => a + b)}',
            color: AppColors.info,
          ),
          _buildStatTile(
            label: 'En attente',
            value: '${provider.statusCounts['pending'] ?? 0}',
            color: AppColors.warning,
          ),
          _buildStatTile(
            label: 'Avec photos',
            value: '${provider.withPhotosCount}',
            color: const Color(0xFF8B5CF6),
          ),
          _buildStatTile(
            label: 'Moyenne',
            value: provider.averageRating.toStringAsFixed(1),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
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
  // FILTRES PAR STATUT
  // ============================================

  Widget _buildStatusTabs(AdminReviewProvider provider) {
    final tabs = [
      {'label': 'Tous', 'status': null},
      {'label': 'En attente', 'status': 'pending'},
      {'label': 'Approuvés', 'status': 'approved'},
      {'label': 'Rejetés', 'status': 'rejected'},
      {'label': 'Spam', 'status': 'spam'},
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = provider.filterStatus?.code == tab['status'];

          return Material(
            color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                final statusCode = tab['status'] as String?;
                if (statusCode == null) {
                  provider.filterByStatus(null);
                } else {
                  final status = AdminReviewStatus.fromCode(statusCode);
                  provider.filterByStatus(status);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  tab['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // FILTRES SECONDAIRES
  // ============================================

  Widget _buildSecondaryFilters(AdminReviewProvider provider) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(vertical: 2),
      color: AppColors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // ✅ Toggle Groupé par produit
          _buildToggleChip(
            label: 'Groupé par produit',
            icon: Icons.folder_outlined,
            isSelected: provider.isGroupedByProduct,
            onTap: () => provider.toggleGroupedByProduct(),
          ),
          const SizedBox(width: 6),

          // ✅ Filtre avec photos
          _buildToggleChip(
            label: 'Avec photos (${provider.withPhotosCount})',
            icon: Icons.photo_camera_outlined,
            isSelected: provider.filterWithPhotos,
            onTap: () => provider.filterByPhotos(!provider.filterWithPhotos),
          ),
          const SizedBox(width: 6),

          // ✅ Filtre vérifiés
          _buildToggleChip(
            label: 'Vérifiés (${provider.verifiedCount})',
            icon: Icons.verified_outlined,
            isSelected: provider.filterVerified,
            onTap: () => provider.filterByVerified(!provider.filterVerified),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // LISTE PLATE (non groupée)
  // ============================================

  Widget _buildFlatList(AdminReviewProvider provider) {
    if (provider.isEmpty) {
      return AdminEmptyState(
        icon: Icons.star_outline,
        title: 'Aucun avis',
        message: 'Les avis clients apparaîtront ici.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.reviews.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loader en bas
          if (index == provider.reviews.length) {
            _triggerLoadMore(provider);
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final review = provider.reviews[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReviewCard(review, provider),
          );
        },
      ),
    );
  }

  void _triggerLoadMore(AdminReviewProvider provider) {
    if (provider.hasMore && !provider.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadMoreReviews();
      });
    }
  }

  // ============================================
  // LISTE GROUPÉE PAR PRODUIT
  // ============================================

  Widget _buildGroupedList(AdminReviewProvider provider) {
    if (!provider.hasGroups) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Aucun produit avec avis',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReviews,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.groupedByProduct.length,
        itemBuilder: (context, index) {
          final group = provider.groupedByProduct[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProductGroup(group, provider),
          );
        },
      ),
    );
  }

  // ============================================
  // GROUPE PAR PRODUIT (ACCORDÉON)
  // ============================================

  Widget _buildProductGroup(
    Map<String, dynamic> group,
    AdminReviewProvider provider,
  ) {
    final product = group['product'] as Map<String, dynamic>? ?? {};
    final stats = group['stats'] as Map<String, dynamic>? ?? {};
    final reviews = group['reviews'] as List<AdminReview>? ?? [];

    final productName = product['name']?.toString() ?? 'Produit';
    final productImage = product['image']?.toString();
    final totalReviews = (stats['total'] as num?)?.toInt() ?? reviews.length;
    final avgRating = (stats['average_rating'] as num?)?.toDouble() ?? 0;
    final pending = (stats['pending'] as num?)?.toInt() ?? 0;
    final withPhotos = (stats['with_photos'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              color: AppColors.surfaceAlt,
              child: productImage != null && productImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: productImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: AppColors.textLight,
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: AppColors.textLight,
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: AppColors.textLight,
                    ),
            ),
          ),
          title: Text(
            productName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildMiniBadge(
                  '$totalReviews avis',
                  AppColors.info,
                  Icons.reviews_outlined,
                ),
                _buildMiniBadge(
                  '${avgRating.toStringAsFixed(1)} ⭐',
                  AppColors.warning,
                  Icons.star_outline,
                ),
                if (pending > 0)
                  _buildMiniBadge(
                    '$pending en attente',
                    AppColors.error,
                    Icons.hourglass_empty,
                  ),
                if (withPhotos > 0)
                  _buildMiniBadge(
                    '$withPhotos photos',
                    const Color(0xFF8B5CF6),
                    Icons.photo_camera_outlined,
                  ),
              ],
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textTertiary,
          children: [
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Aucun avis',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              )
            else
              ...reviews.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildReviewCard(review, provider, compact: true),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CARTE AVIS
  // ============================================

  Widget _buildReviewCard(
    AdminReview review,
    AdminReviewProvider provider, {
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: compact ? AppColors.surfaceAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: compact ? [] : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Avatar + Nom + Étoiles + Statut
          Row(
            children: [
              _buildUserAvatar(review, compact: compact),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: compact ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 12,
                            color: AppColors.warning,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          review.createdAtFormatted,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9.5,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(review),
            ],
          ),

          const SizedBox(height: 10),

          // Titre (si présent)
          if (review.hasTitle) ...[
            Text(
              review.title!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],

          // Contenu
          Text(
            review.content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: compact ? 2 : 4,
            overflow: TextOverflow.ellipsis,
          ),

          // ✅ PHOTOS DE L'AVIS
          if (review.hasImages) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: review.images[i],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceAlt,
                        child: const Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surfaceAlt,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Produit concerné (masqué en mode groupé)
          if (!compact) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      review.productName,
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
                ],
              ),
            ),
          ],

          // Réponse admin existante
          if (review.hasAdminResponse) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 12,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Réponse admin',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.adminResponse!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 8),

          // Actions contextuelles
          _buildReviewActions(review, provider, compact: compact),
        ],
      ),
    );
  }

  // ============================================
  // AVATAR
  // ============================================

  Widget _buildUserAvatar(AdminReview review, {bool compact = false}) {
    final hasAvatar = review.userAvatar != null && review.userAvatar!.isNotEmpty;
    final size = compact ? 32.0 : 40.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? CachedNetworkImage(
              imageUrl: review.userAvatar!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildInitials(review.userName, compact),
              errorWidget: (_, __, ___) =>
                  _buildInitials(review.userName, compact),
            )
          : _buildInitials(review.userName, compact),
    );
  }

  Widget _buildInitials(String name, bool compact) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // BADGE STATUT
  // ============================================

  Widget _buildStatusBadge(AdminReview review) {
    Color bgColor;
    Color textColor;
    String label;

    if (review.isPending) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'En attente';
    } else if (review.isApproved) {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'Approuvé';
    } else if (review.isRejected) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Rejeté';
    } else if (review.isSpam) {
      bgColor = AppColors.surfaceAlt;
      textColor = AppColors.textTertiary;
      label = 'Spam';
    } else {
      bgColor = AppColors.surfaceAlt;
      textColor = AppColors.textTertiary;
      label = 'Inconnu';
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
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  Widget _buildReviewActions(
    AdminReview review,
    AdminReviewProvider provider, {
    bool compact = false,
  }) {
    final actions = <Widget>[];

    if (review.isPending) {
      actions.add(_buildActionButton(
        label: 'Approuver',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        onTap: () => provider.approveReview(review.id),
      ));
      actions.add(const SizedBox(width: 6));
      actions.add(_buildActionButton(
        label: 'Rejeter',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        onTap: () => _confirmReject(provider, review),
      ));
    } else if (review.isApproved) {
      actions.add(_buildActionButton(
        label: review.hasAdminResponse ? 'Modifier réponse' : 'Répondre',
        icon: Icons.reply_outlined,
        color: AppColors.info,
        onTap: () => _showRespondDialog(provider, review),
      ));
    } else if (review.isRejected || review.isSpam) {
      actions.add(_buildActionButton(
        label: 'Remettre en attente',
        icon: Icons.refresh,
        color: AppColors.warning,
        onTap: () => provider.resetToPending(review.id),
      ));
    }

    // Toujours : Supprimer
    actions.add(const SizedBox(width: 6));
    actions.add(_buildActionButton(
      label: 'Supprimer',
      icon: Icons.delete_outline,
      color: AppColors.error,
      onTap: () => _confirmDelete(provider, review),
    ));

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

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
  // DIALOGS
  // ============================================

  Future<void> _confirmReject(
    AdminReviewProvider provider,
    AdminReview review,
  ) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Rejeter cet avis ?',
      message: 'L\'avis sera masqué aux clients.',
      type: AdminDialogType.warning,
      confirmLabel: 'Rejeter',
    );

    if (result == true && mounted) {
      final success = await provider.rejectReview(review.id);
      if (mounted) {
        _showSnack(success, 'Avis rejeté', 'Impossible de rejeter');
      }
    }
  }

  Future<void> _confirmDelete(
    AdminReviewProvider provider,
    AdminReview review,
  ) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Supprimer cet avis ?',
      message: 'Cette action est irréversible.',
      type: AdminDialogType.danger,
      confirmLabel: 'Supprimer',
    );

    if (result == true && mounted) {
      final success = await provider.deleteReview(review.id);
      if (mounted) {
        _showSnack(success, 'Avis supprimé', 'Impossible de supprimer');
      }
    }
  }

  Future<void> _showRespondDialog(
    AdminReviewProvider provider,
    AdminReview review,
  ) async {
    final controller = TextEditingController(text: review.adminResponse ?? '');

    final response = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.hasAdminResponse
                      ? 'Modifier la réponse'
                      : 'Répondre à l\'avis',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'À ${review.userName}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Votre réponse...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (review.hasAdminResponse) ...[
                      TextButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          final success = await provider
                              .deleteAdminResponse(review.id);
                          if (mounted) {
                            _showSnack(
                              success,
                              'Réponse supprimée',
                              'Impossible',
                            );
                          }
                        },
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.of(dialogContext).pop(controller.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Envoyer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (response != null && response.isNotEmpty && mounted) {
      final success = review.hasAdminResponse
          ? await provider.updateAdminResponse(review.id, response)
          : await provider.respondToReview(review.id, response);

      if (mounted) {
        _showSnack(success, 'Réponse enregistrée', 'Impossible d\'enregistrer');
      }
    }
  }

  void _showSnack(bool success, String successMsg, String errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMsg : errorMsg,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}