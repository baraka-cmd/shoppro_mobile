// ============================================
// PAGE : AdminUserDetailScreen (MOBILE SENIOR)
// ============================================
// Écran de détail d'un utilisateur - 100% dynamique.
// - Charge les données depuis l'API
// - Accordéons pour les sections
// - Actions fonctionnelles (activer, bannir, changer rôle)
// - Pull-to-refresh
// - Bottom sheet pour les actions secondaires
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Providers
import '../providers/admin_user_provider.dart';

// Entities
import '../../domain/entities/admin_user.dart';

// Widgets
import '../widgets/admin_confirm_dialog.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeIn = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDetail();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetail() async {
    final provider = context.read<AdminUserProvider>();
    await provider.loadUserDetail(widget.userId);
    if (mounted) {
      _entryController.forward();
    }
  }

  Future<void> _reload() async {
    final provider = context.read<AdminUserProvider>();
    await provider.loadUserDetail(widget.userId);
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminUserProvider>(
      builder: (context, provider, _) {
        final user = provider.currentUser;

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: _buildAppBar(provider, user),
          body: _buildBody(provider, user),
        );
      },
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar(
    AdminUserProvider provider,
    AdminUser? user,
  ) {
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
            'Détail utilisateur',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (user != null)
            Text(
              user.email,
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
          icon: provider.isUpdating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.refresh, color: AppColors.textPrimary),
          onPressed: provider.isUpdating ? null : _reload,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================
  // BODY
  // ============================================

  Widget _buildBody(AdminUserProvider provider, AdminUser? user) {
    if (provider.isLoadingDetail && user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.hasError && user == null) {
      return _buildErrorState(provider.errorMessage);
    }

    if (user == null) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _reload,
      color: AppColors.primary,
      child: FadeTransition(
        opacity: _fadeIn,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // 1. Carte profil
            _buildProfileCard(user),

            const SizedBox(height: 16),

            // 2. Statistiques
            _buildStatsSection(user),

            const SizedBox(height: 16),

            // 3. Informations détaillées
            _buildInfoAccordion(user),

            const SizedBox(height: 16),

            // 4. Actions
            _buildActionsSection(provider, user),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================
  // SECTION : PROFIL
  // ============================================

  Widget _buildProfileCard(AdminUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(user),

          const SizedBox(height: 14),

          // Nom complet
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),

          // Badges (rôle + statut)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildRoleBadge(user),
              _buildStatusBadge(user),
            ],
          ),

          // Téléphone
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.borderColor),
            const SizedBox(height: 16),
            _buildProfileInfoRow(
              Icons.phone_outlined,
              user.phone!,
            ),
          ],

          // Localisation
          if ((user.city != null && user.city!.isNotEmpty) ||
              (user.country != null && user.country!.isNotEmpty)) ...[
            const SizedBox(height: 8),
            _buildProfileInfoRow(
              Icons.location_on_outlined,
              [user.city, user.country]
                  .where((e) => e != null && e.isNotEmpty)
                  .join(', '),
            ),
          ],

          // Adresse
          if (user.address != null && user.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildProfileInfoRow(
              Icons.home_outlined,
              user.address!,
            ),
          ],

          // Date de création
          const SizedBox(height: 8),
          _buildProfileInfoRow(
            Icons.calendar_today_outlined,
            'Membre depuis ${user.createdAtFormatted}',
          ),
        ],
      ),
    );
  }

  // ============================================
  // AVATAR
  // ============================================

  Widget _buildAvatar(AdminUser user) {
    final hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? CachedNetworkImage(
              imageUrl: user.avatar!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _buildInitials(user),
              errorWidget: (_, __, ___) => _buildInitials(user),
            )
          : _buildInitials(user),
    );
  }

  Widget _buildInitials(AdminUser user) {
    return Center(
      child: Text(
        user.initials,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // BADGES
  // ============================================

  Widget _buildRoleBadge(AdminUser user) {
    String label = 'Client';
    Color color = AppColors.successDark;
    Color bgColor = AppColors.successLight;
    IconData icon = Icons.person_outline;

    if (user.isAdmin) {
      label = 'Administrateur';
      color = const Color(0xFF6B21A8);
      bgColor = const Color(0xFFF3E8FF);
      icon = Icons.admin_panel_settings_outlined;
    } else if (user.isSeller) {
      label = 'Vendeur';
      color = AppColors.warningDark;
      bgColor = AppColors.warningLight;
      icon = Icons.storefront_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AdminUser user) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    if (user.isBanned) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Banni';
      icon = Icons.block;
    } else if (user.isSuspended) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'Suspendu';
      icon = Icons.pause_circle_outline;
    } else if (!user.isActive) {
      bgColor = AppColors.statusInactiveBg;
      textColor = AppColors.statusInactiveText;
      label = 'Inactif';
      icon = Icons.do_not_disturb_on_outlined;
    } else {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'Actif';
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // LIGNE D'INFO
  // ============================================

  Widget _buildProfileInfoRow(IconData icon, String text) {
    return Row(
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // SECTION : STATISTIQUES
  // ============================================

  Widget _buildStatsSection(AdminUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Statistiques d'activité",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatItem(
              icon: Icons.receipt_long_outlined,
              label: 'Commandes',
              value: '${user.totalOrders}',
              color: AppColors.info,
              bgColor: AppColors.infoLight,
            ),
            _buildStatItem(
              icon: Icons.payments_outlined,
              label: 'Total dépensé',
              value: user.totalSpentFormatted,
              color: AppColors.success,
              bgColor: AppColors.successLight,
            ),
            _buildStatItem(
              icon: Icons.star_outline,
              label: 'Avis postés',
              value: '${user.reviewsCount}',
              color: AppColors.warning,
              bgColor: AppColors.warningLight,
            ),
            _buildStatItem(
              icon: Icons.favorite_outline,
              label: 'Favoris',
              value: '${user.favoritesCount}',
              color: const Color(0xFFEC4899),
              bgColor: const Color(0xFFFCE7F3),
            ),
            _buildStatItem(
              icon: Icons.login,
              label: 'Dern. connexion',
              value: user.lastLoginFormatted,
              color: AppColors.textTertiary,
              bgColor: AppColors.surfaceAlt,
            ),
            _buildStatItem(
              icon: Icons.access_time,
              label: 'Membre depuis',
              value: user.createdAtFormatted,
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFF3E8FF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION : INFORMATIONS DÉTAILLÉES
  // ============================================

  Widget _buildInfoAccordion(AdminUser user) {
    return _buildAccordion(
      title: 'Informations détaillées',
      icon: Icons.info_outline,
      color: AppColors.info,
      initiallyExpanded: true,
      child: Column(
        children: [
          _buildInfoRow('ID', '${user.id}'),
          _buildInfoRow('Nom complet', user.fullName),
          _buildInfoRow('Email', user.email),
          if (user.firstName != null)
            _buildInfoRow('Prénom', user.firstName!),
          if (user.lastName != null)
            _buildInfoRow('Nom', user.lastName!),
          if (user.phone != null && user.phone!.isNotEmpty)
            _buildInfoRow('Téléphone', user.phone!),
          if (user.country != null && user.country!.isNotEmpty)
            _buildInfoRow('Pays', user.country!),
          if (user.city != null && user.city!.isNotEmpty)
            _buildInfoRow('Ville', user.city!),
          if (user.address != null && user.address!.isNotEmpty)
            _buildInfoRow('Adresse', user.address!),
          _buildInfoRow('Langue', user.language.toUpperCase()),
          _buildInfoRow('Devise', user.currency),
          _buildInfoRow(
            'Email vérifié',
            user.isVerified ? 'Oui' : 'Non',
            valueColor: user.isVerified
                ? AppColors.success
                : AppColors.warning,
          ),
          _buildInfoRow(
            'Dernière activité',
            user.lastActivityFormatted,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION : ACTIONS
  // ============================================

  Widget _buildActionsSection(
    AdminUserProvider provider,
    AdminUser user,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Actions de gestion',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _buildAvailableActions(provider, user),
        ),
      ],
    );
  }

  List<Widget> _buildAvailableActions(
    AdminUserProvider provider,
    AdminUser user,
  ) {
    final actions = <Widget>[];

    // Activer (si inactif ou suspendu)
    if (!user.isActive || user.isSuspended) {
      actions.add(_buildActionButton(
        label: 'Activer',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
        onTap: provider.isUpdating
            ? null
            : () => _executeAction(
                  provider,
                  'activate',
                  user,
                ),
      ));
    }

    // Désactiver (si actif)
    if (user.isActive && !user.isBanned) {
      actions.add(_buildActionButton(
        label: 'Désactiver',
        icon: Icons.do_not_disturb_on_outlined,
        color: AppColors.warning,
        onTap: provider.isUpdating
            ? null
            : () => _executeAction(
                  provider,
                  'deactivate',
                  user,
                ),
      ));
    }

    // Suspendre (si actif et non suspendu)
    if (user.isActive && !user.isSuspended && !user.isBanned) {
      actions.add(_buildActionButton(
        label: 'Suspendre',
        icon: Icons.pause_circle_outline_rounded,
        color: AppColors.warning,
        onTap: provider.isUpdating
            ? null
            : () => _executeAction(
                  provider,
                  'suspend',
                  user,
                ),
      ));
    }

    // Lever la suspension
    if (user.isSuspended) {
      actions.add(_buildActionButton(
        label: 'Lever susp.',
        icon: Icons.play_circle_outline,
        color: AppColors.info,
        onTap: provider.isUpdating
            ? null
            : () => _executeAction(
                  provider,
                  'unsuspend',
                  user,
                ),
      ));
    }

    // Changer rôle
    actions.add(_buildActionButton(
      label: 'Changer rôle',
      icon: Icons.swap_horiz_rounded,
      color: AppColors.info,
      onTap: provider.isUpdating
          ? null
          : () => _showRoleDialog(provider, user),
    ));

    // Bannir (si pas déjà banni)
    if (!user.isBanned) {
      actions.add(_buildActionButton(
        label: 'Bannir',
        icon: Icons.block_rounded,
        color: AppColors.error,
        onTap: provider.isUpdating
            ? null
            : () => _executeAction(
                  provider,
                  'ban',
                  user,
                ),
      ));
    }

    return actions;
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;

    return Material(
      color: enabled ? color : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: enabled ? Colors.white : AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.white : AppColors.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ACCORDÉON GÉNÉRIQUE
  // ============================================

  Widget _buildAccordion({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            iconColor: color,
            collapsedIconColor: AppColors.textTertiary,
            children: [child],
          ),
        ),
      ),
    );
  }

  // ============================================
  // EXÉCUTION DES ACTIONS
  // ============================================

  Future<void> _executeAction(
    AdminUserProvider provider,
    String type,
    AdminUser user,
  ) async {
    final confirmed = await _confirmAction(type, user);
    if (confirmed != true) return;
    if (!mounted) return;

    bool success = false;
    String successMessage = '';
    String errorMessage = '';

    switch (type) {
      case 'activate':
        success = await provider.activateUser(user.id);
        successMessage = 'Utilisateur activé';
        errorMessage = 'Impossible d\'activer';
        break;
      case 'deactivate':
        success = await provider.deactivateUser(user.id);
        successMessage = 'Utilisateur désactivé';
        errorMessage = 'Impossible de désactiver';
        break;
      case 'suspend':
        success = await provider.suspendUser(user.id);
        successMessage = 'Utilisateur suspendu';
        errorMessage = 'Impossible de suspendre';
        break;
      case 'unsuspend':
        success = await provider.unsuspendUser(user.id);
        successMessage = 'Suspension levée';
        errorMessage = 'Impossible de lever la suspension';
        break;
      case 'ban':
        success = await provider.banUser(user.id);
        successMessage = 'Utilisateur banni';
        errorMessage = 'Impossible de bannir';
        break;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMessage : errorMessage,
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

  Future<bool?> _confirmAction(String type, AdminUser user) async {
    String title;
    String message;
    AdminDialogType dialogType;
    String confirmLabel;

    switch (type) {
      case 'activate':
        title = 'Activer cet utilisateur ?';
        message = '${user.fullName} pourra se connecter.';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'Activer';
        break;
      case 'deactivate':
        title = 'Désactiver cet utilisateur ?';
        message = '${user.fullName} ne pourra plus se connecter.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Désactiver';
        break;
      case 'suspend':
        title = 'Suspendre cet utilisateur ?';
        message = '${user.fullName} sera suspendu pour 7 jours.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Suspendre';
        break;
      case 'unsuspend':
        title = 'Lever la suspension ?';
        message = '${user.fullName} pourra se reconnecter.';
        dialogType = AdminDialogType.confirm;
        confirmLabel = 'Lever';
        break;
      case 'ban':
        title = 'Bannir cet utilisateur ?';
        message =
            '${user.fullName} ne pourra plus accéder à son compte. Action irréversible.';
        dialogType = AdminDialogType.danger;
        confirmLabel = 'Bannir';
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
  // DIAlOG : CHANGER LE RÔLE
  // ============================================

  Future<void> _showRoleDialog(
    AdminUserProvider provider,
    AdminUser user,
  ) async {
    final role = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                  'Changer le rôle',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rôle actuel : ${user.roles.first.displayName}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRoleOption(
                  dialogContext,
                  'Client',
                  Icons.person_outline_rounded,
                  'client',
                  user.isClient,
                ),
                const SizedBox(height: 8),
                _buildRoleOption(
                  dialogContext,
                  'Vendeur',
                  Icons.storefront_outlined,
                  'seller',
                  user.isSeller,
                ),
                const SizedBox(height: 8),
                _buildRoleOption(
                  dialogContext,
                  'Admin',
                  Icons.admin_panel_settings_outlined,
                  'admin',
                  user.isAdmin,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (role == null || !mounted) return;

    // Convertir en AdminUserRole
    final newRole = AdminUserRole.fromCode(role);

    // Si c'est le même rôle → rien
    if (user.roles.contains(newRole)) return;

    // Exécuter le changement
    final success = await provider.changeUserRole(user.id, newRole);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Rôle changé en ${newRole.displayName}' : 'Impossible de changer le rôle',
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

  Widget _buildRoleOption(
    BuildContext dialogContext,
    String label,
    IconData icon,
    String role,
    bool isSelected,
  ) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(dialogContext).pop(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.primary,
                )
              else
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
  // ÉTATS ALTERNATIFS
  // ============================================

  Widget _buildErrorState(String? message) {
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
              message ?? 'Impossible de charger l\'utilisateur.',
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
              Icons.person_off_outlined,
              size: 60,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Utilisateur introuvable',
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
}