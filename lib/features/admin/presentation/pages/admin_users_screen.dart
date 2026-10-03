// ============================================
// PAGE : AdminUsersScreen (MOBILE SENIOR)
// ============================================
// Écran de gestion des utilisateurs.
// - Statistiques rapides
// - Filtres par rôle
// - Cartes utilisateurs verticales
// - FAB pour créer un utilisateur
// - Pull-to-refresh
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Entities
import '../../domain/entities/admin_user.dart';

// Providers
import '../providers/admin_user_provider.dart';

// Widgets
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    await context.read<AdminUserProvider>().loadUsers();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Utilisateurs',
      subtitle: 'Gérez vos utilisateurs',
      currentRoute: AppRoutes.adminUsers,
      onNavigate: (route) {
        if (route.isNotEmpty) {
          Navigator.of(context).pushNamed(route);
        }
      },
      onNotificationsTap: () {
        Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
      },
      onLogout: () {},
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildContent(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  // ============================================
  // FAB — AJOUTER UN UTILISATEUR
  // ============================================

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreate,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.person_add_alt_1, size: 20),
      label: const Text(
        'Ajouter',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _navigateToCreate() async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.adminUserCreate,
    );

    // Rafraîchir la liste si création réussie
    if (result == true && mounted) {
      await _loadUsers();
    }
  }

  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminUserProvider>(
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
              onRetry: _loadUsers,
            ),
          );
        }

        return Column(
          children: [
            // Stats rapides
            _buildCompactStats(provider),

            const SizedBox(height: 6),

            // Filtres par rôle
            _buildRoleFilters(provider),

            const SizedBox(height: 6),

            // Liste des utilisateurs
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.people_outline,
                      title: 'Aucun utilisateur',
                      message: 'Cliquez sur "Ajouter" pour créer le premier.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.users.length +
                            (provider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loader en bas si hasMore
                          if (index == provider.users.length) {
                            return _buildLoadMoreIndicator(provider);
                          }
                          final user = provider.users[index];
                          return _buildUserCard(user, provider);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // STATS RAPIDES
  // ============================================

  Widget _buildCompactStats(AdminUserProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          _buildCompactStat(
            label: 'Total',
            value: provider.usersCount,
            color: AppColors.info,
          ),
          _buildCompactStat(
            label: 'Admins',
            value: provider.users.where((u) => u.isAdmin).length,
            color: const Color(0xFF8B5CF6),
          ),
          _buildCompactStat(
            label: 'Vendeurs',
            value: provider.users.where((u) => u.isSeller).length,
            color: AppColors.warning,
          ),
          _buildCompactStat(
            label: 'Clients',
            value: provider.users.where((u) => u.isClient).length,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

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
  // FILTRES PAR RÔLE
  // ============================================

  Widget _buildRoleFilters(AdminUserProvider provider) {
    final roles = [
      {'label': 'Tous', 'role': null},
      {'label': 'Admins', 'role': AdminUserRole.admin},
      {'label': 'Vendeurs', 'role': AdminUserRole.seller},
      {'label': 'Clients', 'role': AdminUserRole.client},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: roles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final role = roles[index];
          final roleValue = role['role'] as AdminUserRole?;
          final isSelected = provider.filterRole == roleValue;

          return Material(
            color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                if (roleValue == null) {
                  provider.clearFilters();
                } else {
                  provider.filterByRole(roleValue);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  role['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textTertiary,
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
  // CARTE UTILISATEUR
  // ============================================

  Widget _buildUserCard(AdminUser user, AdminUserProvider provider) {
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
          // LIGNE 1 : Avatar + Nom + Email
          Row(
            children: [
              _buildAvatar(user),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
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
                      user.email,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
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

          const SizedBox(height: 10),

          // LIGNE 2 : Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildRoleBadge(user.roles),
              _buildStatusBadge(user),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${user.totalOrders} cmd',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              if (user.totalSpent > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    user.totalSpentFormatted,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.infoDark,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 8),

          // LIGNE 3 : Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                label: 'Voir',
                icon: Icons.visibility_outlined,
                color: AppColors.info,
                onTap: () => _navigateToDetail(user),
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                label: 'Bannir',
                icon: Icons.block,
                color: AppColors.error,
                onTap: () => _confirmBanUser(provider, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // AVATAR (avec support URL)
  // ============================================

  Widget _buildAvatar(AdminUser user) {
    final hasAvatar = user.avatar != null && user.avatar!.isNotEmpty;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================================
  // BOUTON D'ACTION
  // ============================================

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
  // BADGES
  // ============================================

  Widget _buildRoleBadge(List<AdminUserRole> roles) {
    String label = 'Client';
    Color color = AppColors.successDark;
    Color bgColor = AppColors.successLight;

    if (roles.isNotEmpty) {
      final role = roles.first;
      if (role == AdminUserRole.admin) {
        label = 'Admin';
        color = const Color(0xFF6B21A8);
        bgColor = const Color(0xFFF3E8FF);
      } else if (role == AdminUserRole.seller) {
        label = 'Vendeur';
        color = AppColors.warningDark;
        bgColor = AppColors.warningLight;
      }
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

  Widget _buildStatusBadge(AdminUser user) {
    Color bgColor;
    Color textColor;
    String label;

    if (user.isBanned) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Banni';
    } else if (user.isSuspended) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'Suspendu';
    } else if (!user.isActive) {
      bgColor = AppColors.statusInactiveBg;
      textColor = AppColors.statusInactiveText;
      label = 'Inactif';
    } else {
      bgColor = AppColors.successLight;
      textColor = AppColors.successDark;
      label = 'Actif';
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
          color: textColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ============================================
  // LOAD MORE INDICATOR
  // ============================================

  Widget _buildLoadMoreIndicator(AdminUserProvider provider) {
    // Déclencher le chargement si pas déjà en cours
    if (!provider.isLoadingMore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadMoreUsers();
      });
    }

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

  // ============================================
  // NAVIGATION ET ACTIONS
  // ============================================

  void _navigateToDetail(AdminUser user) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminUserDetail,
      arguments: {'user_id': user.id},
    );
  }

  Future<void> _confirmBanUser(
    AdminUserProvider provider,
    AdminUser user,
  ) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Bannir cet utilisateur ?',
      message:
          'L\'utilisateur "${user.fullName}" ne pourra plus accéder à son compte.',
      type: AdminDialogType.danger,
      confirmLabel: 'Bannir',
    );

    if (result == true && mounted) {
      final success = await provider.banUser(user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Utilisateur banni avec succès'
                : 'Impossible de bannir l\'utilisateur',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor:
              success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}