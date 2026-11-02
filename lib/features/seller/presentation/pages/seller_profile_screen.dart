// ============================================
// PAGE : SellerProfileScreen
// ============================================
// Écran du profil boutique vendeur.
//
// Structure :
//   - Header visuel (bannière + avatar + nom + KYC)
//   - Actions rapides (modifier, uploader logo/bannière)
//   - Alerte KYC (si pending/rejected)
//   - Section statistiques (produits, commandes, note)
//   - Section informations (contact, adresse)
//   - Section finance (solde, commission)
//   - BottomSheet édition profil
//   - BottomSheet KYC (upload documents)
//
// UX :
//   - Pull-to-refresh
//   - Loading skeleton
//   - Error state avec retry
//   - Upload via image_picker
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Image picker
import 'package:image_picker/image_picker.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Domain
import '../../domain/entities/seller_profile.dart';

// Presentation
import '../providers/seller_profile_provider.dart';
import '../widgets/seller_scaffold.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SellerProfileProvider>();
      if (provider.status == SellerProfileStatus.initial) {
        provider.loadProfile();
      }
    });
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SellerScaffold(
      currentIndex: 8,
      title: 'Ma boutique',
      subtitle: 'Gérez votre profil vendeur',
      showBackButton: false,
      extraActions: [
        Consumer<SellerProfileProvider>(
          builder: (context, provider, _) {
            if (!provider.hasProfile) return const SizedBox.shrink();

            return IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 22,
                color: AppColors.textPrimary,
              ),
              onPressed: () => _showEditSheet(provider.profile!),
              tooltip: 'Modifier',
            );
          },
        ),
      ],
      child: Consumer<SellerProfileProvider>(
        builder: (context, provider, _) {
          return _buildContent(provider);
        },
      ),
    );
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent(SellerProfileProvider provider) {
    if (provider.isLoading && !provider.hasProfile) {
      return _buildSkeleton();
    }

    if (provider.isUnauthorized) {
      return _buildUnauthorizedState();
    }

    if (provider.hasError && !provider.hasProfile) {
      return _buildErrorState(provider);
    }

    if (!provider.hasProfile) {
      return _buildEmptyState();
    }

    final profile = provider.profile!;

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppColors.warning,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // HEADER VISUEL
            // ============================================
            _buildHeader(profile, provider),

            const SizedBox(height: 16),

            // ============================================
            // ALERTE KYC
            // ============================================
            if (profile.isKycPending || profile.isKycRejected)
              _buildKycAlert(profile, provider),

            // ============================================
            // STATS
            // ============================================
            _buildStatsCard(profile),

            const SizedBox(height: 12),

            // ============================================
            // INFORMATIONS
            // ============================================
            _buildInfoCard(profile),

            const SizedBox(height: 12),

            // ============================================
            // FINANCE
            // ============================================
            _buildFinanceCard(profile),

            const SizedBox(height: 12),

            // ============================================
            // ACTIONS
            // ============================================
            _buildActionsSection(profile, provider),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HEADER VISUEL
  // ============================================

  Widget _buildHeader(SellerProfile profile, SellerProfileProvider provider) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bannière
        GestureDetector(
          onTap: () => _pickBanner(provider),
          child: Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              gradient: profile.hasBanner
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.warning.withValues(alpha: 0.3),
                        AppColors.warning.withValues(alpha: 0.1),
                      ],
                    ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // Image ou placeholder
                  Positioned.fill(
                    child: profile.hasBanner
                        ? Image.network(
                            profile.bannerUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildBannerPlaceholder(),
                          )
                        : _buildBannerPlaceholder(),
                  ),

                  // Overlay gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bouton "Changer bannière"
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildImageActionButton(
                      icon: Icons.photo_camera_outlined,
                      label: 'Changer',
                      isLoading: provider.isUploadingBanner,
                      onTap: () => _pickBanner(provider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Avatar logo
        Positioned(
          left: 20,
          bottom: 0,
          child: GestureDetector(
            onTap: () => _pickLogo(provider),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profile.hasLogo
                        ? Image.network(
                            profile.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildAvatarFallback(profile),
                          )
                        : _buildAvatarFallback(profile),
                  ),
                ),

                // Bouton caméra
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: provider.isUploadingLogo
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Infos boutique
        Positioned(
          left: 132,
          right: 16,
          bottom: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.shopName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: AppColors.info,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              _buildKycBadge(profile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.3),
            AppColors.warning.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: 48,
          color: AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(SellerProfile profile) {
    return Container(
      color: AppColors.warning,
      child: Center(
        child: Text(
          profile.shopInitials,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKycBadge(SellerProfile profile) {
    final color = Color(profile.kycStatus.colorHex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            profile.isKycVerified
                ? Icons.verified_user_rounded
                : profile.isKycPending
                    ? Icons.hourglass_empty_rounded
                    : Icons.gpp_bad_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            profile.kycStatusLabel,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ALERTE KYC
  // ============================================

  Widget _buildKycAlert(SellerProfile profile, SellerProfileProvider provider) {
    final isRejected = profile.isKycRejected;
    final color = isRejected ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRejected
                    ? Icons.gpp_bad_outlined
                    : Icons.hourglass_empty_rounded,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isRejected
                      ? 'Votre KYC a été refusé'
                      : 'Votre KYC est en cours de vérification',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isRejected ? AppColors.errorDark : AppColors.warningDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isRejected
                ? profile.kycRejectionReason ??
                    'Veuillez soumettre à nouveau vos documents.'
                : 'Nous vérifions vos documents sous 24-48h.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showKycSheet(provider),
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: Text(
                isRejected ? 'Resoumettre le KYC' : 'Compléter le KYC',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS CARD
  // ============================================

  Widget _buildStatsCard(SellerProfile profile) {
    return _buildCard(
      icon: Icons.insights_rounded,
      title: 'Statistiques',
      children: [
        Row(
          children: [
            _buildStatItem(
              icon: Icons.inventory_2_outlined,
              value: '${profile.productsCount}',
              label: 'Produits',
              color: AppColors.info,
            ),
            _buildStatItem(
              icon: Icons.receipt_long_outlined,
              value: '${profile.ordersCount}',
              label: 'Commandes',
              color: AppColors.warning,
            ),
            _buildStatItem(
              icon: Icons.star_rounded,
              value: profile.averageRatingFormatted,
              label: 'Note',
              color: AppColors.ratingColor,
            ),
            _buildStatItem(
              icon: Icons.rate_review_outlined,
              value: '${profile.reviewsCount}',
              label: 'Avis',
              color: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
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
  // INFO CARD
  // ============================================

  Widget _buildInfoCard(SellerProfile profile) {
    return _buildCard(
      icon: Icons.info_outline_rounded,
      title: 'Informations',
      children: [
        if (profile.hasDescription)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              profile.description!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        if (profile.hasPhone)
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Téléphone',
            value: profile.phone!,
          ),
        if (profile.hasEmail)
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: profile.email!,
          ),
        if (profile.address != null && profile.address!.isNotEmpty)
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value: profile.address!,
          ),
        if (profile.hasLocation)
          _buildInfoRow(
            icon: Icons.map_outlined,
            label: 'Localisation',
            value: profile.formattedLocation,
          ),
        if (!profile.hasDescription &&
            !profile.hasPhone &&
            !profile.hasEmail &&
            !profile.hasLocation)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                'Aucune information renseignée',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.3,
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
  // FINANCE CARD
  // ============================================

  Widget _buildFinanceCard(SellerProfile profile) {
    return _buildCard(
      icon: Icons.payments_outlined,
      title: 'Finance',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFinanceItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Solde disponible',
                value: profile.balanceFormatted,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFinanceItem(
                icon: Icons.hourglass_bottom_rounded,
                label: 'En attente',
                value: profile.pendingBalanceFormatted,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFinanceItem(
                icon: Icons.trending_up_rounded,
                label: 'CA total',
                value: profile.totalRevenueFormatted,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFinanceItem(
                icon: Icons.percent_rounded,
                label: 'Commission',
                value: '${profile.commissionRate.toStringAsFixed(1)}%',
                color: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinanceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

  Widget _buildActionsSection(
    SellerProfile profile,
    SellerProfileProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Modifier les informations',
            onTap: () => _showEditSheet(profile),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.photo_library_outlined,
            label: 'Changer le logo',
            onTap: () => _pickLogo(provider),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            icon: Icons.image_outlined,
            label: 'Changer la bannière',
            onTap: () => _pickBanner(provider),
          ),
          if (profile.canSubmitKyc) ...[
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.verified_user_outlined,
              label: 'Soumettre le KYC',
              color: AppColors.info,
              onTap: () => _showKycSheet(provider),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.warning;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: effectiveColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // CARD GÉNÉRIQUE
  // ============================================

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ============================================
  // ACTIONS : PICK IMAGES
  // ============================================

  Future<void> _pickLogo(SellerProfileProvider provider) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (file == null || !mounted) return;

      final result = await provider.uploadLogo(file.path);

      if (!mounted) return;

      if (result != null) {
        _showSuccess('Logo mis à jour');
      } else {
        _showError(provider.actionError ?? 'Erreur upload');
      }
    } catch (e) {
      _showError('Impossible de sélectionner l\'image');
    }
  }

  Future<void> _pickBanner(SellerProfileProvider provider) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 800,
      );

      if (file == null || !mounted) return;

      final result = await provider.uploadBanner(file.path);

      if (!mounted) return;

      if (result != null) {
        _showSuccess('Bannière mise à jour');
      } else {
        _showError(provider.actionError ?? 'Erreur upload');
      }
    } catch (e) {
      _showError('Impossible de sélectionner l\'image');
    }
  }

  // ============================================
  // BOTTOM SHEETS
  // ============================================

  void _showEditSheet(SellerProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }

  void _showKycSheet(SellerProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _KycSheet(provider: provider),
    );
  }

  // ============================================
  // ÉTATS VIDES / ERREUR
  // ============================================

  Widget _buildEmptyState() {
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
                Icons.storefront_outlined,
                size: 42,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun profil boutique',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Veuillez contacter le support pour créer votre profil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(SellerProfileProvider provider) {
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
              provider.errorMessage ?? 'Impossible de charger le profil',
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
              onPressed: () => provider.loadProfile(forceRefresh: true),
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
  // SKELETON
  // ============================================

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 60),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ============================================
// BOTTOM SHEET : _EditProfileSheet
// ============================================

class _EditProfileSheet extends StatefulWidget {
  final SellerProfile profile;

  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.profile.shopName);
    _descriptionController =
        TextEditingController(text: widget.profile.description ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _addressController =
        TextEditingController(text: widget.profile.address ?? '');
    _cityController = TextEditingController(text: widget.profile.city ?? '');
    _countryController =
        TextEditingController(text: widget.profile.country ?? '');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Modifier les informations',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Nom boutique
                _buildField(
                  label: 'Nom de la boutique',
                  controller: _shopNameController,
                  hint: 'Ex: Ma super boutique',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Obligatoire';
                    }
                    if (v.trim().length < 3) return 'Minimum 3 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Description
                _buildField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'Décrivez votre boutique...',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Phone
                _buildField(
                  label: 'Téléphone',
                  controller: _phoneController,
                  hint: '+237 6 50 00 00 00',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                // Email
                _buildField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'contact@boutique.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Adresse
                _buildField(
                  label: 'Adresse',
                  controller: _addressController,
                  hint: 'Rue, quartier...',
                ),
                const SizedBox(height: 12),

                // Ville
                _buildField(
                  label: 'Ville',
                  controller: _cityController,
                  hint: 'Douala',
                ),
                const SizedBox(height: 12),

                // Pays
                _buildField(
                  label: 'Pays',
                  controller: _countryController,
                  hint: 'Cameroun',
                ),
                const SizedBox(height: 20),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SellerProfileProvider>();

    final data = <String, dynamic>{
      'shop_name': _shopNameController.text.trim(),
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
      if (_emailController.text.trim().isNotEmpty)
        'email': _emailController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
      if (_cityController.text.trim().isNotEmpty)
        'city': _cityController.text.trim(),
      if (_countryController.text.trim().isNotEmpty)
        'country': _countryController.text.trim(),
    };

    final result = await provider.updateProfile(data);

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil mis à jour',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.actionError ?? 'Erreur',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ============================================
// BOTTOM SHEET : _KycSheet
// ============================================

class _KycSheet extends StatefulWidget {
  final SellerProfileProvider provider;

  const _KycSheet({required this.provider});

  @override
  State<_KycSheet> createState() => _KycSheetState();
}

class _KycSheetState extends State<_KycSheet> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _idType;
  String? _idDocumentPath;
  String? _businessLicensePath;
  String? _selfiePath;

  static const _idTypes = [
    {'value': 'cni', 'label': 'Carte Nationale d\'Identité'},
    {'value': 'passport', 'label': 'Passeport'},
    {'value': 'license', 'label': 'Permis de conduire'},
    {'value': 'residence', 'label': 'Carte de séjour'},
  ];

  @override
  void dispose() {
    _idNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Vérification KYC',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vos documents sont sécurisés et confidentiels',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),

                // Type de document
                _buildLabel('Type de document *'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _idType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Sélectionner',
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: _idTypes
                      .map((t) => DropdownMenuItem<String>(
                            value: t['value'],
                            child: Text(
                              t['label']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _idType = v),
                  validator: (v) => v == null ? 'Requis' : null,
                ),
                const SizedBox(height: 16),

                // Numéro
                _buildLabel('Numéro du document *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    hintText: 'Ex: 123456789',
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requis';
                    if (v.trim().length < 5) return 'Minimum 5 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Document recto
                _buildLabel('Photo du document *'),
                const SizedBox(height: 6),
                _buildFilePicker(
                  label: 'Document d\'identité',
                  filePath: _idDocumentPath,
                  onTap: () => _pickFile('id'),
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // Registre de commerce
                _buildLabel('Registre de commerce (optionnel)'),
                const SizedBox(height: 6),
                _buildFilePicker(
                  label: 'Registre de commerce',
                  filePath: _businessLicensePath,
                  onTap: () => _pickFile('business'),
                ),
                const SizedBox(height: 16),

                // Selfie
                _buildLabel('Selfie (optionnel)'),
                const SizedBox(height: 6),
                _buildFilePicker(
                  label: 'Selfie',
                  filePath: _selfiePath,
                  onTap: () => _pickFile('selfie'),
                ),
                const SizedBox(height: 16),

                // Notes
                _buildLabel('Notes (optionnel)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Informations complémentaires...',
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.verified_user_rounded, size: 18),
                    label: const Text(
                      'Soumettre pour vérification',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFilePicker({
    required String label,
    required String? filePath,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    final hasFile = filePath != null && filePath.isNotEmpty;

    return Material(
      color: hasFile
          ? AppColors.successLight
          : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFile ? AppColors.success : AppColors.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasFile
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                size: 20,
                color: hasFile ? AppColors.success : AppColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasFile ? 'Fichier sélectionné' : label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: hasFile ? AppColors.successDark : AppColors.textSecondary,
                  ),
                ),
              ),
              if (hasFile)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textTertiary,
                  onPressed: () {
                    setState(() {
                      if (isRequired) _idDocumentPath = null;
                      // Simplification : on ne gère qu'un effacement
                    });
                  },
                )
              else
                Icon(
                  isRequired ? Icons.add_photo_alternate_rounded : Icons.add_rounded,
                  size: 20,
                  color: AppColors.warning,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (file == null || !mounted) return;

      setState(() {
        switch (type) {
          case 'id':
            _idDocumentPath = file.path;
            break;
          case 'business':
            _businessLicensePath = file.path;
            break;
          case 'selfie':
            _selfiePath = file.path;
            break;
        }
      });
    } catch (e) {
      debugPrint('❌ Erreur pickFile: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_idDocumentPath == null || _idDocumentPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner le document d\'identité',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await widget.provider.submitKyc(
      idType: _idType!,
      idNumber: _idNumberController.text.trim(),
      idDocumentPath: _idDocumentPath!,
      businessLicensePath: _businessLicensePath,
      selfiePath: _selfiePath,
      kycNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'KYC soumis. Vérification sous 24-48h.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.provider.actionError ?? 'Erreur',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
