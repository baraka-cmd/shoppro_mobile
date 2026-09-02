// ============================================
// PAGE : AdminUsersScreen
// ============================================
// Écran de gestion des utilisateurs mobile.
// Avec statistiques rapides et filtres fonctionnels.
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

// Entities (même feature admin)
import '../../domain/entities/admin_user.dart';

// Providers (même feature admin)
import '../providers/admin_user_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_confirm_dialog.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de gestion des utilisateurs mobile.
///
/// Affiche :
/// - Statistiques rapides (total, admins, vendeurs, clients)
/// - Filtres par rôle en chips
/// - Cartes utilisateurs verticales
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserProvider>().loadUsers();
    });
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
      child: _buildContent(),
    );
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
              onRetry: provider.loadUsers,
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // STATISTIQUES RAPIDES (barre horizontale)
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            ),

            const SizedBox(height: 6),

            // ============================================
            // FILTRES PAR RÔLE (CHIPS FONCTIONNELS)
            // ============================================
            _buildRoleFilters(provider),

            const SizedBox(height: 6),

            // ============================================
            // LISTE DES UTILISATEURS EN CARTES
            // ============================================
            Expanded(
              child: provider.isEmpty
                  ? AdminEmptyState(
                      icon: Icons.people_outline,
                      title: 'Aucun utilisateur',
                      message: 'Les utilisateurs apparaîtront ici.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.users.length,
                      itemBuilder: (context, index) {
                        final user = provider.users[index];
                        return _buildUserCard(user, provider);
                      },
                    ),
            ),

            // ============================================
            // PAGINATION SIMPLE
            // ============================================
            if (provider.users.isNotEmpty)
              _buildPagination(provider),
          ],
        );
      },
    );
  }

  /// Statistique compacte.
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
  // FILTRES PAR RÔLE (FONCTIONNELS)
  // ============================================

  Widget _buildRoleFilters(AdminUserProvider provider) {
    final roles = [
      {'label': 'Tous', 'role': null},
      {'label': 'Admins', 'role': AdminUserRole.admin},
      {'label': 'Vendeurs', 'role': AdminUserRole.seller},
      {'label': 'Clients', 'role': AdminUserRole.client},
    ];

    return Container(
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
                // ✅ Filtrage fonctionnel
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
                    color: isSelected ? Colors.white : AppColors.textTertiary,
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

  Widget _buildUserCard(dynamic user, AdminUserProvider provider) {
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
          // LIGNE 1 : Avatar + Nom + Email
          // ============================================
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.initials ?? '?',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'Utilisateur',
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
                      user.email ?? '',
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

          // ============================================
          // LIGNE 2 : Badges en Wrap
          // ============================================
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildRoleBadge(user.roles),
              _buildStatusBadge(user),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${user.totalOrders ?? 0} cmd',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              if ((user.totalSpent ?? 0) > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    user.totalSpentFormatted ?? '',
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
  // BADGES
  // ============================================

  /// Badge de rôle.
  Widget _buildRoleBadge(dynamic roles) {
    String label = 'Client';
    Color color = AppColors.successDark;
    Color bgColor = AppColors.successLight;

    if (roles is List && roles.isNotEmpty) {
      final roleCode = roles.first.code ?? roles.first.toString();
      if (roleCode == 'admin') {
        label = 'Admin';
        color = const Color(0xFF6B21A8);
        bgColor = const Color(0xFFF3E8FF);
      } else if (roleCode == 'seller') {
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

  /// Badge de statut.
  Widget _buildStatusBadge(dynamic user) {
    Color bgColor;
    Color textColor;
    String label;

    if (user.isBanned == true) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.errorDark;
      label = 'Banni';
    } else if (user.isSuspended == true) {
      bgColor = AppColors.warningLight;
      textColor = AppColors.warningDark;
      label = 'Suspendu';
    } else if (user.isActive == false) {
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
  // PAGINATION
  // ============================================

  Widget _buildPagination(AdminUserProvider provider) {
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
            onPressed: provider.currentPage > 1 ? provider.loadUsers : null,
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
            onPressed: provider.hasMore ? provider.loadMoreUsers : null,
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  // ============================================
  // NAVIGATION ET ACTIONS
  // ============================================

  void _navigateToDetail(dynamic user) {
    Navigator.of(context).pushNamed(
      AppRoutes.adminUserDetail,
      arguments: {'user_id': user.id},
    );
  }

  Future<void> _confirmBanUser(AdminUserProvider provider, dynamic user) async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Bannir cet utilisateur ?',
      message: 'L\'utilisateur ne pourra plus accéder à son compte.',
      type: AdminDialogType.danger,
      confirmLabel: 'Bannir',
    );

    if (result == true) {
      await provider.banUser(user.id);
    }
  }
}