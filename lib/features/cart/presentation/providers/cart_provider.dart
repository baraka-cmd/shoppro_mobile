// ============================================
// PROVIDER DU PANIER - VERSION PREMIUM
// ============================================
// Gère l'état du panier avec actions complètes,
// snapshot pour annulation et synchronisation.
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/repositories/cart_repository_impl.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartProvider({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  CartStatus _status = CartStatus.initial;
  Cart _cart = const Cart();
  String? _errorMessage;
  int _updatingItemId = -1;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  CartStatus get status => _status;
  Cart get cart => _cart;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CartStatus.loading;
  bool get isUpdating => _status == CartStatus.updating;
  bool get hasError => _status == CartStatus.error;
  bool get isEmpty => _cart.isEmpty;
  int get totalQuantity => _cart.totalQuantity;
  int get totalItems => _cart.totalItems;
  double get subtotal => _cart.subtotal;
  double get total => _cart.total;

  /// ID de l'article en cours de mise à jour
  int get updatingItemId => _updatingItemId;

  /// Le panier a-t-il un code promo ?
  bool get hasCoupon => _cart.hasCoupon;

  /// La livraison gratuite est-elle activée ?
  bool get hasFreeShipping => _cart.hasFreeShipping;

  /// Progression livraison gratuite (0-100)
  int get freeShippingPercentage => _cart.freeShippingPercentage;

  /// Montant restant pour livraison gratuite
  String get formattedRemainingForFreeShipping =>
      _cart.formattedRemainingForFreeShipping;

  /// Articles actifs
  List<CartItem> get activeItems => _cart.activeItems;

  /// Articles sauvegardés
  List<CartItem> get savedForLaterItems => _cart.savedForLaterItems;

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger le panier
  Future<void> loadCart() async {
    _setStatus(CartStatus.loading);
    _clearError();

    try {
      _cart = await _cartRepository.getCart();
      _setStatus(CartStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(CartStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir le panier
  Future<void> refreshCart() async {
    await loadCart();
  }

  // ============================================
  // AJOUT
  // ============================================

  /// Ajouter un article
  Future<bool> addItem(CartItem item) async {
    _setStatus(CartStatus.updating);
    _clearError();

    try {
      await _cartRepository.saveCartSnapshot();
      _cart = await _cartRepository.addItem(item);
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Ajouter plusieurs articles
  Future<bool> addItems(List<CartItem> items) async {
    _setStatus(CartStatus.updating);
    _clearError();

    try {
      await _cartRepository.saveCartSnapshot();
      _cart = await _cartRepository.addItems(items);
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer un article
  Future<bool> removeItem(int itemId) async {
    _setStatus(CartStatus.updating);
    _updatingItemId = itemId;

    try {
      await _cartRepository.saveCartSnapshot();
      _cart = await _cartRepository.removeItem(itemId);
      _updatingItemId = -1;
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingItemId = -1;
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Supprimer plusieurs articles
  Future<bool> removeItems(List<int> itemIds) async {
    _setStatus(CartStatus.updating);

    try {
      await _cartRepository.saveCartSnapshot();
      _cart = await _cartRepository.removeItems(itemIds);
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // QUANTITÉ
  // ============================================

  /// Mettre à jour la quantité
  Future<bool> updateQuantity(int itemId, int quantity) async {
    _setStatus(CartStatus.updating);
    _updatingItemId = itemId;

    try {
      _cart = await _cartRepository.updateQuantity(itemId, quantity);
      _updatingItemId = -1;
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingItemId = -1;
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Incrémenter
  Future<bool> incrementQuantity(int itemId) async {
    _updatingItemId = itemId;

    try {
      _cart = await _cartRepository.incrementQuantity(itemId);
      _updatingItemId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingItemId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Décrémenter
  Future<bool> decrementQuantity(int itemId) async {
    _updatingItemId = itemId;

    try {
      _cart = await _cartRepository.decrementQuantity(itemId);
      _updatingItemId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingItemId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // VIDER
  // ============================================

  /// Vider le panier
  Future<void> clearCart() async {
    await _cartRepository.clearCart();
    _cart = const Cart();
    notifyListeners();
  }

  // ============================================
  // SAUVEGARDER POUR PLUS TARD
  // ============================================

  /// Sauvegarder pour plus tard
  Future<bool> saveForLater(int itemId) async {
    _updatingItemId = itemId;

    try {
      _cart = await _cartRepository.saveForLater(itemId);
      _updatingItemId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingItemId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Déplacer vers le panier
  Future<bool> moveToCart(int itemId) async {
    _updatingItemId = itemId;

    try {
      _cart = await _cartRepository.moveToCart(itemId);
      _updatingItemId = -1;
      notifyListeners();
      return true;
    } catch (e) {
      _updatingItemId = -1;
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // CODE PROMO
  // ============================================

  /// Appliquer un code promo
  Future<bool> applyCoupon(String code) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.applyCoupon(code);
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Retirer le code promo
  Future<bool> removeCoupon() async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.removeCoupon();
      _setStatus(CartStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(CartStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Annuler la dernière action (restaurer le snapshot)
  Future<bool> undoLastAction() async {
    try {
      final restoredCart = await _cartRepository.restoreCartSnapshot();
      if (restoredCart != null) {
        _cart = restoredCart;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  /// Restaurer le panier abandonné
  Future<void> restoreAbandonedCart() async {
    final abandonedCart = await _cartRepository.getAbandonedCart();
    if (abandonedCart != null && !abandonedCart.isEmpty) {
      _cart = abandonedCart;
      await _cartRepository.saveCart(_cart);
      await _cartRepository.clearAbandonedCart();
      notifyListeners();
    }
  }

  /// Synchroniser avec le backend
  Future<void> syncCart() async {
    _cart = await _cartRepository.syncWithBackend();
    notifyListeners();
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(CartStatus newStatus) {
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
    return 'CartProvider(status: $_status, items: $totalItems, '
        'quantity: $totalQuantity, subtotal: $subtotal, total: $total, '
        'coupon: ${_cart.couponCode})';
  }
}