// ============================================
// WIDGET : AdminLoadingState
// ============================================
// État de chargement générique pour les pages admin.
// Design moderne avec skeleton shimmer.
//
// Structure :
// - Squelettes de cartes qui pulsent
// - Squelettes de lignes de tableau
// - Squelettes de texte
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

/// État de chargement pour les pages admin.
///
/// Affiche des squelettes animés qui simulent
/// le contenu en cours de chargement.
class AdminLoadingState extends StatefulWidget {
  // ============================================
  // PROPRIÉTÉS
  // ============================================

  /// Type de chargement
  final AdminLoadingType type;

  /// Nombre de squelettes à afficher
  final int itemCount;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminLoadingState({
    super.key,
    this.type = AdminLoadingType.cards,
    this.itemCount = 4,
  });

  @override
  State<AdminLoadingState> createState() => _AdminLoadingStateState();
}

// ============================================
// ENUM DE TYPE DE CHARGEMENT
// ============================================

/// Types de chargement supportés
enum AdminLoadingType {
  /// Cartes statistiques (dashboard)
  cards,

  /// Lignes de tableau (listes)
  tableRows,

  /// Liste verticale
  list,

  /// Formulaire
  form,

  /// Détail
  detail,
}

// ============================================
// STATE
// ============================================

class _AdminLoadingStateState extends State<AdminLoadingState>
    with SingleTickerProviderStateMixin {
  // ============================================
  // ANIMATION
  // ============================================

  late final AnimationController _controller;
  late final Animation<double> _animation;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final opacity = _animation.value;
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: _buildByType(),
    );
  }

  // ============================================
  // BUILD PAR TYPE
  // ============================================

  Widget _buildByType() {
    switch (widget.type) {
      case AdminLoadingType.cards:
        return _buildCardsLoading();
      case AdminLoadingType.tableRows:
        return _buildTableLoading();
      case AdminLoadingType.list:
        return _buildListLoading();
      case AdminLoadingType.form:
        return _buildFormLoading();
      case AdminLoadingType.detail:
        return _buildDetailLoading();
    }
  }

  // ============================================
  // SKELETONS
  // ============================================

  /// Squelettes de cartes statistiques.
  Widget _buildCardsLoading() {
    return Row(
      children: List.generate(
        widget.itemCount,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < widget.itemCount - 1 ? 16 : 0,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 44, height: 44, radius: 10),
                const SizedBox(height: 16),
                _skeletonBox(width: 120, height: 20),
                const SizedBox(height: 8),
                _skeletonBox(width: 80, height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Squelettes de lignes de tableau.
  Widget _buildTableLoading() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: _skeletonBox(
                    width: 60,
                    height: 12,
                    margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                  ),
                ),
              ),
            ),
          ),
          // Lignes
          ...List.generate(
            widget.itemCount,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderColor.withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                children: List.generate(
                  4,
                  (cellIndex) => Expanded(
                    child: _skeletonBox(
                      width: 80,
                      height: 14,
                      margin: EdgeInsets.only(right: cellIndex < 3 ? 16 : 0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Squelettes de liste verticale.
  Widget _buildListLoading() {
    return Column(
      children: List.generate(
        widget.itemCount,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              _skeletonBox(width: 48, height: 48, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(width: 150, height: 14),
                    const SizedBox(height: 6),
                    _skeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
              _skeletonBox(width: 60, height: 24, radius: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Squelettes de formulaire.
  Widget _buildFormLoading() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(width: 120, height: 16),
          const SizedBox(height: 8),
          _skeletonBox(width: double.infinity, height: 44),
          const SizedBox(height: 20),
          _skeletonBox(width: 120, height: 16),
          const SizedBox(height: 8),
          _skeletonBox(width: double.infinity, height: 44),
          const SizedBox(height: 20),
          _skeletonBox(width: 120, height: 16),
          const SizedBox(height: 8),
          _skeletonBox(width: double.infinity, height: 100),
          const SizedBox(height: 24),
          Row(
            children: [
              _skeletonBox(width: 100, height: 40),
              const SizedBox(width: 12),
              _skeletonBox(width: 140, height: 40),
            ],
          ),
        ],
      ),
    );
  }

  /// Squelettes de détail.
  Widget _buildDetailLoading() {
    return Column(
      children: [
        // Carte principale
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              _skeletonBox(width: 64, height: 64, radius: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(width: 200, height: 18),
                    const SizedBox(height: 8),
                    _skeletonBox(width: 150, height: 14),
                    const SizedBox(height: 8),
                    _skeletonBox(width: 100, height: 24, radius: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Carte secondaire
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _skeletonBox(width: 100, height: 14),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _skeletonBox(width: double.infinity, height: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // SKELETON BOX
  // ============================================

  /// Boîte squelette individuelle.
  Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 6,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}