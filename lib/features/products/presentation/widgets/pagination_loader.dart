// ============================================
// WIDGET DE PAGINATION - VERSION PREMIUM
// ============================================
// Gère le chargement infini, le bouton "Charger plus"
// et l'indicateur. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaginationLoader extends StatelessWidget {
  final PaginationType type;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final String? loadingMessage;
  final String? noMoreMessage;
  final String? errorMessage;

  const PaginationLoader({
    super.key,
    this.type = PaginationType.infiniteScroll,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
    this.loadingMessage = 'Chargement des produits...',
    this.noMoreMessage = 'Vous avez tout vu !',
    this.errorMessage = 'Erreur de chargement',
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case PaginationType.infiniteScroll:
        return _buildInfiniteScroll();
      case PaginationType.loadMoreButton:
        return _buildLoadMoreButton();
      case PaginationType.indicator:
        return _buildIndicator();
    }
  }

  // ============================================
  // INFINITE SCROLL
  // ============================================

  Widget _buildInfiniteScroll() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                loadingMessage!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                noMoreMessage!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ============================================
  // BOUTON CHARGER PLUS
  // ============================================

  Widget _buildLoadMoreButton() {
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            noMoreMessage!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ElevatedButton(
          onPressed: isLoading ? null : onLoadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.white,
            disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Text(
                  'CHARGER PLUS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ============================================
  // INDICATEUR
  // ============================================

  Widget _buildIndicator() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  loadingMessage!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(
            noMoreMessage!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ============================================
// ENUM
// ============================================

enum PaginationType {
  infiniteScroll,   // Spinner automatique
  loadMoreButton,   // Bouton "Charger plus"
  indicator,        // Indicateur avec texte
}