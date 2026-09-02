// ============================================
// PROVIDER : AdminReviewProvider
// ============================================
// Provider de gestion d'état pour la modération des avis.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des avis paginés
// - Modération (approuver, rejeter, spam)
// - Réponse aux avis
// - Statistiques des avis
// - Actions en masse
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_review.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_review_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_review_repository_impl.dart';
import '../../data/models/admin_review_model.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider avis
enum AdminReviewStatus2 {
  initial,
  loading,
  loaded,
  loadingMore,
  updating,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des avis administrés.
///
/// Gère :
/// - La liste paginée des avis
/// - La modération des avis
/// - Les réponses admin
/// - Les statistiques
class AdminReviewProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminReviewRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminReviewStatus2 _status = AdminReviewStatus2.initial;
  List<AdminReview> _reviews = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;

  // Filtres
  AdminReviewStatus? _filterStatus;
  int? _filterRating;
  int? _filterProductId;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  Map<String, int> _statusCounts = {};
  Map<int, int> _ratingCounts = {};
  double _averageRating = 0;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminReviewProvider({AdminReviewRepository? repository})
      : _repository = repository ?? AdminReviewRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminReviewStatus2 get status => _status;
  List<AdminReview> get reviews => List.unmodifiable(_reviews);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == AdminReviewStatus2.loading;
  bool get isLoaded => _status == AdminReviewStatus2.loaded;
  bool get isLoadingMore => _status == AdminReviewStatus2.loadingMore;
  bool get isUpdating => _status == AdminReviewStatus2.updating;
  bool get hasError => _status == AdminReviewStatus2.error;
  int get reviewsCount => _reviews.length;
  bool get isEmpty => _reviews.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);
  Map<String, int> get statusCounts => Map.unmodifiable(_statusCounts);
  Map<int, int> get ratingCounts => Map.unmodifiable(_ratingCounts);
  double get averageRating => _averageRating;
  AdminReviewStatus? get filterStatus => _filterStatus;

  /// Avis en attente de modération
  List<AdminReview> get pendingReviews =>
      _reviews.where((r) => r.isPending).toList();

  /// Avis approuvés
  List<AdminReview> get approvedReviews =>
      _reviews.where((r) => r.isApproved).toList();

  /// Avis rejetés
  List<AdminReview> get rejectedReviews =>
      _reviews.where((r) => r.isRejected).toList();

  /// Avis spam
  List<AdminReview> get spamReviews =>
      _reviews.where((r) => r.isSpam).toList();

  /// Nombre d'avis en attente
  int get pendingCount => pendingReviews.length;

  /// Nombre d'avis approuvés
  int get approvedCount => approvedReviews.length;

  /// Avis avec réponse admin
  List<AdminReview> get respondedReviews =>
      _reviews.where((r) => r.hasAdminResponse).toList();

  /// Avis vérifiés (achat vérifié)
  List<AdminReview> get verifiedReviews =>
      _reviews.where((r) => r.isVerifiedPurchase).toList();

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge la première page des avis.
  Future<void> loadReviews() async {
  _status = AdminReviewStatus2.loading;
  _errorMessage = null;
  _currentPage = 1;
  notifyListeners();

  try {
    final reviews = await _repository.getReviews(
      page: _currentPage,
      perPage: _perPage,
      status: _filterStatus,
      rating: _filterRating,
      productId: _filterProductId,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );

    // ✅ CONVERSION : Si reviews est List<AdminReviewModel>, convertir
    _reviews = reviews.map((review) {
      if (review is AdminReviewModel) {
        return AdminReview(
          id: review.id,
          title: review.title,
          content: review.content,
          createdAt: review.createdAt,
          updatedAt: review.updatedAt,
          rating: review.rating,
          qualityRating: review.qualityRating,
          priceRating: review.priceRating,
          shippingRating: review.shippingRating,
          averageRating: review.averageRating,
          userId: review.userId,
          userName: review.userName,
          userAvatar: review.userAvatar,
          productId: review.productId,
          productName: review.productName,
          productImage: review.productImage,
          orderId: review.orderId,
          orderNumber: review.orderNumber,
          isVerifiedPurchase: review.isVerifiedPurchase,
          status: review.status,
          adminResponse: review.adminResponse,
          adminResponseAt: review.adminResponseAt,
          approvedAt: review.approvedAt,
          isRecommended: review.isRecommended,
          helpfulCount: review.helpfulCount,
          notHelpfulCount: review.notHelpfulCount,
          viewsCount: review.viewsCount,
          imagesCount: review.imagesCount,
        );
      }
      return review;
    }).toList();

    _hasMore = reviews.length >= _perPage;
    _status = AdminReviewStatus2.loaded;
    await _loadStatistics();
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminReviewStatus2.error;
    debugPrint('Erreur loadReviews: $e');
  }

  notifyListeners();
}

  /// Charge la page suivante.
  Future<void> loadMoreReviews() async {
    if (_status == AdminReviewStatus2.loadingMore || !_hasMore) return;

    _status = AdminReviewStatus2.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final reviews = await _repository.getReviews(
        page: nextPage,
        perPage: _perPage,
        status: _filterStatus,
        rating: _filterRating,
        productId: _filterProductId,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      if (reviews.isEmpty) {
        _hasMore = false;
      } else {
        _reviews = [..._reviews, ...reviews];
        _currentPage = nextPage;
        _hasMore = reviews.length >= _perPage;
      }

      _status = AdminReviewStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminReviewStatus2.error;
      debugPrint('Erreur loadMoreReviews: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit sans loader.
  Future<void> refreshReviews() async {
    try {
      final reviews = await _repository.getReviews(
        page: 1,
        perPage: _perPage,
        status: _filterStatus,
        rating: _filterRating,
        productId: _filterProductId,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _reviews = reviews;
      _currentPage = 1;
      _hasMore = reviews.length >= _perPage;
      _status = AdminReviewStatus2.loaded;
      await _loadStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshReviews: $e');
    }

    notifyListeners();
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Filtre par statut.
  Future<void> filterByStatus(AdminReviewStatus? status) async {
    _filterStatus = status;
    await loadReviews();
  }

  /// Filtre par note.
  Future<void> filterByRating(int? rating) async {
    _filterRating = rating;
    await loadReviews();
  }

  /// Filtre par produit.
  Future<void> filterByProduct(int? productId) async {
    _filterProductId = productId;
    await loadReviews();
  }

  /// Trie les résultats.
  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadReviews();
  }

  /// Efface les filtres.
  Future<void> clearFilters() async {
    _filterStatus = null;
    _filterRating = null;
    _filterProductId = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    await loadReviews();
  }

  // ============================================
  // MODÉRATION
  // ============================================

  /// Approuve un avis.
  Future<bool> approveReview(int id) async {
    _status = AdminReviewStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.approveReview(id);
      if (success) {
        _updateReviewStatus(id, AdminReviewStatus.approved);
      }
      _status = AdminReviewStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminReviewStatus2.error;
      debugPrint('Erreur approveReview: $e');
      notifyListeners();
      return false;
    }
  }

  /// Rejette un avis.
  Future<bool> rejectReview(int id, {String? reason}) async {
    _status = AdminReviewStatus2.updating;
    notifyListeners();

    try {
      final success = await _repository.rejectReview(id, reason: reason);
      if (success) {
        _updateReviewStatus(id, AdminReviewStatus.rejected);
      }
      _status = AdminReviewStatus2.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminReviewStatus2.error;
      debugPrint('Erreur rejectReview: $e');
      notifyListeners();
      return false;
    }
  }

  /// Marque un avis comme spam.
  Future<bool> markAsSpam(int id) async {
    try {
      final success = await _repository.markReviewAsSpam(id);
      if (success) {
        _updateReviewStatus(id, AdminReviewStatus.spam);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remet un avis en attente.
  Future<bool> resetToPending(int id) async {
    try {
      final success = await _repository.resetReviewStatus(id);
      if (success) {
        _updateReviewStatus(id, AdminReviewStatus.pending);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RÉPONSE ADMIN
  // ============================================

  /// Répond à un avis.
  Future<bool> respondToReview(int reviewId, String response) async {
    try {
      final success = await _repository.respondToReview(reviewId, response);
      if (success) {
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          _reviews[index] = _reviews[index].copyWith(
            adminResponse: response,
            adminResponseAt: DateTime.now(),
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Supprime la réponse admin.
  Future<bool> deleteAdminResponse(int reviewId) async {
    try {
      final success = await _repository.deleteAdminResponse(reviewId);
      if (success) {
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          _reviews[index] = _reviews[index].copyWith(
            adminResponse: null,
            adminResponseAt: null,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RECOMMANDATION
  // ============================================

  /// Toggle la recommandation d'un avis.
  Future<bool> toggleRecommended(int id) async {
    final review = _reviews.firstWhere((r) => r.id == id,
        orElse: () => throw Exception('Avis introuvable'));

    try {
      final success = review.isRecommended
          ? await _repository.unmarkAsRecommended(id)
          : await _repository.markAsRecommended(id);

      if (success) {
        final index = _reviews.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reviews[index] = _reviews[index].copyWith(
            isRecommended: !review.isRecommended,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprime un avis.
  Future<bool> deleteReview(int id) async {
    try {
      final success = await _repository.deleteReview(id);
      if (success) {
        _reviews.removeWhere((r) => r.id == id);
        _selectedIds.remove(id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Toggle la sélection.
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Sélectionne tout.
  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_reviews.map((r) => r.id));
    notifyListeners();
  }

  /// Efface la sélection.
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Vérifie la sélection.
  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Approuve les avis sélectionnés.
  Future<int> bulkApproveSelected() async {
    final count = await _repository.bulkApproveReviews(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  /// Rejette les avis sélectionnés.
  Future<int> bulkRejectSelected() async {
    final count = await _repository.bulkRejectReviews(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  /// Supprime les avis sélectionnés.
  Future<int> bulkDeleteSelected() async {
    final count = await _repository.bulkDeleteReviews(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  /// Marque comme spam les avis sélectionnés.
  Future<int> bulkMarkSpamSelected() async {
    final count = await _repository.bulkMarkAsSpam(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Met à jour le statut d'un avis dans la liste.
  void _updateReviewStatus(int id, AdminReviewStatus status) {
    final index = _reviews.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(
        status: status,
        approvedAt: status == AdminReviewStatus.approved ? DateTime.now() : null,
      );
      notifyListeners();
    }
  }

  /// Charge les statistiques des avis.
  Future<void> _loadStatistics() async {
    try {
      _statusCounts = await _repository.getReviewsCountByStatus();
      _ratingCounts = await _repository.getReviewsCountByRating();
      _averageRating = await _repository.getAverageRating();
    } catch (e) {
      debugPrint('Erreur _loadStatistics: $e');
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminReviewStatus2.initial;
    _reviews = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filterStatus = null;
    _filterRating = null;
    _filterProductId = null;
    _selectedIds.clear();
    _statusCounts = {};
    _ratingCounts = {};
    _averageRating = 0;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminReviewProvider(status: $_status, reviews: ${_reviews.length}, '
        'pending: $pendingCount, approved: $approvedCount, avg: ${_averageRating.toStringAsFixed(1)})';
  }
}