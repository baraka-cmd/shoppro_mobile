// Provider du panier
// Gère l'état du panier et les actions

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

  CartStatus _status = CartStatus.initial;
  Cart _cart = const Cart();
  String? _errorMessage;

  // Getters
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

  /// Ajouter un article
  Future<bool> addItem(CartItem item) async {
    _setStatus(CartStatus.updating);
    _clearError();

    try {
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

  /// Supprimer un article
  Future<bool> removeItem(int itemId) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.removeItem(itemId);
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

  /// Mettre à jour la quantité
  Future<bool> updateQuantity(int itemId, int quantity) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.updateQuantity(itemId, quantity);
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

  /// Incrémenter
  Future<bool> incrementQuantity(int itemId) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.incrementQuantity(itemId);
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

  /// Décrémenter
  Future<bool> decrementQuantity(int itemId) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.decrementQuantity(itemId);
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

  /// Vider le panier
  Future<void> clearCart() async {
    await _cartRepository.clearCart();
    _cart = const Cart();
    notifyListeners();
  }

  /// Sauvegarder pour plus tard
  Future<bool> saveForLater(int itemId) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.saveForLater(itemId);
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

  /// Déplacer vers le panier
  Future<bool> moveToCart(int itemId) async {
    _setStatus(CartStatus.updating);

    try {
      _cart = await _cartRepository.moveToCart(itemId);
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

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(CartStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}