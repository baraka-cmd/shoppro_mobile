// ============================================
// INTERFACE DU REPOSITORY DU PANIER - PREMIUM
// ============================================
// Définit le contrat que le repository doit
// respecter. Gestion complète du panier local
// avec synchronisation et panier abandonné.
// ============================================

import '../entities/cart.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  // ============================================
  // LECTURE
  // ============================================

  /// Récupérer le panier depuis le stockage local
  Future<Cart> getCart();

  /// Vérifier si le panier est vide
  Future<bool> isCartEmpty();

  /// Récupérer le nombre total d'articles
  Future<int> getCartCount();

  /// Récupérer le nombre total d'articles (quantités)
  Future<int> getCartQuantity();

  /// Récupérer le sous-total du panier
  Future<double> getCartSubtotal();

  /// Récupérer le total final du panier
  Future<double> getCartTotal();

  // ============================================
  // MODIFICATION
  // ============================================

  /// Ajouter un article au panier
  Future<Cart> addItem(CartItem item);

  /// Ajouter plusieurs articles au panier
  Future<Cart> addItems(List<CartItem> items);

  /// Supprimer un article du panier
  Future<Cart> removeItem(int itemId);

  /// Supprimer plusieurs articles
  Future<Cart> removeItems(List<int> itemIds);

  /// Mettre à jour la quantité d'un article
  Future<Cart> updateQuantity(int itemId, int quantity);

  /// Incrémenter la quantité
  Future<Cart> incrementQuantity(int itemId);

  /// Décrémenter la quantité
  Future<Cart> decrementQuantity(int itemId);

  /// Vider le panier
  Future<void> clearCart();

  /// Sauvegarder le panier localement
  Future<void> saveCart(Cart cart);

  // ============================================
  // SAUVEGARDER POUR PLUS TARD
  // ============================================

  /// Sauvegarder pour plus tard
  Future<Cart> saveForLater(int itemId);

  /// Déplacer vers le panier
  Future<Cart> moveToCart(int itemId);

  /// Sauvegarder plusieurs articles pour plus tard
  Future<Cart> saveMultipleForLater(List<int> itemIds);

  /// Déplacer plusieurs articles vers le panier
  Future<Cart> moveMultipleToCart(List<int> itemIds);

  // ============================================
  // CODE PROMO
  // ============================================

  /// Appliquer un code promo
  Future<Cart> applyCoupon(String code);

  /// Retirer le code promo
  Future<Cart> removeCoupon();

  /// Vérifier si un code promo est valide
  Future<bool> validateCoupon(String code);

  /// Récupérer les codes promo disponibles
  Future<List<String>> getAvailableCoupons();

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Synchroniser avec le backend (si connecté)
  Future<Cart> syncWithBackend();

  /// Récupérer le panier abandonné (si existe)
  Future<Cart?> getAbandonedCart();

  /// Effacer le panier abandonné
  Future<void> clearAbandonedCart();

  /// Restaurer le panier abandonné
  Future<Cart> restoreAbandonedCart();

  /// Vérifier si le panier est synchronisé
  Future<bool> isCartSynced();

  // ============================================
  // ANNUALISATION (Undo)
  // ============================================

  /// Sauvegarder l'état du panier pour annulation
  Future<void> saveCartSnapshot();

  /// Restaurer le dernier état sauvegardé
  Future<Cart> restoreCartSnapshot();

  /// Effacer le snapshot
  Future<void> clearCartSnapshot();
}