// ============================================
// WIDGET D'AVATAR DE PROFIL - VERSION PREMIUM
// ============================================
// Affiche l'avatar avec initiales, image réseau
// ou fichier local. Design ShopPro.
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 80,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: size * 0.12,
              offset: Offset(0, size * 0.04),
            ),
          ],
        ),
        child: _buildAvatarContent(),
      ),
    );
  }

  // ============================================
  // CONTENU DE L'AVATAR
  // ============================================

  Widget _buildAvatarContent() {
    // Fichier local
    if (avatarUrl != null && avatarUrl!.startsWith('file://')) {
      return ClipOval(
        child: Image.file(
          File(avatarUrl!.replaceFirst('file://', '')),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitials(),
        ),
      );
    }

    // Image réseau
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildInitials(),
          errorWidget: (context, url, error) => _buildInitials(),
        ),
      );
    }

    // Initiales par défaut
    return _buildInitials();
  }

  // ============================================
  // INITIALES
  // ============================================

  Widget _buildInitials() {
    final initials = _getInitials(name);

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }

    return '?';
  }
}