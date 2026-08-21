// Provider des favoris
// Gère l'état des favoris et les actions

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

  FavoriteStatus _status = FavoriteStatus.initial;
  List<Favorite> _favorites = [];
  String? _errorMessage;

  // Getters
  FavoriteStatus get status => _status;
  List<Favorite> get favorites => _favorites;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == FavoriteStatus.loading;
  bool get isUpdating => _status == FavoriteStatus.updating;
  bool get hasError => _status == FavoriteStatus.error;
  bool get isEmpty => _favorites.isEmpty;
  int get favoritesCount => _favorites.length;

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

  /// Ajouter un favori
  Future<bool> addFavorite(Favorite favorite) async {
    _setStatus(FavoriteStatus.updating);

    try {
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

  /// Supprimer un favori
  Future<bool> removeFavorite(int favoriteId) async {
    _setStatus(FavoriteStatus.updating);

    try {
      _favorites = await _favoriteRepository.removeFavorite(favoriteId);
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

  /// Toggle favori
  Future<bool?> toggleFavorite(Favorite favorite) async {
    _setStatus(FavoriteStatus.updating);

    try {
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

  /// Activer/désactiver l'alerte prix
  Future<bool> togglePriceAlert(int favoriteId, {double? threshold}) async {
    _setStatus(FavoriteStatus.updating);

    try {
      _favorites = await _favoriteRepository.togglePriceAlert(favoriteId, threshold);
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

  /// Vider tous les favoris
  Future<void> clearFavorites() async {
    await _favoriteRepository.clearFavorites();
    _favorites = [];
    notifyListeners();
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(FavoriteStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}