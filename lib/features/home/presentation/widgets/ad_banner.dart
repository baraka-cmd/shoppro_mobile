// ============================================
// WIDGET : AdBanner
// ============================================
// Bannière publicitaire avec :
// - Dégradé élégant
// - Image ou icône décorative
// - Bouton d'action
// - Design responsive mobile
// ============================================

// ============================================
// IMPORTS
// ============================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class AdBanner extends StatelessWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final Color backgroundColor;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onTap;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdBanner({
    super.key,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.backgroundColor = AppColors.primary,
    this.icon = Icons.local_offer,
    this.buttonText,
    this.onTap,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundColor.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              // ============================================
              // CONTENU TEXTUEL
              // ============================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (title != null && title!.isNotEmpty)
                        Text(
                          title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                      if (buttonText != null && buttonText!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            buttonText!,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: backgroundColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ============================================
              // IMAGE OU ICÔNE
              // ============================================
              if (imageUrl != null && imageUrl!.isNotEmpty)
                SizedBox(
                  width: 100,
                  height: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: backgroundColor.withValues(alpha: 0.3),
                    ),
                    errorWidget: (context, url, error) => _buildIcon(),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _buildIcon(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ICÔNE DÉCORATIVE
  // ============================================

  Widget _buildIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: Colors.white,
      ),
    );
  }
}