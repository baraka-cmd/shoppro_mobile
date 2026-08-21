// Implémentation du repository des favoris
// Gère la logique métier des favoris avec stockage local

import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../models/favorite_model.dart';
import '../sources/favorite_local_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _localDataSource;

  FavoriteRepositoryImpl({FavoriteLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? FavoriteLocalDataSource();

  @override
  Future<List<Favorite>> getFavorites() async {
    return await _localDataSource.getFavorites();
  }

  @override
  Future<List<Favorite>> addFavorite(Favorite favorite) async {
    final favorites = await getFavorites();

    // Vérifier si déjà présent
    final exists = favorites.any((f) => f.productId == favorite.productId);

    if (!exists) {
      favorites.add(favorite);
      await _localDataSource.saveFavorites(favorites);
    }

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
  Future<bool> toggleFavorite(Favorite favorite) async {
    final favorites = await getFavorites();
    final exists = favorites.any((f) => f.productId == favorite.productId);

    if (exists) {
      // Supprimer
      favorites.removeWhere((f) => f.productId == favorite.productId);
      await _localDataSource.saveFavorites(favorites);
      return false; // Retiré des favoris
    } else {
      // Ajouter
      favorites.add(favorite);
      await _localDataSource.saveFavorites(favorites);
      return true; // Ajouté aux favoris
    }
  }

  @override
  Future<bool> isFavorite(int productId) async {
    return await _localDataSource.isFavorite(productId);
  }

  @override
  Future<int> getFavoritesCount() async {
    return await _localDataSource.getFavoritesCount();
  }

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
  Future<void> clearFavorites() async {
    await _localDataSource.clearFavorites();
  }

  @override
  Future<void> saveFavorites(List<Favorite> favorites) async {
    await _localDataSource.saveFavorites(favorites);
  }

  @override
  Future<List<Favorite>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getFavorites();
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
}