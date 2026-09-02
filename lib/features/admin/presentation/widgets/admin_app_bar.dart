// ============================================
// WIDGET : AdminAppBar
// ============================================
// Barre supérieure du backoffice admin mobile.
// Design moderne avec hamburger, titre et actions.
//
// Structure :
// - Bouton hamburger (ouvre le Drawer)
// - Titre de la page
// - Notifications avec badge
// - Avatar admin
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

/// Barre supérieure de l'administration mobile.
///
/// Affiche :
/// - Le bouton hamburger pour ouvrir le menu
/// - Le titre de la page actuelle
/// - Les notifications avec badge
/// - L'avatar de l'administrateur
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Titre de la page
  final String title;

  /// Sous-titre optionnel
  final String? subtitle;

  /// Nombre de notifications non lues
  final int notificationCount;

  /// Nom de l'administrateur
  final String adminName;

  /// Avatar de l'administrateur
  final String? adminAvatar;

  /// Callback pour ouvrir le drawer
  final VoidCallback? onMenuTap;

  /// Callback pour les notifications
  final VoidCallback? onNotificationsTap;

  /// Callback pour le profil
  final VoidCallback? onProfileTap;

  /// Actions supplémentaires
  final List<Widget>? actions;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.notificationCount = 0,
    this.adminName = 'Admin',
    this.adminAvatar,
    this.onMenuTap,
    this.onNotificationsTap,
    this.onProfileTap,
    this.actions,
  });

  // ============================================
  // TAILLE
  // ============================================

  @override
  Size get preferredSize => const Size.fromHeight(60);

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ============================================
          // BOUTON HAMBURGER
          // ============================================
          IconButton(
            onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.menu,
              size: 24,
              color: Colors.white,
            ),
            tooltip: 'Menu',
          ),

          const SizedBox(width: 4),

          // ============================================
          // TITRE
          // ============================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFB0C4DE),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ============================================
          // ACTIONS SUPPLÉMENTAIRES
          // ============================================
          if (actions != null) ...actions!,

          // ============================================
          // NOTIFICATIONS
          // ============================================
          _buildNotificationButton(),

          const SizedBox(width: 4),

          // ============================================
          // AVATAR ADMIN
          // ============================================
          _buildAdminProfile(),
        ],
      ),
    );
  }

  // ============================================
  // BOUTON NOTIFICATIONS
  // ============================================

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(
            Icons.notifications_outlined,
            size: 22,
            color: Colors.white,
          ),
          tooltip: 'Notifications',
        ),
        if (notificationCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : '$notificationCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // PROFIL ADMIN
  // ============================================

  Widget _buildAdminProfile() {
    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: adminAvatar != null && adminAvatar!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    adminAvatar!,
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitials();
                    },
                  ),
                )
              : _buildInitials(),
        ),
      ),
    );
  }

  /// Construit les initiales pour l'avatar.
  Widget _buildInitials() {
    return Text(
      _getInitials(adminName),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  /// Extrait les initiales du nom.
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }
}