// ============================================
// PROVIDER DES FAVORIS - VERSION PREMIUM
// ============================================
// Gère l'état des favoris avec actions complètes,
// filtres intelligents et annulation.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../data/repositories/favorite_repository_impl.dart';

enum FavoriteStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;

  FavoriteProvider({FavoriteRepository? favoriteRepository})
      : _favoriteRepository = favoriteRepository ?? FavoriteRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  FavoriteStatus _status = FavoriteStatus.initial;
  List<Favorite> _favorites = [];
  String? _errorMessage;
  int _updatingFavoriteId = -1;
  String _currentFilter = 'all';
  String _currentSort = 'recent';

  // ============================================
  // GETTERS DE BASE
  // ============================================

  FavoriteStatus get status => _status;
  List<Favorite> get favorites => _favorites;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == FavoriteStatus.loading;
  bool get isUpdating => _status == FavoriteStatus.updating;
  bool get hasError => _status == FavoriteStatus.error;
  bool get isEmpty => _favorites.isEmpty;
  int get favoritesCount => _favorites.length;

  /// ID du favori en cours de mise à jour
  int get updatingFavoriteId => _updatingFavoriteId;

  /// Filtre actuel
  String get currentFilter => _currentFilter;

  /// Tri actuel
  String get currentSort => _currentSort;

  // ============================================
  // GETTERS FILTRÉS
  // ============================================

  /// Favoris filtrés selon le filtre actuel
  List<Favorite> get filteredFavorites {
    switch (_currentFilter) {
      case 'in_stock':
        return inStockFavorites;
      case 'on_sale':
        return onSaleFavorites;
      case 'price_dropped':
        return priceDroppedFavorites;
      case 'price_alert':
        return priceAlertFavorites;
      case 'out_of_stock':
        return outOfStockFavorites;
      default:
        return List.from(_favorites);
    }
  }

  /// Favoris triés selon le tri actuel
  List<Favorite> get sortedFavorites {
    final sorted = List<Favorite>.from(filteredFavorites);

    switch (_currentSort) {
      case 'price_asc':
        sorted.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'rating_desc':
        sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'discount_desc':
        sorted.sort((a, b) => (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));
        break;
      default: // recent
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }

    return sorted;
  }

  /// Favoris en stock
  List<Favorite> get inStockFavorites {
    return _favorites.where((f) => f.isInStock).toList();
  }

  /// Favoris en promotion
  List<Favorite> get onSaleFavorites {
    return _favorites.where((f) => f.hasDiscount).toList();
  }

  /// Favoris avec alerte prix
  List<Favorite> get priceAlertFavorites {
    return _favorites.where((f) => f.priceAlert).toList();
  }

  /// Favoris dont le prix a baissé
  List<Favorite> get priceDroppedFavorites {
    return _favorites.where((f) => f.hasPriceDropped).toList();
  }

  /// Favoris en rupture
  List<Favorite> get outOfStockFavorites {
    return _favorites.where((f) => f.isOutOfStock).toList();
  }

  /// Nombre de favoris dont le prix a baissé
  int get priceDroppedCount => priceDroppedFavorites.length;

  /// Nombre de favoris en rupture
  int get outOfStockCount => outOfStockFavorites.length;

  /// Nombre de favoris avec alerte prix
  int get priceAlertCount => priceAlertFavorites.length;

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger les favoris
  Future<void> loadFavorites() async {
    _setStatus(FavoriteStatus.loading);
    _clearError();

    try {
      _favorites = await _favoriteRepository.getFavorites();
      _setStatus(FavoriteStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(FavoriteStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les favoris
  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  // ============================================
  // AJOUT
  // ============================================

  /// Ajouter un favori
  Future<bool> addFavorite(Favorite favorite) async {
    _setStatus(FavoriteStatus.updating);

    try {
      await _favoriteRepository.saveFavoritesSnapshot();
      _favorites = await _favoriteRepository.addFavorite(favorite);
      _setStatus(FavoriteStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(FavoriteStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer un favori
  Future<bool> removeFavorite(int favoriteId) async {
    _setStatus(FavoriteStatus.updating);
    _updatingFavoriteId = favoriteId;

    try {
      await _favoriteRepository.saveFavoritesSnapshot();
      _favorites = await _favoriteRepository.removeFavorite(favoriteId);
      _updatingFavoriteId = -1;
      _setStatus(FavoriteStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingFavoriteId = -1;
      _setError(e.toString());
      _setStatus(FavoriteStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Supprimer par ID produit
  Future<bool> removeByProductId(int productId) async {
    _setStatus(FavoriteStatus.updating);

    try {
      await _favoriteRepository.saveFavoritesSnapshot();
      _favorites = await _favoriteRepository.removeByProductId(productId);
      _setStatus(FavoriteStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(FavoriteStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // TOGGLE
  // ============================================

  /// Toggle favori
  Future<bool?> toggleFavorite(Favorite favorite) async {
    _setStatus(FavoriteStatus.updating);

    try {
      await _favoriteRepository.saveFavoritesSnapshot();
      final result = await _favoriteRepository.toggleFavorite(favorite);
      _favorites = await _favoriteRepository.getFavorites();
      _setStatus(FavoriteStatus.loaded);
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      _setStatus(FavoriteStatus.error);
      notifyListeners();
      return null;
    }
  }

  /// Vérifier si un produit est en favori
  Future<bool> isFavorite(int productId) async {
    return await _favoriteRepository.isFavorite(productId);
  }

  /// Vérifier si un produit est favori (synchrone)
  bool isFavoriteSync(int productId) {
    return _favorites.any((f) => f.productId == productId);
  }

  // ============================================
  // ALERTES PRIX
  // ============================================

  /// Activer/désactiver l'alerte prix
  Future<bool> togglePriceAlert(int favoriteId, {double? threshold}) async {
    _updatingFavoriteId = favoriteId;

    try {
      _favorites = await _favoriteRepository.togglePriceAlert(favoriteId, threshold);
      _updatingFavoriteId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingFavoriteId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Définir un seuil d'alerte prix
  Future<bool> setPriceAlertThreshold(int favoriteId, double threshold) async {
    _updatingFavoriteId = favoriteId;

    try {
      _favorites = await _favoriteRepository.setPriceAlertThreshold(favoriteId, threshold);
      _updatingFavoriteId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingFavoriteId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // FILTRES ET TRI
  // ============================================

  /// Changer le filtre
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Changer le tri
  void setSort(String sort) {
    _currentSort = sort;
    notifyListeners();
  }

  /// Effacer le filtre
  void clearFilter() {
    _currentFilter = 'all';
    notifyListeners();
  }

  // ============================================
  // COLLECTIONS
  // ============================================

  /// Mettre à jour la collection d'un favori
  Future<bool> updateCollection(int favoriteId, String collectionName) async {
    _updatingFavoriteId = favoriteId;

    try {
      _favorites = await _favoriteRepository.updateCollection(favoriteId, collectionName);
      _updatingFavoriteId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingFavoriteId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Récupérer les collections disponibles
  Future<List<String>> getCollections() async {
    return await _favoriteRepository.getCollections();
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Vider tous les favoris
  Future<void> clearFavorites() async {
    await _favoriteRepository.clearFavorites();
    _favorites = [];
    notifyListeners();
  }

  /// Annuler la dernière action
  Future<bool> undoLastAction() async {
    try {
      final restored = await _favoriteRepository.restoreFavoritesSnapshot();
      if (restored != null) {
        _favorites = restored;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(FavoriteStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'FavoriteProvider(status: $_status, favorites: ${_favorites.length}, '
        'filter: $_currentFilter, sort: $_currentSort, '
        'priceDropped: $priceDroppedCount, outOfStock: $outOfStockCount)';
  }
}