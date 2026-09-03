// ============================================
// IMPLÉMENTATION DU REPOSITORY DES FAVORIS - PREMIUM
// ============================================
// Gère la logique métier des favoris avec
// stockage local, alertes prix et collections.
// ============================================

import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../models/favorite_model.dart';
import '../sources/favorite_local_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _localDataSource;

  FavoriteRepositoryImpl({FavoriteLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? FavoriteLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<Favorite>> getFavorites() async {
    return await _localDataSource.getFavorites();
  }

  @override
  Future<List<Favorite>> getInStockFavorites() async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.isInStock).toList();
  }

  @override
  Future<List<Favorite>> getOnSaleFavorites() async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.hasDiscount).toList();
  }

  @override
  Future<List<Favorite>> getPriceAlertFavorites() async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.priceAlert).toList();
  }

  @override
  Future<List<Favorite>> getPriceDroppedFavorites() async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.hasPriceDropped).toList();
  }

  @override
  Future<List<Favorite>> getOutOfStockFavorites() async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.isOutOfStock).toList();
  }

  @override
  Future<List<Favorite>> getFavoritesByCollection(String collectionName) async {
    final favorites = await getFavorites();
    return favorites
        .where((f) => f.collectionName == collectionName)
        .toList();
  }

  @override
  Future<List<String>> getCollections() async {
    final favorites = await getFavorites();
    return favorites
        .where((f) => f.collectionName != null && f.collectionName!.isNotEmpty)
        .map((f) => f.collectionName!)
        .toSet()
        .toList();
  }

  @override
  Future<int> getFavoritesCount() async {
    return await _localDataSource.getFavoritesCount();
  }

  @override
  Future<bool> isFavorite(int productId) async {
    return await _localDataSource.isFavorite(productId);
  }

  @override
  Future<Favorite?> getFavoriteByProductId(int productId) async {
    final favorites = await getFavorites();
    for (final favorite in favorites) {
      if (favorite.productId == productId) {
        return favorite;
      }
    }
    return null;
  }

  // ============================================
  // MODIFICATION
  // ============================================

  @override
  Future<List<Favorite>> addFavorite(Favorite favorite) async {
    final favorites = await getFavorites();

    final exists = favorites.any((f) => f.productId == favorite.productId);

    if (!exists) {
      favorites.add(favorite);
      await _localDataSource.saveFavorites(favorites);
    }

    return favorites;
  }

  @override
  Future<List<Favorite>> addFavorites(List<Favorite> newFavorites) async {
    final favorites = await getFavorites();

    for (final favorite in newFavorites) {
      final exists = favorites.any((f) => f.productId == favorite.productId);
      if (!exists) {
        favorites.add(favorite);
      }
    }

    await _localDataSource.saveFavorites(favorites);
    return favorites;
  }

  @override
  Future<List<Favorite>> removeFavorite(int favoriteId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.id == favoriteId);
    await _localDataSource.saveFavorites(favorites);
    return favorites;
  }

  @override
  Future<List<Favorite>> removeByProductId(int productId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.productId == productId);
    await _localDataSource.saveFavorites(favorites);
    return favorites;
  }

  @override
  Future<List<Favorite>> removeFavorites(List<int> favoriteIds) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => favoriteIds.contains(f.id));
    await _localDataSource.saveFavorites(favorites);
    return favorites;
  }

  @override
  Future<bool> toggleFavorite(Favorite favorite) async {
    final favorites = await getFavorites();
    final exists = favorites.any((f) => f.productId == favorite.productId);

    if (exists) {
      favorites.removeWhere((f) => f.productId == favorite.productId);
      await _localDataSource.saveFavorites(favorites);
      return false;
    } else {
      favorites.add(favorite);
      await _localDataSource.saveFavorites(favorites);
      return true;
    }
  }

  @override
  Future<void> clearFavorites() async {
    await _localDataSource.clearFavorites();
  }

  @override
  Future<void> saveFavorites(List<Favorite> favorites) async {
    await _localDataSource.saveFavorites(favorites);
  }

  // ============================================
  // ALERTES PRIX
  // ============================================

  @override
  Future<List<Favorite>> togglePriceAlert(int favoriteId, double? threshold) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((f) => f.id == favoriteId);

    if (index >= 0) {
      favorites[index] = favorites[index].copyWith(
        priceAlert: !favorites[index].priceAlert,
        priceAlertThreshold: threshold,
      );
      await _localDataSource.saveFavorites(favorites);
    }

    return favorites;
  }

  @override
  Future<List<Favorite>> setPriceAlertThreshold(
      int favoriteId, double threshold) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((f) => f.id == favoriteId);

    if (index >= 0) {
      favorites[index] = favorites[index].copyWith(
        priceAlert: true,
        priceAlertThreshold: threshold,
      );
      await _localDataSource.saveFavorites(favorites);
    }

    return favorites;
  }

  @override
  Future<List<Favorite>> removePriceAlert(int favoriteId) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((f) => f.id == favoriteId);

    if (index >= 0) {
      favorites[index] = favorites[index].copyWith(
        priceAlert: false,
        priceAlertThreshold: null,
      );
      await _localDataSource.saveFavorites(favorites);
    }

    return favorites;
  }

  // ============================================
  // COLLECTIONS
  // ============================================

  @override
  Future<List<Favorite>> updateCollection(int favoriteId, String collectionName) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((f) => f.id == favoriteId);

    if (index >= 0) {
      favorites[index] = favorites[index].copyWith(
        collectionName: collectionName,
      );
      await _localDataSource.saveFavorites(favorites);
    }

    return favorites;
  }

  @override
  Future<List<Favorite>> createCollection(String collectionName) async {
    // Pour créer une collection, il suffit d'ajouter des favoris avec ce nom
    return await getFavorites();
  }

  @override
  Future<List<Favorite>> deleteCollection(String collectionName) async {
    final favorites = await getFavorites();
    final updatedFavorites = favorites
        .map((f) => f.collectionName == collectionName
            ? f.copyWith(collectionName: null)
            : f)
        .toList();
    await _localDataSource.saveFavorites(updatedFavorites);
    return updatedFavorites;
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  @override
  Future<List<Favorite>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getFavorites();
  }

  @override
  Future<bool> isFavoritesSynced() async {
    // Pour l'instant, les favoris locaux sont toujours "synced"
    return true;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  @override
  Future<void> saveFavoritesSnapshot() async {
    await _localDataSource.saveFavoritesSnapshot();
  }

  @override
  Future<List<Favorite>> restoreFavoritesSnapshot() async {
    return await _localDataSource.restoreFavoritesSnapshot() ?? [];
  }

  @override
  Future<void> clearFavoritesSnapshot() async {
    await _localDataSource.clearFavoritesSnapshot();
  }
}