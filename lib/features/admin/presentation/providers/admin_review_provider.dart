// ============================================
// PROVIDER : AdminReviewProvider (COMPLET)
// ============================================
// Provider de gestion d'état pour la modération des avis.
// - Liste paginée + filtres
// - Regroupement par produit
// - Filtre avec photos
// - Statistiques par produit
// - Détail d'un avis
// - Modération
// ============================================

import 'package:flutter/material.dart';

// Entities
import '../../domain/entities/admin_review.dart';

// Repositories
import '../../domain/repositories/admin_review_repository.dart';

// Repositories Impl
import '../../data/repositories/admin_review_repository_impl.dart';
import '../../data/models/admin_review_model.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

enum AdminReviewStatus2 {
  initial,
  loading,
  loaded,
  loadingMore,
  updating,
  error,
}

// ============================================
// PROVIDER
// ============================================

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

  // Regroupement par produit
  bool _isGroupedByProduct = false;
  List<Map<String, dynamic>> _groupedByProduct = [];
  List<Map<String, dynamic>> _statsByProduct = [];

  // Filtres
  AdminReviewStatus? _filterStatus;
  int? _filterRating;
  int? _filterProductId;
  bool _filterWithPhotos = false;
  bool _filterVerified = false;
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
  // GETTERS — ÉTAT
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

  // ============================================
  // GETTERS — SÉLECTION
  // ============================================

  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);

  // ============================================
  // GETTERS — STATISTIQUES
  // ============================================

  Map<String, int> get statusCounts => Map.unmodifiable(_statusCounts);
  Map<int, int> get ratingCounts => Map.unmodifiable(_ratingCounts);
  double get averageRating => _averageRating;

  // ============================================
  // GETTERS — FILTRES
  // ============================================

  AdminReviewStatus? get filterStatus => _filterStatus;
  int? get filterRating => _filterRating;
  int? get filterProductId => _filterProductId;
  bool get filterWithPhotos => _filterWithPhotos;
  bool get filterVerified => _filterVerified;

  // ============================================
  // GETTERS — REGROUPEMENT
  // ============================================

  bool get isGroupedByProduct => _isGroupedByProduct;
  List<Map<String, dynamic>> get groupedByProduct =>
      List.unmodifiable(_groupedByProduct);
  List<Map<String, dynamic>> get statsByProduct =>
      List.unmodifiable(_statsByProduct);
  bool get hasGroups => _groupedByProduct.isNotEmpty;
  int get groupsCount => _groupedByProduct.length;

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  List<AdminReview> get pendingReviews =>
      _reviews.where((r) => r.isPending).toList();
  List<AdminReview> get approvedReviews =>
      _reviews.where((r) => r.isApproved).toList();
  List<AdminReview> get rejectedReviews =>
      _reviews.where((r) => r.isRejected).toList();
  List<AdminReview> get spamReviews =>
      _reviews.where((r) => r.isSpam).toList();
  List<AdminReview> get withPhotosReviews =>
      _reviews.where((r) => r.hasImages).toList();
  List<AdminReview> get verifiedReviews =>
      _reviews.where((r) => r.isVerifiedPurchase).toList();
  List<AdminReview> get respondedReviews =>
      _reviews.where((r) => r.hasAdminResponse).toList();

  int get pendingCount => pendingReviews.length;
  int get approvedCount => approvedReviews.length;
  int get rejectedCount => rejectedReviews.length;
  int get spamCount => spamReviews.length;
  int get withPhotosCount => withPhotosReviews.length;
  int get verifiedCount => verifiedReviews.length;

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> loadReviews() async {
    _status = AdminReviewStatus2.loading;
    _errorMessage = null;
    _currentPage = 1;
    _isGroupedByProduct = false;
    notifyListeners();

    try {
      final reviews = await _repository.getReviews(
        page: _currentPage,
        perPage: _perPage,
        status: _filterStatus,
        rating: _filterRating,
        productId: _filterProductId,
        withPhotos: _filterWithPhotos ? true : null,
        verified: _filterVerified ? true : null,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _reviews = reviews.map(_normalizeReview).toList();
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
        withPhotos: _filterWithPhotos ? true : null,
        verified: _filterVerified ? true : null,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      if (reviews.isEmpty) {
        _hasMore = false;
      } else {
        _reviews = [..._reviews, ...reviews.map(_normalizeReview)];
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

  Future<void> refreshReviews() async {
    try {
      final reviews = await _repository.getReviews(
        page: 1,
        perPage: _perPage,
        status: _filterStatus,
        rating: _filterRating,
        productId: _filterProductId,
        withPhotos: _filterWithPhotos ? true : null,
        verified: _filterVerified ? true : null,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _reviews = reviews.map(_normalizeReview).toList();
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
  // DÉTAIL D'UN AVIS
  // ============================================

  /// Récupère les détails d'un avis par son ID.
  /// - Cherche d'abord dans la liste locale
  /// - Sinon, appelle l'API
  /// - Ajoute au cache local si trouvé
  Future<AdminReview?> getReviewById(int id) async {
    try {
      // 1. Chercher dans la liste locale
      for (final review in _reviews) {
        if (review.id == id) {
          return review;
        }
      }

      // 2. Charger depuis l'API
      final review = await _repository.getReviewById(id);

      if (review != null) {
        final normalized = _normalizeReview(review);
        if (!_reviews.any((r) => r.id == normalized.id)) {
          _reviews = [normalized, ..._reviews];
        }
        return normalized;
      }

      return null;
    } catch (e) {
      debugPrint('Erreur getReviewById: $e');
      return null;
    }
  }

  // ============================================
  // REGROUPEMENT PAR PRODUIT
  // ============================================

  Future<void> loadReviewsGroupedByProduct() async {
    _status = AdminReviewStatus2.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _groupedByProduct = await _repository.getReviewsGroupedByProduct();
      _isGroupedByProduct = true;
      _status = AdminReviewStatus2.loaded;
      debugPrint('✅ ${_groupedByProduct.length} produits groupés');
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminReviewStatus2.error;
      debugPrint('Erreur loadReviewsGroupedByProduct: $e');
    }

    notifyListeners();
  }

  Future<void> loadStatsByProduct() async {
    try {
      _statsByProduct = await _repository.getStatsByProduct();
      debugPrint('✅ ${_statsByProduct.length} stats produits chargées');
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur loadStatsByProduct: $e');
    }
  }

  Future<void> toggleGroupedByProduct() async {
    if (_isGroupedByProduct) {
      _isGroupedByProduct = false;
      _groupedByProduct = [];
      await loadReviews();
    } else {
      await loadReviewsGroupedByProduct();
    }
  }

  Future<void> showReviewsOfProduct(int productId) async {
    _filterProductId = productId;
    _isGroupedByProduct = false;
    await loadReviews();
  }

  // ============================================
  // FILTRES
  // ============================================

  Future<void> filterByStatus(AdminReviewStatus? status) async {
    _filterStatus = status;
    await loadReviews();
  }

  Future<void> filterByRating(int? rating) async {
    _filterRating = rating;
    await loadReviews();
  }

  Future<void> filterByProduct(int? productId) async {
    _filterProductId = productId;
    await loadReviews();
  }

  /// Active/désactive le filtre "avec photos".
  Future<void> filterByPhotos(bool enabled) async {
    _filterWithPhotos = enabled;
    await loadReviews();
  }

  /// Active/désactive le filtre "vérifiés".
  Future<void> filterByVerified(bool enabled) async {
    _filterVerified = enabled;
    await loadReviews();
  }

  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadReviews();
  }

  Future<void> clearFilters() async {
    _filterStatus = null;
    _filterRating = null;
    _filterProductId = null;
    _filterWithPhotos = false;
    _filterVerified = false;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    await loadReviews();
  }

  // ============================================
  // MODÉRATION
  // ============================================

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
      notifyListeners();
      return false;
    }
  }

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
      notifyListeners();
      return false;
    }
  }

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

  /// Modifie la réponse admin existante.
  Future<bool> updateAdminResponse(int reviewId, String response) async {
    try {
      final success =
          await _repository.updateAdminResponse(reviewId, response);
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

  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_reviews.map((r) => r.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  Future<int> bulkApproveSelected() async {
    final count = await _repository.bulkApproveReviews(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  Future<int> bulkRejectSelected() async {
    final count = await _repository.bulkRejectReviews(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  Future<int> bulkDeleteSelected() async {
    final count = await _repository.bulkDeleteReviews(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  Future<int> bulkMarkSpamSelected() async {
    final count = await _repository.bulkMarkAsSpam(selectedIds);
    _selectedIds.clear();
    await refreshReviews();
    return count;
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Normalise un avis (conversion AdminReviewModel → AdminReview).
  AdminReview _normalizeReview(AdminReview review) {
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
        userId: review.userId,
        userName: review.userName,
        userEmail: review.userEmail,
        userAvatar: review.userAvatar,
        productId: review.productId,
        productName: review.productName,
        productSku: review.productSku,
        productImage: review.productImage,
        status: review.status,
        adminResponse: review.adminResponse,
        adminResponseAt: review.adminResponseAt,
        approvedAt: review.approvedAt,
        isRecommended: review.isRecommended,
        isVerifiedPurchase: review.isVerifiedPurchase,
        helpfulCount: review.helpfulCount,
        notHelpfulCount: review.notHelpfulCount,
        viewsCount: review.viewsCount,
        images: review.images,
      );
    }
    return review;
  }

  /// Met à jour le statut d'un avis dans la liste.
  void _updateReviewStatus(int id, AdminReviewStatus status) {
    final index = _reviews.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(
        status: status,
        approvedAt:
            status == AdminReviewStatus.approved ? DateTime.now() : null,
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

  void reset() {
    _status = AdminReviewStatus2.initial;
    _reviews = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filterStatus = null;
    _filterRating = null;
    _filterProductId = null;
    _filterWithPhotos = false;
    _filterVerified = false;
    _selectedIds.clear();
    _statusCounts = {};
    _ratingCounts = {};
    _averageRating = 0;
    _isGroupedByProduct = false;
    _groupedByProduct = [];
    _statsByProduct = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminReviewProvider(status: $_status, reviews: ${_reviews.length}, '
        'pending: $pendingCount, approved: $approvedCount, '
        'withPhotos: $withPhotosCount, grouped: $_isGroupedByProduct)';
  }
}