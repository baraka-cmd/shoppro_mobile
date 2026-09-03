// ============================================
// INTERFACE DU REPOSITORY DES FAVORIS - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète des favoris,
// alertes prix et collections.
// ============================================

import '../entities/favorite.dart';

abstract class FavoriteRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer tous les favoris
  Future<List<Favorite>> getFavorites();

  /// Récupérer les favoris en stock
  Future<List<Favorite>> getInStockFavorites();

  /// Récupérer les favoris en promotion
  Future<List<Favorite>> getOnSaleFavorites();

  /// Récupérer les favoris avec alerte prix
  Future<List<Favorite>> getPriceAlertFavorites();

  /// Récupérer les favoris dont le prix a baissé
  Future<List<Favorite>> getPriceDroppedFavorites();

  /// Récupérer les favoris en rupture de stock
  Future<List<Favorite>> getOutOfStockFavorites();

  /// Récupérer les favoris par collection
  Future<List<Favorite>> getFavoritesByCollection(String collectionName);

  /// Récupérer les collections disponibles
  Future<List<String>> getCollections();

  /// Récupérer le nombre de favoris
  Future<int> getFavoritesCount();

  /// Vérifier si un produit est en favori
  Future<bool> isFavorite(int productId);

  /// Récupérer un favori par ID produit
  Future<Favorite?> getFavoriteByProductId(int productId);

  // ============================================
  // MODIFICATION
  // ============================================

  /// Ajouter un favori
  Future<List<Favorite>> addFavorite(Favorite favorite);

  /// Ajouter plusieurs favoris
  Future<List<Favorite>> addFavorites(List<Favorite> favorites);

  /// Supprimer un favori
  Future<List<Favorite>> removeFavorite(int favoriteId);

  /// Supprimer par productId
  Future<List<Favorite>> removeByProductId(int productId);

  /// Supprimer plusieurs favoris
  Future<List<Favorite>> removeFavorites(List<int> favoriteIds);

  /// Toggle favori (ajouter si absent, supprimer si présent)
  Future<bool> toggleFavorite(Favorite favorite);

  /// Vider tous les favoris
  Future<void> clearFavorites();

  /// Sauvegarder les favoris localement
  Future<void> saveFavorites(List<Favorite> favorites);

  // ============================================
  // ALERTES PRIX
  // ============================================

  /// Activer/désactiver l'alerte de prix
  Future<List<Favorite>> togglePriceAlert(int favoriteId, double? threshold);

  /// Définir un seuil d'alerte de prix
  Future<List<Favorite>> setPriceAlertThreshold(
      int favoriteId, double threshold);

  /// Retirer l'alerte de prix
  Future<List<Favorite>> removePriceAlert(int favoriteId);

  // ============================================
  // COLLECTIONS
  // ============================================

  /// Mettre à jour la collection d'un favori
  Future<List<Favorite>> updateCollection(int favoriteId, String collectionName);

  /// Créer une nouvelle collection
  Future<List<Favorite>> createCollection(String collectionName);

  /// Supprimer une collection
  Future<List<Favorite>> deleteCollection(String collectionName);

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Synchroniser avec le backend
  Future<List<Favorite>> syncWithBackend();

  /// Vérifier si les favoris sont synchronisés
  Future<bool> isFavoritesSynced();

  // ============================================
  // ANNUALISATION (Undo)
  // ============================================

  /// Sauvegarder le snapshot des favoris
  Future<void> saveFavoritesSnapshot();

  /// Restaurer le snapshot des favoris
  Future<List<Favorite>> restoreFavoritesSnapshot();

  /// Effacer le snapshot
  Future<void> clearFavoritesSnapshot();
}