// ============================================
// PROVIDER : SellerReviewProvider
// ============================================
// Gestion d'état pour les avis vendeur.
//
// Responsabilités :
//   - Chargement paginé avec filtres (statut, note, photos, vérifiés)
//   - Recherche
//   - Actions : respond, approve, reject, markAsSpam
//   - Statistiques globales (total, pending, approved, etc.)
//   - Gestion des erreurs
//
// Pattern :
//   - ChangeNotifier (Provider)
//   - États via enums
//   - Notification listeners après chaque changement
// ============================================

// Flutter
import 'package:flutter/foundation.dart';

// Domain
import '../../domain/entities/seller_review.dart';

// Data
import '../../data/sources/seller_review_api.dart';

// ============================================
// ENUMS
// ============================================

enum SellerReviewListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  forbidden,
  unauthorized,
}

enum SellerReviewActionStatus {
  idle,
  responding,
  approving,
  rejecting,
  markingSpam,
  error,
}

// ============================================
// ONGLETS (TABS) DE FILTRE
// ============================================

enum SellerReviewTab {
  all('all', 'Tous'),
  pending('pending', 'En attente'),
  approved('approved', 'Approuvés'),
  rejected('rejected', 'Rejetés'),
  spam('spam', 'Spam');

  final String statusCode;
  final String label;

  const SellerReviewTab(this.statusCode, this.label);
}

// ============================================
// PROVIDER PRINCIPAL
// ============================================

class SellerReviewProvider extends ChangeNotifier {
  final SellerReviewApi _api;

  SellerReviewProvider({SellerReviewApi? api}) : _api = api ?? SellerReviewApi();

  // ============================================
  // ÉTAT : LISTE
  // ============================================

  SellerReviewListStatus _listStatus = SellerReviewListStatus.initial;
  List<SellerReview> _reviews = [];
  String? _listError;

  // Pagination
  int _currentPage = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _hasMore = false;
  int _perPage = 15;

  // Filtres
  SellerReviewTab _activeTab = SellerReviewTab.all;
  int? _filterRating;
  int? _filterProductId;
  bool _filterWithPhotos = false;
  bool _filterVerified = false;
  String _search = '';
  String _sortBy = 'created_at';
  String _sortDir = 'desc';

  // Stats
  SellerReviewsStats _stats = const SellerReviewsStats.empty();

  // ============================================
  // ÉTAT : ACTION
  // ============================================

  SellerReviewActionStatus _actionStatus = SellerReviewActionStatus.idle;
  String? _actionError;
  int? _lastAffectedReviewId;

  // ============================================
  // GETTERS : LISTE
  // ============================================

  SellerReviewListStatus get listStatus => _listStatus;
  List<SellerReview> get reviews => List.unmodifiable(_reviews);
  String? get listError => _listError;

  bool get isLoading => _listStatus == SellerReviewListStatus.loading;
  bool get isLoaded => _listStatus == SellerReviewListStatus.loaded;
  bool get isLoadingMore => _listStatus == SellerReviewListStatus.loadingMore;
  bool get hasError => _listStatus == SellerReviewListStatus.error;
  bool get isForbidden => _listStatus == SellerReviewListStatus.forbidden;
  bool get isUnauthorized => _listStatus == SellerReviewListStatus.unauthorized;

  bool get isEmpty => _reviews.isEmpty;
  int get reviewsCount => _reviews.length;
  int get total => _total;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMore => _hasMore;

  SellerReviewTab get activeTab => _activeTab;
  int? get filterRating => _filterRating;
  int? get filterProductId => _filterProductId;
  bool get filterWithPhotos => _filterWithPhotos;
  bool get filterVerified => _filterVerified;
  String get search => _search;
  String get sortBy => _sortBy;
  String get sortDir => _sortDir;

  /// Le provider a-t-il des filtres actifs (hors défaut) ?
  bool get hasActiveFilters =>
      _activeTab != SellerReviewTab.all ||
      _filterRating != null ||
      _filterProductId != null ||
      _filterWithPhotos ||
      _filterVerified ||
      _search.isNotEmpty;

  /// Nombre de filtres actifs (pour badge).
  int get activeFiltersCount {
    var count = 0;
    if (_activeTab != SellerReviewTab.all) count++;
    if (_filterRating != null) count++;
    if (_filterProductId != null) count++;
    if (_filterWithPhotos) count++;
    if (_filterVerified) count++;
    if (_search.isNotEmpty) count++;
    return count;
  }

  // ============================================
  // GETTERS : STATS
  // ============================================

  SellerReviewsStats get stats => _stats;

  int get totalReviewsCount => _stats.total;
  int get pendingCount => _stats.pending;
  int get approvedCount => _stats.approved;
  int get rejectedCount => _stats.rejected;
  int get spamCount => _stats.spam;
  int get withPhotosCount => _stats.withPhotos;
  int get verifiedCount => _stats.verified;
  double get averageRating => _stats.averageRating;
  int get toModerateCount => _stats.toModerate;

  /// Retourne le count d'un onglet donné.
  int getCountForTab(SellerReviewTab tab) {
    switch (tab) {
      case SellerReviewTab.all:
        return _stats.total;
      case SellerReviewTab.pending:
        return _stats.pending;
      case SellerReviewTab.approved:
        return _stats.approved;
      case SellerReviewTab.rejected:
        return _stats.rejected;
      case SellerReviewTab.spam:
        return _stats.spam;
    }
  }

  // ============================================
  // GETTERS : ACTION
  // ============================================

  SellerReviewActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  int? get lastAffectedReviewId => _lastAffectedReviewId;

  bool get isResponding =>
      _actionStatus == SellerReviewActionStatus.responding;
  bool get isApproving => _actionStatus == SellerReviewActionStatus.approving;
  bool get isRejecting => _actionStatus == SellerReviewActionStatus.rejecting;
  bool get isMarkingSpam =>
      _actionStatus == SellerReviewActionStatus.markingSpam;
  bool get hasActionError =>
      _actionStatus == SellerReviewActionStatus.error;

  bool get isPerformingAction =>
      _actionStatus != SellerReviewActionStatus.idle &&
      _actionStatus != SellerReviewActionStatus.error;

  // ============================================
  // CHARGEMENT DE LA LISTE
  // ============================================

  /// Charge la première page avec les filtres actifs.
  Future<void> loadReviews({bool forceRefresh = false}) async {
    if (isLoading && !forceRefresh) return;

    _listStatus = SellerReviewListStatus.loading;
    _listError = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await _api.getReviews(
        page: 1,
        perPage: _perPage,
        status: _activeTab.statusCode,
        rating: _filterRating,
        productId: _filterProductId,
        withPhotos: _filterWithPhotos,
        verified: _filterVerified,
        search: _search.isNotEmpty ? _search : null,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );

      _reviews = result.reviews;
      _stats = result.stats;
      _currentPage = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerReviewListStatus.loaded;
    } on SellerReviewForbiddenException catch (e) {
      _listStatus = SellerReviewListStatus.forbidden;
      _listError = e.message;
    } on SellerReviewUnauthorizedException catch (e) {
      _listStatus = SellerReviewListStatus.unauthorized;
      _listError = e.message;
    } catch (e) {
      _listStatus = SellerReviewListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charge la page suivante (pagination infinie).
  Future<void> loadMore() async {
    if (isLoadingMore || !_hasMore) return;

    _listStatus = SellerReviewListStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final result = await _api.getReviews(
        page: nextPage,
        perPage: _perPage,
        status: _activeTab.statusCode,
        rating: _filterRating,
        productId: _filterProductId,
        withPhotos: _filterWithPhotos,
        verified: _filterVerified,
        search: _search.isNotEmpty ? _search : null,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );

      _reviews = [..._reviews, ...result.reviews];
      _stats = result.stats;
      _currentPage = result.currentPage;
      _total = result.total;
      _hasMore = result.hasMore;
      _listStatus = SellerReviewListStatus.loaded;
    } catch (e) {
      _listStatus = SellerReviewListStatus.error;
      _listError = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Rafraîchit la liste.
  Future<void> refresh() async {
    await loadReviews(forceRefresh: true);
  }

  // ============================================
  // FILTRES
  // ============================================

  /// Change l'onglet actif.
  Future<void> setActiveTab(SellerReviewTab tab) async {
    if (_activeTab == tab) return;
    _activeTab = tab;
    _reviews = [];
    await loadReviews();
  }

  /// Filtre par note.
  Future<void> setRatingFilter(int? rating) async {
    _filterRating = rating;
    await loadReviews();
  }

  /// Filtre par produit.
  Future<void> setProductFilter(int? productId) async {
    _filterProductId = productId;
    await loadReviews();
  }

  /// Active/désactive le filtre "avec photos".
  Future<void> setWithPhotosFilter(bool enabled) async {
    _filterWithPhotos = enabled;
    await loadReviews();
  }

  /// Active/désactive le filtre "achats vérifiés".
  Future<void> setVerifiedFilter(bool enabled) async {
    _filterVerified = enabled;
    await loadReviews();
  }

  /// Change la recherche.
  Future<void> setSearch(String value) async {
    _search = value.trim();
    await loadReviews();
  }

  /// Change le tri.
  Future<void> setSort(String sortBy, {String? sortDir}) async {
    _sortBy = sortBy;
    if (sortDir != null) _sortDir = sortDir;
    await loadReviews();
  }

  /// Efface tous les filtres.
  Future<void> clearFilters() async {
    _activeTab = SellerReviewTab.all;
    _filterRating = null;
    _filterProductId = null;
    _filterWithPhotos = false;
    _filterVerified = false;
    _search = '';
    _sortBy = 'created_at';
    _sortDir = 'desc';
    await loadReviews();
  }

  // ============================================
  // ACTIONS : RESPOND
  // ============================================

  Future<SellerReview?> respondToReview(
    int reviewId, {
    required String response,
  }) async {
    return _performAction(
      status: SellerReviewActionStatus.responding,
      reviewId: reviewId,
      action: () => _api.respondToReview(reviewId, response: response),
    );
  }

  // ============================================
  // ACTIONS : APPROVE
  // ============================================

  Future<SellerReview?> approveReview(int reviewId) async {
    return _performAction(
      status: SellerReviewActionStatus.approving,
      reviewId: reviewId,
      action: () => _api.approveReview(reviewId),
    );
  }

  // ============================================
  // ACTIONS : REJECT
  // ============================================

  Future<SellerReview?> rejectReview(
    int reviewId, {
    String? reason,
  }) async {
    return _performAction(
      status: SellerReviewActionStatus.rejecting,
      reviewId: reviewId,
      action: () => _api.rejectReview(reviewId, reason: reason),
    );
  }

  // ============================================
  // ACTIONS : MARK AS SPAM
  // ============================================

  Future<SellerReview?> markAsSpam(int reviewId) async {
    return _performAction(
      status: SellerReviewActionStatus.markingSpam,
      reviewId: reviewId,
      action: () => _api.markAsSpam(reviewId),
    );
  }

  // ============================================
  // HELPER : EXÉCUTION D'ACTION
  // ============================================

  Future<SellerReview?> _performAction({
    required SellerReviewActionStatus status,
    required int reviewId,
    required Future<SellerReview> Function() action,
  }) async {
    _actionStatus = status;
    _actionError = null;
    _lastAffectedReviewId = reviewId;
    notifyListeners();

    try {
      final updatedReview = await action();

      // Mettre à jour l'avis dans la liste
      final index = _reviews.indexWhere((r) => r.id == updatedReview.id);
      if (index != -1) {
        final newList = List<SellerReview>.from(_reviews);
        newList[index] = updatedReview;
        _reviews = newList;
      }

      _actionStatus = SellerReviewActionStatus.idle;
      notifyListeners();

      // Rafraîchir les stats en arrière-plan
      _refreshStatsInBackground();

      return updatedReview;
    } catch (e) {
      _actionStatus = SellerReviewActionStatus.error;
      _actionError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Rafraîchit les stats sans bloquer l'UI.
  Future<void> _refreshStatsInBackground() async {
    try {
      // Recharger les stats globales
      final result = await _api.getReviews(page: 1, perPage: 1);
      _stats = result.stats;
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Impossible de rafraîchir les stats: $e');
    }
  }

    // ============================================
  // DÉTAIL D'UN AVIS
  // ============================================

  /// Charge un avis par ID.
  ///
  /// - Cherche d'abord dans la liste locale
  /// - Sinon, appelle l'API
  /// - Ajoute au cache local si trouvé
  Future<SellerReview?> getReviewById(int id) async {
    // 1. Cherche dans la liste locale
    for (final review in _reviews) {
      if (review.id == id) {
        return review;
      }
    }

    // 2. Appelle l'API
    try {
      final review = await _api.getReviewById(id);

      // 3. Ajoute au cache local
      if (!_reviews.any((r) => r.id == review.id)) {
        _reviews = [review, ..._reviews];
        notifyListeners();
      }

      return review;
    } catch (e) {
      debugPrint('❌ Erreur getReviewById: $e');
      return null;
    }
  }

  
  // ============================================
  // RESET / CLEAR
  // ============================================

  /// Efface les erreurs.
  void clearErrors() {
    _listError = null;
    _actionError = null;
    _lastAffectedReviewId = null;

    if (_listStatus == SellerReviewListStatus.error) {
      _listStatus = _reviews.isNotEmpty
          ? SellerReviewListStatus.loaded
          : SellerReviewListStatus.initial;
    }

    if (_actionStatus == SellerReviewActionStatus.error) {
      _actionStatus = SellerReviewActionStatus.idle;
    }

    notifyListeners();
  }

  /// Réinitialise complètement le provider (logout).
  void reset() {
    _listStatus = SellerReviewListStatus.initial;
    _actionStatus = SellerReviewActionStatus.idle;
    _reviews = [];
    _listError = null;
    _actionError = null;
    _lastAffectedReviewId = null;
    _activeTab = SellerReviewTab.all;
    _filterRating = null;
    _filterProductId = null;
    _filterWithPhotos = false;
    _filterVerified = false;
    _search = '';
    _sortBy = 'created_at';
    _sortDir = 'desc';
    _currentPage = 1;
    _lastPage = 1;
    _total = 0;
    _hasMore = false;
    _stats = const SellerReviewsStats.empty();
    notifyListeners();
  }

  @override
  String toString() {
    return 'SellerReviewProvider(tab: ${_activeTab.label}, '
        'reviews: ${_reviews.length}, total: $_total, '
        'actionStatus: $_actionStatus)';
  }
}