// ============================================
// PROVIDER : AdminPromotionProvider
// ============================================
// Provider de gestion d'état pour la gestion des promotions.
// Utilise ChangeNotifier pour notifier les widgets des changements.
//
// Responsabilités :
// - Chargement des promotions paginées
// - Recherche et filtrage
// - CRUD complet
// - Gestion des statuts (activer, pause, annuler)
// - Statistiques
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (même feature admin)
import '../../domain/entities/admin_promotion.dart';

// Repositories (même feature admin)
import '../../domain/repositories/admin_promotion_repository.dart';

// Repositories Impl (même feature admin)
import '../../data/repositories/admin_promotion_repository_impl.dart';
import '../../data/models/admin_promotion_model.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider promotions
enum AdminPromotionStatus2 {
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

/// Provider de gestion des promotions administrées.
///
/// Gère :
/// - La liste paginée des promotions
/// - Les opérations CRUD
/// - Les changements de statut
/// - Les statistiques d'utilisation
class AdminPromotionProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminPromotionRepository _repository;

  // ============================================
  // ÉTAT
  // ============================================

  AdminPromotionStatus2 _status = AdminPromotionStatus2.initial;
  List<AdminPromotion> _promotions = [];
  String? _errorMessage;
  int _currentPage = 1;
  int _perPage = 20;
  bool _hasMore = true;

  // Filtres
  AdminPromotionType? _filterType;
  AdminPromotionStatus? _filterStatus;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  Map<String, int> _statusCounts = {};
  Map<String, int> _typeCounts = {};

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminPromotionProvider({AdminPromotionRepository? repository})
      : _repository = repository ?? AdminPromotionRepositoryImpl();

  // ============================================
  // GETTERS
  // ============================================

  AdminPromotionStatus2 get status => _status;
  List<AdminPromotion> get promotions => List.unmodifiable(_promotions);
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == AdminPromotionStatus2.loading;
  bool get isLoaded => _status == AdminPromotionStatus2.loaded;
  bool get isLoadingMore => _status == AdminPromotionStatus2.loadingMore;
  bool get isUpdating => _status == AdminPromotionStatus2.updating;
  bool get hasError => _status == AdminPromotionStatus2.error;
  int get promotionsCount => _promotions.length;
  bool get isEmpty => _promotions.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);
  Map<String, int> get statusCounts => Map.unmodifiable(_statusCounts);
  Map<String, int> get typeCounts => Map.unmodifiable(_typeCounts);

  /// Promotions actives
  List<AdminPromotion> get activePromotions =>
      _promotions.where((p) => p.isCurrentlyActive).toList();

  /// Promotions à venir
  List<AdminPromotion> get upcomingPromotions =>
      _promotions.where((p) => p.isUpcoming).toList();

  /// Promotions expirées
  List<AdminPromotion> get expiredPromotions =>
      _promotions.where((p) => p.isExpired).toList();

  /// Promotions en vedette
  List<AdminPromotion> get featuredPromotions =>
      _promotions.where((p) => p.isFeatured).toList();

  /// Promotions expirant bientôt
  List<AdminPromotion> get expiringSoonPromotions =>
      _promotions.where((p) => p.isExpiringSoon).toList();

  /// Nombre de promotions actives
  int get activeCount => activePromotions.length;

  /// Nombre de promotions à venir
  int get upcomingCount => upcomingPromotions.length;

  /// Nombre de promotions expirées
  int get expiredCount => expiredPromotions.length;

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge la première page des promotions.
  Future<void> loadPromotions() async {
  _status = AdminPromotionStatus2.loading;
  _errorMessage = null;
  _currentPage = 1;
  notifyListeners();

  try {
    final promotions = await _repository.getPromotions(
      page: _currentPage,
      perPage: _perPage,
      type: _filterType,
      status: _filterStatus,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );

    // ✅ CONVERSION : Si promotions est List<AdminPromotionModel>, convertir
    _promotions = promotions.map((promotion) {
      if (promotion is AdminPromotionModel) {
        return AdminPromotion(
          id: promotion.id,
          name: promotion.name,
          slug: promotion.slug,
          description: promotion.description,
          type: promotion.type,
          discountType: promotion.discountType,
          discountValue: promotion.discountValue,
          startDate: promotion.startDate,
          endDate: promotion.endDate,
          minimumOrder: promotion.minimumOrder,
          usageLimit: promotion.usageLimit,
          usageCount: promotion.usageCount,
          usagePerUser: promotion.usagePerUser,
          banner: promotion.banner,
          bannerMobile: promotion.bannerMobile,
          status: promotion.status,
          isActive: promotion.isActive,
          isFeatured: promotion.isFeatured,
          showCountdown: promotion.showCountdown,
          productsCount: promotion.productsCount,
          totalRevenue: promotion.totalRevenue,
          ordersCount: promotion.ordersCount,
          totalSavings: promotion.totalSavings,
        );
      }
      return promotion;
    }).toList();

    _hasMore = promotions.length >= _perPage;
    _status = AdminPromotionStatus2.loaded;
    await _loadStatistics();
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminPromotionStatus2.error;
    debugPrint('Erreur loadPromotions: $e');
  }

  notifyListeners();
}


  /// Charge la page suivante.
  Future<void> loadMorePromotions() async {
    if (_status == AdminPromotionStatus2.loadingMore || !_hasMore) return;

    _status = AdminPromotionStatus2.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final promotions = await _repository.getPromotions(
        page: nextPage,
        perPage: _perPage,
        type: _filterType,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      if (promotions.isEmpty) {
        _hasMore = false;
      } else {
        _promotions = [..._promotions, ...promotions];
        _currentPage = nextPage;
        _hasMore = promotions.length >= _perPage;
      }

      _status = AdminPromotionStatus2.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminPromotionStatus2.error;
      debugPrint('Erreur loadMorePromotions: $e');
    }

    notifyListeners();
  }

  /// Rafraîchit sans loader.
  Future<void> refreshPromotions() async {
    try {
      final promotions = await _repository.getPromotions(
        page: 1,
        perPage: _perPage,
        type: _filterType,
        status: _filterStatus,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _promotions = promotions;
      _currentPage = 1;
      _hasMore = promotions.length >= _perPage;
      _status = AdminPromotionStatus2.loaded;
      await _loadStatistics();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur refreshPromotions: $e');
    }

    notifyListeners();
  }

  // ============================================
  // RECHERCHE ET FILTRES
  // ============================================

  /// Filtre par type.
  Future<void> filterByType(AdminPromotionType? type) async {
    _filterType = type;
    await loadPromotions();
  }

  /// Filtre par statut.
  Future<void> filterByStatus(AdminPromotionStatus? status) async {
    _filterStatus = status;
    await loadPromotions();
  }

  /// Trie les résultats.
  Future<void> sort(String sortBy, {String direction = 'asc'}) async {
    _sortBy = sortBy;
    _sortDirection = direction;
    await loadPromotions();
  }

  /// Efface les filtres.
  Future<void> clearFilters() async {
    _filterType = null;
    _filterStatus = null;
    _sortBy = 'created_at';
    _sortDirection = 'desc';
    await loadPromotions();
  }

  // ============================================
  // CRUD
  // ============================================

  /// Crée une nouvelle promotion.
  Future<bool> createPromotion(AdminPromotion promotion) async {
    _status = AdminPromotionStatus2.updating;
    notifyListeners();

    try {
      final created = await _repository.createPromotion(promotion);
      _promotions.insert(0, created);
      _status = AdminPromotionStatus2.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminPromotionStatus2.error;
      debugPrint('Erreur createPromotion: $e');
      notifyListeners();
      return false;
    }
  }

  /// Met à jour une promotion.
  Future<bool> updatePromotion(AdminPromotion promotion) async {
    _status = AdminPromotionStatus2.updating;
    notifyListeners();

    try {
      final updated = await _repository.updatePromotion(promotion);
      final index = _promotions.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        _promotions[index] = updated;
      }
      _status = AdminPromotionStatus2.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminPromotionStatus2.error;
      debugPrint('Erreur updatePromotion: $e');
      notifyListeners();
      return false;
    }
  }

  /// Supprime une promotion.
  Future<bool> deletePromotion(int id) async {
    try {
      final success = await _repository.deletePromotion(id);
      if (success) {
        _promotions.removeWhere((p) => p.id == id);
        _selectedIds.remove(id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Erreur deletePromotion: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // GESTION DES STATUTS
  // ============================================

  /// Active une promotion.
  Future<bool> activatePromotion(int id) async {
    try {
      final success = await _repository.activatePromotion(id);
      if (success) {
        _updateStatus(id, AdminPromotionStatus.active);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Désactive une promotion.
  Future<bool> deactivatePromotion(int id) async {
    try {
      final success = await _repository.deactivatePromotion(id);
      if (success) {
        _updateStatus(id, AdminPromotionStatus.paused);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Met en pause une promotion.
  Future<bool> pausePromotion(int id) async {
    try {
      final success = await _repository.pausePromotion(id);
      if (success) {
        _updateStatus(id, AdminPromotionStatus.paused);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reprend une promotion.
  Future<bool> resumePromotion(int id) async {
    try {
      final success = await _repository.resumePromotion(id);
      if (success) {
        _updateStatus(id, AdminPromotionStatus.active);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Annule une promotion.
  Future<bool> cancelPromotion(int id, {String? reason}) async {
    try {
      final success = await _repository.cancelPromotion(id, reason: reason);
      if (success) {
        _updateStatus(id, AdminPromotionStatus.cancelled);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Met en vedette une promotion.
  Future<bool> toggleFeatured(int id, {required bool isFeatured}) async {
    try {
      final success = await _repository.setFeaturedPromotion(id, isFeatured: isFeatured);
      if (success) {
        final index = _promotions.indexWhere((p) => p.id == id);
        if (index != -1) {
          _promotions[index] = _promotions[index].copyWith(isFeatured: isFeatured);
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
  // VALIDATION
  // ============================================

  /// Vérifie si un slug est disponible.
  Future<bool> isSlugAvailable(String slug) async {
    try {
      return await _repository.isSlugAvailable(slug);
    } catch (e) {
      debugPrint('Erreur isSlugAvailable: $e');
      return false;
    }
  }

  /// Vérifie si une promotion est valide.
  Future<bool> isPromotionValid(int id) async {
    try {
      return await _repository.isPromotionValid(id);
    } catch (e) {
      debugPrint('Erreur isPromotionValid: $e');
      return false;
    }
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Toggle la sélection d'une promotion.
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Sélectionne toutes les promotions.
  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_promotions.map((p) => p.id));
    notifyListeners();
  }

  /// Efface la sélection.
  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  /// Vérifie si une promotion est sélectionnée.
  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // ACTIONS EN MASSE
  // ============================================

  /// Active les promotions sélectionnées.
  Future<int> bulkActivateSelected() async {
    final count = await _repository.bulkActivatePromotions(selectedIds);
    _selectedIds.clear();
    await refreshPromotions();
    return count;
  }

  /// Désactive les promotions sélectionnées.
  Future<int> bulkDeactivateSelected() async {
    final count = await _repository.bulkDeactivatePromotions(selectedIds);
    _selectedIds.clear();
    await refreshPromotions();
    return count;
  }

  /// Supprime les promotions sélectionnées.
  Future<int> bulkDeleteSelected() async {
    final count = await _repository.bulkDeletePromotions(selectedIds);
    _selectedIds.clear();
    await refreshPromotions();
    return count;
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Met à jour le statut d'une promotion dans la liste.
  void _updateStatus(int id, AdminPromotionStatus status) {
    final index = _promotions.indexWhere((p) => p.id == id);
    if (index != -1) {
      _promotions[index] = _promotions[index].copyWith(status: status);
      notifyListeners();
    }
  }

  /// Charge les statistiques des promotions.
  Future<void> _loadStatistics() async {
    try {
      _statusCounts = await _repository.getPromotionsCountByStatus();
      _typeCounts = await _repository.getPromotionsCountByType();
    } catch (e) {
      debugPrint('Erreur _loadStatistics: $e');
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminPromotionStatus2.initial;
    _promotions = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filterType = null;
    _filterStatus = null;
    _selectedIds.clear();
    _statusCounts = {};
    _typeCounts = {};
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminPromotionProvider(status: $_status, promotions: ${_promotions.length}, '
        'active: $activeCount, upcoming: $upcomingCount, expired: $expiredCount)';
  }
}