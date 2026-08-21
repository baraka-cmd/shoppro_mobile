// Interface du repository du panier
// Définit le contrat que le repository doit respecter

import '../entities/cart.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  /// Récupérer le panier depuis le stockage local
  Future<Cart> getCart();

  /// Ajouter un article au panier
  Future<Cart> addItem(CartItem item);

  /// Supprimer un article du panier
  Future<Cart> removeItem(int itemId);

  /// Mettre à jour la quantité d'un article
  Future<Cart> updateQuantity(int itemId, int quantity);

  /// Incrémenter la quantité
  Future<Cart> incrementQuantity(int itemId);

  /// Décrémenter la quantité
  Future<Cart> decrementQuantity(int itemId);

  /// Vider le panier
  Future<void> clearCart();

  /// Sauvegarder pour plus tard
  Future<Cart> saveForLater(int itemId);

  /// Déplacer vers le panier
  Future<Cart> moveToCart(int itemId);

  /// Appliquer un code promo
  Future<Cart> applyCoupon(String code);

  /// Retirer le code promo
  Future<Cart> removeCoupon();

  /// Vérifier si le panier est vide
  Future<bool> isCartEmpty();

  /// Récupérer le nombre total d'articles
  Future<int> getCartCount();

  /// Sauvegarder le panier localement
  Future<void> saveCart(Cart cart);

  /// Synchroniser avec le backend (si connecté)
  Future<Cart> syncWithBackend();

  /// Récupérer le panier abandonné (si existe)
  Future<Cart?> getAbandonedCart();

  /// Effacer le panier abandonné
  Future<void> clearAbandonedCart();
}