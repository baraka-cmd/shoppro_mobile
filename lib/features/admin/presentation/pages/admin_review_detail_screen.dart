// ============================================
// PAGE : AdminReviewDetailScreen (MOBILE SENIOR)
// ============================================
// Écran de détail d'un avis client - Admin.
// - Détail complet de l'avis
// - Galerie de photos plein écran (swipe + zoom)
// - Produit associé
// - Utilisateur (avatar + infos)
// - Statistiques (votes, vues)
// - Réponse admin (affichage + édition)
// - Actions : approuver, rejeter, spam, supprimer
// - Pull-to-refresh
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Providers
import '../providers/admin_review_provider.dart';

// Entities
import '../../domain/entities/admin_review.dart';

// Widgets
import '../widgets/admin_confirm_dialog.dart';

class AdminReviewDetailScreen extends StatefulWidget {
  final int reviewId;

  const AdminReviewDetailScreen({super.key, required this.reviewId});

  @override
  State<AdminReviewDetailScreen> createState() =>
      _AdminReviewDetailScreenState();
}

class _AdminReviewDetailScreenState extends State<AdminReviewDetailScreen>
    with SingleTickerProviderStateMixin {
  // ============================================
  // ÉTAT LOCAL
  // ============================================

  AdminReview? _review;
  bool _isLoading = true;
  String? _errorMessage;

  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReview();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<AdminReviewProvider>();

      // Essayer depuis la liste locale d'abord
      AdminReview? review = provider.reviews.firstWhere(
        (r) => r.id == widget.reviewId,
        orElse: () => _emptyReview,
      );

      if (review.id == 0) review = null;

      // Sinon, charger depuis l'API
      review ??= await provider.getReviewById(widget.reviewId);

      if (!mounted) return;

      if (review == null) {
        setState(() {
          _errorMessage = 'Avis introuvable';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _review = review;
        _isLoading = false;
      });

      _entryController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Avis vide (utilisé pour la recherche locale).
  static final AdminReview _emptyReview = AdminReview(
    id: 0,
    content: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    rating: 0,
    userId: 0,
    userName: '',
    productId: 0,
    productName: '',
  );

  Future<void> _reload() async {
    await _loadReview();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détail de l\'avis',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (_review != null)
            Text(
              '#${_review!.id}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Rafraîchir',
          icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          onPressed: _isLoading ? null : _reload,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_review == null) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _reload,
      color: AppColors.primary,
      child: FadeTransition(
        opacity: _fadeIn,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // 1. Hero (note + statut)
            _buildHeroBanner(),

            const SizedBox(height: 16),

            // 2. Utilisateur
            _buildUserSection(),

            const SizedBox(height: 16),

            // 3. Produit
            _buildProductSection(),

            const SizedBox(height: 16),

            // 4. Contenu de l'avis
            _buildContentSection(),

            const SizedBox(height: 16),

            // 5. Photos
            if (_review!.hasImages) ...[
              _buildImagesSection(),
              const SizedBox(height: 16),
            ],

            // 6. Réponse admin
            _buildAdminResponseSection(),

            const SizedBox(height: 16),

            // 7. Statistiques
            _buildStatsSection(),

            const SizedBox(height: 16),

            // 8. Actions
            _buildActionsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HERO — NOTE + STATUT
  // ============================================

  Widget _buildHeroBanner() {
    final review = _review!;
    final statusInfo = _getStatusInfo(review.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusInfo['color']!.withValues(alpha: 0.12),
            statusInfo['color']!.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo['color']!.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusInfo['color']!.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusInfo['icon'] as IconData,
                  color: statusInfo['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusInfo['color'],
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.createdAtFormatted,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Colors.white54),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildHeroStat(
                'Note globale',
                '${review.rating}/5',
                Icons.star,
              ),
              const SizedBox(width: 12),
              _buildHeroStat(
                'Votes',
                '${review.totalVotes}',
                Icons.thumb_up_outlined,
              ),
              const SizedBox(width: 12),
              _buildHeroStat(
                'Vues',
                review.viewsCountFormatted,
                Icons.visibility_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // UTILISATEUR
  // ============================================

  Widget _buildUserSection() {
    final review = _review!;
    final hasAvatar = review.userAvatar != null && review.userAvatar!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AUTEUR',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: hasAvatar
                    ? CachedNetworkImage(
                        imageUrl: review.userAvatar!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildInitials(review.userName),
                        errorWidget: (_, __, ___) =>
                            _buildInitials(review.userName),
                      )
                    : _buildInitials(review.userName),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (review.userEmail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        review.userEmail,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (review.isVerifiedPurchase) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 11,
                              color: AppColors.successDark,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Achat vérifié',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.successDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // PRODUIT
  // ============================================

  Widget _buildProductSection() {
    final review = _review!;
    final hasImage =
        review.productImage != null && review.productImage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUIT CONCERNÉ',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceAlt,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: review.productImage!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Icon(
                            Icons.inventory_2_outlined,
                            size: 24,
                            color: AppColors.textLight,
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 24,
                            color: AppColors.textLight,
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          size: 24,
                          color: AppColors.textLight,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.productName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (review.productSku != null &&
                        review.productSku!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'SKU : ${review.productSku}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // CONTENU DE L'AVIS
  // ============================================

  Widget _buildContentSection() {
    final review = _review!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONTENU DE L\'AVIS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Étoiles
          Row(
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 18,
                  color: AppColors.warning,
                );
              }),
              const SizedBox(width: 8),
              Text(
                review.ratingLabel,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Titre
          if (review.hasTitle) ...[
            Text(
              review.title!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Contenu
          Text(
            review.content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PHOTOS
  // ============================================

  Widget _buildImagesSection() {
    final images = _review!.images;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PHOTOS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${images.length}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () => _openImageGallery(i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: images[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 100,
                        height: 100,
                        color: AppColors.surfaceAlt,
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: AppColors.surfaceAlt,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 24,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  Widget _buildAdminResponseSection() {
    final review = _review!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'RÉPONSE ADMIN',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showRespondDialog,
                icon: Icon(
                  review.hasAdminResponse ? Icons.edit : Icons.reply,
                  size: 14,
                  color: AppColors.info,
                ),
                label: Text(
                  review.hasAdminResponse ? 'Modifier' : 'Répondre',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (review.hasAdminResponse)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 14,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Répondu ${review.adminResponseAtFormatted}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.adminResponse!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aucune réponse. Cliquez sur "Répondre" pour en ajouter une.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // STATISTIQUES
  // ============================================

  Widget _buildStatsSection() {
    final review = _review!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATISTIQUES',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatTile(
                icon: Icons.thumb_up_outlined,
                label: 'Utile',
                value: '${review.helpfulCount}',
                color: AppColors.success,
              ),
              const SizedBox(width: 10),
              _buildStatTile(
                icon: Icons.thumb_down_outlined,
                label: 'Pas utile',
                value: '${review.notHelpfulCount}',
                color: AppColors.error,
              ),
              const SizedBox(width: 10),
              _buildStatTile(
                icon: Icons.visibility_outlined,
                label: 'Vues',
                value: review.viewsCountFormatted,
                color: AppColors.info,
              ),
            ],
          ),
          if (review.hasVotes) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Taux d\'utilité',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: review.helpfulRate / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceAlt,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.helpfulRateFormatted,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
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
                fontSize: 9.5,
                color: AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  Widget _buildActionsSection() {
    final review = _review!;
    final actions = <Widget>[];

    // Approuver (si en attente)
    if (review.isPending) {
      actions.add(_buildPrimaryAction(
        label: 'Approuver l\'avis',
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        onTap: () => _executeAction('approve'),
      ));
      actions.add(const SizedBox(height: 8));
      actions.add(_buildPrimaryAction(
        label: 'Rejeter l\'avis',
        icon: Icons.cancel_outlined,
        color: AppColors.error,
        onTap: () => _executeAction('reject'),
      ));
    }

    // Répondre (si approuvé)
    if (review.isApproved) {
      actions.add(_buildPrimaryAction(
        label: review.hasAdminResponse
            ? 'Modifier la réponse'
            : 'Répondre à l\'avis',
        icon: Icons.reply_outlined,
        color: AppColors.info,
        onTap: _showRespondDialog,
      ));
    }

    // Remettre en attente (si rejeté ou spam)
    if (review.isRejected || review.isSpam) {
      actions.add(_buildPrimaryAction(
        label: 'Remettre en attente',
        icon: Icons.refresh,
        color: AppColors.warning,
        onTap: () => _executeAction('reset'),
      ));
    }

    // Marquer comme spam (si pas spam)
    if (!review.isSpam) {
      actions.add(const SizedBox(height: 8));
      actions.add(_buildPrimaryAction(
        label: 'Marquer comme spam',
        icon: Icons.block,
        color: const Color(0xFF8B5CF6),
        onTap: () => _executeAction('spam'),
      ));
    }

    // Supprimer
    actions.add(const SizedBox(height: 8));
    actions.add(_buildPrimaryAction(
      label: 'Supprimer l\'avis',
      icon: Icons.delete_outline,
      color: AppColors.error,
      onTap: () => _executeAction('delete'),
      isDanger: true,
    ));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIONS',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildPrimaryAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: isDanger
          ? AppColors.error.withValues(alpha: 0.05)
          : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // EXÉCUTION DES ACTIONS
  // ============================================

  Future<void> _executeAction(String type) async {
    final review = _review!;
    final provider = context.read<AdminReviewProvider>();

    // Confirmation
    final confirmed = await _confirmAction(type);
    if (confirmed != true) return;
    if (!mounted) return;

    bool success = false;
    String successMsg = '';
    String errorMsg = '';

    switch (type) {
      case 'approve':
        success = await provider.approveReview(review.id);
        successMsg = 'Avis approuvé';
        errorMsg = 'Impossible d\'approuver';
        break;

      case 'reject':
        success = await provider.rejectReview(review.id);
        successMsg = 'Avis rejeté';
        errorMsg = 'Impossible de rejeter';
        break;

      case 'reset':
        success = await provider.resetToPending(review.id);
        successMsg = 'Avis remis en attente';
        errorMsg = 'Impossible de remettre en attente';
        break;

      case 'spam':
        success = await provider.markAsSpam(review.id);
        successMsg = 'Avis marqué comme spam';
        errorMsg = 'Impossible de marquer comme spam';
        break;

      case 'delete':
        success = await provider.deleteReview(review.id);
        successMsg = 'Avis supprimé';
        errorMsg = 'Impossible de supprimer';
        break;
    }

    if (!mounted) return;

    _showSnack(success, successMsg, errorMsg);

    // Si suppression → fermer l'écran
    if (type == 'delete' && success) {
      Navigator.of(context).pop();
      return;
    }

    // Sinon recharger
    if (success) {
      await _reload();
    }
  }

  Future<bool?> _confirmAction(String type) async {
    String title;
    String message;
    AdminDialogType dialogType;
    String confirmLabel;

    switch (type) {
      case 'approve':
        title = 'Approuver cet avis ?';
        message = 'L\'avis sera visible par tous les clients.';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'Approuver';
        break;

      case 'reject':
        title = 'Rejeter cet avis ?';
        message = 'L\'avis ne sera plus visible publiquement.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Rejeter';
        break;

      case 'reset':
        title = 'Remettre en attente ?';
        message = 'L\'avis repassera en file de modération.';
        dialogType = AdminDialogType.warning;
        confirmLabel = 'Remettre';
        break;

      case 'spam':
        title = 'Marquer comme spam ?';
        message = 'Cet avis sera classé comme spam.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Marquer';
        break;

      case 'delete':
        title = 'Supprimer cet avis ?';
        message = 'Cette action est irréversible.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Supprimer';
        break;

      default:
        return false;
    }

    return await AdminConfirmDialog.show(
      context: context,
      title: title,
      message: message,
      type: dialogType,
      confirmLabel: confirmLabel,
    );
  }

  // ============================================
  // DIALOG RÉPONSE ADMIN
  // ============================================

  Future<void> _showRespondDialog() async {
    final review = _review!;
    final provider = context.read<AdminReviewProvider>();
    final controller = TextEditingController(text: review.adminResponse ?? '');

    final response = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
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
                    fontWeight: FontWeight.bold,
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
                  maxLines: 5,
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
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (review.hasAdminResponse) ...[
                      TextButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          final success =
                              await provider.deleteAdminResponse(review.id);
                          if (mounted) {
                            _showSnack(
                              success,
                              'Réponse supprimée',
                              'Impossible de supprimer',
                            );
                            if (success) await _reload();
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
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(dialogContext).pop(text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Envoyer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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

    if (response == null || response.isEmpty || !mounted) return;

    final success = review.hasAdminResponse
        ? await provider.updateAdminResponse(review.id, response)
        : await provider.respondToReview(review.id, response);

    if (!mounted) return;

    _showSnack(success, 'Réponse enregistrée', 'Impossible d\'enregistrer');

    if (success) {
      await _reload();
    }
  }

  // ============================================
  // GALERIE D'IMAGES
  // ============================================

  void _openImageGallery(int initialIndex) {
    final images = _review!.images;
    if (images.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, _, __) => _ImageGalleryViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ============================================
  // ÉTATS ALTERNATIFS
  // ============================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Impossible de charger l\'avis.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'RÉESSAYER',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_outline,
              size: 60,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Avis introuvable',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  Map<String, dynamic> _getStatusInfo(AdminReviewStatus status) {
    switch (status) {
      case AdminReviewStatus.pending:
        return {
          'label': 'En attente',
          'color': AppColors.warning,
          'icon': Icons.hourglass_empty,
        };
      case AdminReviewStatus.approved:
        return {
          'label': 'Approuvé',
          'color': AppColors.success,
          'icon': Icons.check_circle_outline,
        };
      case AdminReviewStatus.rejected:
        return {
          'label': 'Rejeté',
          'color': AppColors.error,
          'icon': Icons.cancel_outlined,
        };
      case AdminReviewStatus.spam:
        return {
          'label': 'Spam',
          'color': AppColors.textTertiary,
          'icon': Icons.block,
        };
    }
  }

  void _showSnack(bool success, String successMsg, String errorMsg) {
    if (!mounted) return;
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

// ============================================
// VIEWER D'IMAGES PLEIN ÉCRAN
// ============================================

class _ImageGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<_ImageGalleryViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 60,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Bouton fermer
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Compteur
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}