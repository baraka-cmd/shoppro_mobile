// ============================================
// ÉCRAN : TOUS LES AVIS D'UN PRODUIT
// ============================================
// Affiche la liste complète des avis avec :
// - Résumé (note moyenne + distribution)
// - Filtres (Tous, par note, avec photos, vérifiés)
// - Tri (Récents, Utiles, Note)
// - Pagination infinie
// - Pull-to-refresh
// - États : chargement, vide, erreur
// Design conforme à la vision ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/product_provider.dart';
import '../widgets/review_card.dart';
import '../widgets/reviews_section.dart'; 
import '../widgets/review_filter_bar.dart';

class AllReviewsScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final double averageRating;
  final int totalReviews;

  const AllReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  // ============================================
  // ÉTAT
  // ============================================

  final ScrollController _scrollController = ScrollController();

  /// Filtre actif : null = Tous
  int? _selectedRating;

  /// Filtre : avis avec photos uniquement
  bool _withPhotosOnly = false;

  /// Filtre : achats vérifiés uniquement
  bool _verifiedOnly = false;

  /// Tri : 'recent' | 'helpful' | 'rating_desc' | 'rating_asc'
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadReviews() async {
    final provider = context.read<ProductProvider>();
    await provider.loadAllReviews(widget.productId);
  }

  Future<void> _refresh() async {
    await _loadReviews();
  }

  // ============================================
  // SCROLL INFINI
  // ============================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - 300;

    if (currentScroll >= threshold) {
      final provider = context.read<ProductProvider>();
      if (provider.hasMoreReviews && !provider.isLoadingMoreReviews) {
        provider.loadMoreReviews(widget.productId);
      }
    }
  }

  void _onFilterSelected(String filterId) {
  setState(() {
    // Reset tous les filtres
    _selectedRating = null;
    _withPhotosOnly = false;
    _verifiedOnly = false;

    // Appliquer le filtre sélectionné
    if (filterId.startsWith('rating_')) {
      _selectedRating = int.tryParse(filterId.split('_')[1]);
    } else if (filterId == 'with_photos') {
      _withPhotosOnly = true;
    } else if (filterId == 'verified') {
      _verifiedOnly = true;
    }
  });
}

  // ============================================
  // CONVERSION DES AVIS
  // ============================================

  List<ReviewCardData> _convertReviews(List<dynamic> raw) {
    final result = <ReviewCardData>[];

    for (final item in raw) {
      if (item is! Map) continue;

      try {
        final map = Map<String, dynamic>.from(item);

        // Utilisateur
        String userName = 'Utilisateur';
        String? userAvatar;

        if (map['user'] is Map) {
          final user = map['user'] as Map;
          userName = user['name']?.toString() ?? 'Utilisateur';
          userAvatar = user['avatar']?.toString();
        } else if (map['user_name'] != null) {
          userName = map['user_name'].toString();
        }

        // Images
        final images = <String>[];
        if (map['images'] is List) {
          for (final img in map['images']) {
            if (img is String) {
              images.add(img);
            } else if (img is Map && img['url'] != null) {
              images.add(img['url'].toString());
            } else if (img is Map && img['image_path'] != null) {
              images.add(img['image_path'].toString());
            }
          }
        }

        result.add(
          ReviewCardData(
            userName: userName,
            userAvatar: userAvatar,
            rating: _parseDouble(map['rating']),
            comment: map['comment']?.toString() ?? '',
            title: map['title']?.toString(),
            date: _parseDate(map['created_at']),
            isVerifiedPurchase: map['is_verified_purchase'] == true,
            helpfulCount: _parseInt(map['helpful_count']),
            notHelpfulCount: _parseInt(map['not_helpful_count']),
            images: images.isEmpty ? null : images,
          ),
        );
      } catch (e) {
        debugPrint('⚠️ Erreur conversion avis: $e');
      }
    }

    return result;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ============================================
  // APPLICATION DES FILTRES + TRI
  // ============================================

  List<ReviewCardData> _applyFiltersAndSort(List<ReviewCardData> input) {
    var result = [...input];

    // Filtre par note
    if (_selectedRating != null) {
      result = result.where((r) {
        return r.rating.round() == _selectedRating;
      }).toList();
    }

    // Filtre : avec photos
    if (_withPhotosOnly) {
      result = result.where((r) {
        return r.images != null && r.images!.isNotEmpty;
      }).toList();
    }

    // Filtre : achats vérifiés
    if (_verifiedOnly) {
      result = result.where((r) => r.isVerifiedPurchase).toList();
    }

    // Tri
    switch (_sortBy) {
      case 'helpful':
        result.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
      case 'rating_desc':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'rating_asc':
        result.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'recent':
      default:
        result.sort((a, b) {
          final da = a.date ?? DateTime(2000);
          final db = b.date ?? DateTime(2000);
          return db.compareTo(da);
        });
        break;
    }

    return result;
  }

  // ============================================
  // DISTRIBUTION DES NOTES
  // ============================================

  Map<int, int> _buildDistribution(List<ReviewCardData> reviews) {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final r in reviews) {
      final rounded = r.rating.round().clamp(1, 5);
      dist[rounded] = (dist[rounded] ?? 0) + 1;
    }

    return dist;
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingReviews && provider.allProductReviews.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.allProductReviews.isEmpty) {
            return _buildEmptyState();
          }

          final allReviews = _convertReviews(provider.allProductReviews);
          final distribution = _buildDistribution(allReviews);
          final filtered = _applyFiltersAndSort(allReviews);

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Résumé (note moyenne + distribution)
                SliverToBoxAdapter(
                  child: _buildFilterChips(distribution, allReviews),
                ),

                // Barre de filtres (chips)
                SliverToBoxAdapter(
                  child: _buildFilterChips(distribution, allReviews),
                ),

                // Barre de tri
                SliverToBoxAdapter(
                  child: _buildSortBar(filtered.length),
                ),

                // Liste des avis
                if (filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildNoMatchState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          child: ReviewCard(
                            userName: filtered[index].userName,
                            userAvatar: filtered[index].userAvatar,
                            rating: filtered[index].rating,
                            title: filtered[index].title,
                            comment: filtered[index].comment,
                            date: filtered[index].date,
                            isVerifiedPurchase:
                                filtered[index].isVerifiedPurchase,
                            helpfulCount: filtered[index].helpfulCount,
                            notHelpfulCount:
                                filtered[index].notHelpfulCount,
                            images: filtered[index].images,
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),

                // Loader de pagination
                if (provider.isLoadingMoreReviews)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),

                // Message "fin"
                if (!provider.hasMoreReviews && filtered.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(
                          'Vous avez vu tous les avis',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(
          Icons.arrow_back_ios,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tous les avis',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (widget.productName.isNotEmpty)
            Text(
              widget.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================
  // RÉSUMÉ (NOTE + DISTRIBUTION)
  // ============================================

  Widget _buildSummaryCard(Map<int, int> distribution) {
    final total = widget.totalReviews > 0 ? widget.totalReviews : 1;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Note moyenne
          Column(
            children: [
              Text(
                widget.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              Text(
                '${widget.totalReviews} avis',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isFilled = index < widget.averageRating.round();
                  return Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: 15,
                    color: isFilled
                        ? AppColors.ratingColor
                        : AppColors.textLight,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(width: 20),

          // Distribution
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = distribution[star] ?? 0;
                final percentage =
                    (count / total * 100).clamp(0.0, 100.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.star,
                        size: 10,
                        color: AppColors.ratingColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.surface,
                            color: AppColors.ratingColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTRES (CHIPS)
  // ============================================

  Widget _buildFilterChips(Map<int, int> distribution, List<ReviewCardData> allReviews) {
  // Calculer les compteurs
  final withPhotosCount = allReviews
      .where((r) => r.images != null && r.images!.isNotEmpty)
      .length;
  final verifiedCount = allReviews
      .where((r) => r.isVerifiedPurchase)
      .length;

  // Construire les filtres
  final filters = ReviewFilterFactory.standard(
    totalCount: allReviews.length,
    distribution: distribution,
    withPhotosCount: withPhotosCount,
    verifiedCount: verifiedCount,
  );

  // Déterminer l'ID sélectionné
  String selectedId = 'all';
  if (_selectedRating != null) {
    selectedId = 'rating_$_selectedRating';
  } else if (_withPhotosOnly) {
    selectedId = 'with_photos';
  } else if (_verifiedOnly) {
    selectedId = 'verified';
  }

  return ReviewFilterBar(
    filters: filters,
    selectedFilterId: selectedId,
    onFilterSelected: _onFilterSelected,
  );
}


  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BARRE DE TRI
  // ============================================

  Widget _buildSortBar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
      child: Row(
        children: [
          Text(
            '$count avis',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _sortLabel(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel() {
    switch (_sortBy) {
      case 'helpful':
        return 'Plus utiles';
      case 'rating_desc':
        return 'Meilleures notes';
      case 'rating_asc':
        return 'Notes faibles';
      case 'recent':
      default:
        return 'Plus récents';
    }
  }

  // ============================================
  // BOTTOM SHEET DE TRI
  // ============================================

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Poignée
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Trier les avis',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                _buildSortOption('recent', 'Plus récents', Icons.schedule),
                _buildSortOption('helpful', 'Plus utiles', Icons.thumb_up),
                _buildSortOption(
                  'rating_desc',
                  'Meilleures notes',
                  Icons.trending_up,
                ),
                _buildSortOption(
                  'rating_asc',
                  'Notes faibles',
                  Icons.trending_down,
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;

    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
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
                Icons.check,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ÉTATS
  // ============================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 60,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 15),
          const Text(
            'Aucun avis pour le moment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Soyez le premier à partager votre expérience',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off,
              size: 50,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucun avis ne correspond à vos filtres',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedRating = null;
                  _withPhotosOnly = false;
                  _verifiedOnly = false;
                });
              },
              child: const Text(
                'Réinitialiser les filtres',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}