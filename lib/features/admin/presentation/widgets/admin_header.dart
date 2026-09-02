// ============================================
// WIDGET : AdminHeader
// ============================================
// Header du backoffice admin.
// Design moderne avec fond blanc et ombre subtile.
//
// Structure :
// - Titre de la page à gauche
// - Barre de recherche au centre
// - Notifications et avatar à droite
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

/// Header de l'administration.
///
/// Affiche :
/// - Le titre de la page actuelle
/// - Une barre de recherche
/// - Les notifications avec badge
/// - L'avatar de l'administrateur
class AdminHeader extends StatelessWidget {
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

  /// Avatar de l'administrateur (URL ou initiales)
  final String? adminAvatar;

  /// Callback quand on clique sur les notifications
  final VoidCallback? onNotificationsTap;

  /// Callback quand on clique sur le profil
  final VoidCallback? onProfileTap;

  /// Callback pour la recherche
  final ValueChanged<String>? onSearch;

  /// Placeholder de la recherche
  final String searchPlaceholder;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.notificationCount = 0,
    this.adminName = 'Admin',
    this.adminAvatar,
    this.onNotificationsTap,
    this.onProfileTap,
    this.onSearch,
    this.searchPlaceholder = 'Rechercher...',
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ============================================
          // TITRE
          // ============================================
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ============================================
          // BARRE DE RECHERCHE
          // ============================================
          Expanded(
            flex: 2,
            child: _buildSearchBar(),
          ),

          const SizedBox(width: 16),

          // ============================================
          // NOTIFICATIONS
          // ============================================
          _buildNotificationButton(),

          const SizedBox(width: 8),

          // ============================================
          // AVATAR ADMIN
          // ============================================
          _buildAdminProfile(),
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS INTERNES
  // ============================================

  /// Construit la barre de recherche.
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        onChanged: onSearch,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: searchPlaceholder,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: Color(0xFF64748B),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  /// Construit le bouton de notifications.
  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(
            Icons.notifications_outlined,
            size: 22,
            color: Color(0xFF64748B),
          ),
          tooltip: 'Notifications',
        ),
        if (notificationCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.adminAccent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : '$notificationCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Construit le profil admin.
  Widget _buildAdminProfile() {
    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.adminSidebarBackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: adminAvatar != null && adminAvatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          adminAvatar!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitials();
                          },
                        ),
                      )
                    : _buildInitials(),
              ),
            ),
            const SizedBox(width: 8),
            // Nom
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit les initiales pour l'avatar.
  Widget _buildInitials() {
    final initials = _getInitials(adminName);
    return Text(
      initials,
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