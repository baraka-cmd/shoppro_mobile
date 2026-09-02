// ============================================
// IMPLÉMENTATION DU REPOSITORY DU PANIER - PREMIUM
// ============================================
// Gère la logique métier du panier avec stockage
// local, codes promo et sauvegarde pour plus tard.
// ============================================

import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';
import '../sources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;

  CartRepositoryImpl({CartLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? CartLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<Cart> getCart() async {
    final cart = await _localDataSource.getCart();
    return cart ?? const Cart();
  }

  @override
  Future<bool> isCartEmpty() async {
    return await _localDataSource.isCartEmpty();
  }

  @override
  Future<int> getCartCount() async {
    return await _localDataSource.getCartCount();
  }

  @override
  Future<int> getCartQuantity() async {
    final cart = await getCart();
    return cart.totalQuantity;
  }

  @override
  Future<double> getCartSubtotal() async {
    final cart = await getCart();
    return cart.subtotal;
  }

  @override
  Future<double> getCartTotal() async {
    final cart = await getCart();
    return cart.total;
  }

  // ============================================
  // MODIFICATION
  // ============================================

  @override
  Future<Cart> addItem(CartItem item) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final existingIndex = items.indexWhere(
      (existing) =>
          existing.productId == item.productId &&
          existing.variantColor == item.variantColor &&
          existing.variantSize == item.variantSize,
    );

    if (existingIndex >= 0) {
      final existingItem = items[existingIndex];
      final newQuantity = existingItem.quantity + item.quantity;

      if (newQuantity <= existingItem.maxQuantity &&
          newQuantity <= existingItem.stock) {
        items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        // Limiter au stock disponible
        final maxAllowed = existingItem.stock < existingItem.maxQuantity
            ? existingItem.stock
            : existingItem.maxQuantity;
        items[existingIndex] = existingItem.copyWith(quantity: maxAllowed);
      }
    } else {
      items.add(item);
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> addItems(List<CartItem> items) async {
    var cart = await getCart();
    for (final item in items) {
      cart = await addItem(item);
    }
    return cart;
  }

  @override
  Future<Cart> removeItem(int itemId) async {
    final currentCart = await getCart();
    final items = currentCart.items
        .where((item) => item.id != itemId)
        .toList();

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> removeItems(List<int> itemIds) async {
    final currentCart = await getCart();
    final items = currentCart.items
        .where((item) => !itemIds.contains(item.id))
        .toList();

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> updateQuantity(int itemId, int quantity) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      final item = items[index];
      final maxAllowed = item.stock > 0 && item.stock < item.maxQuantity
          ? item.stock
          : item.maxQuantity;
      final newQuantity = quantity.clamp(1, maxAllowed);
      items[index] = item.copyWith(quantity: newQuantity);
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> incrementQuantity(int itemId) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      final item = items[index];
      if (item.canIncrement) {
        items[index] = item.copyWith(quantity: item.quantity + 1);
      }
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> decrementQuantity(int itemId) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      final item = items[index];
      if (item.canDecrement) {
        items[index] = item.copyWith(quantity: item.quantity - 1);
      }
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<void> clearCart() async {
    await _localDataSource.clearCart();
  }

  @override
  Future<void> saveCart(Cart cart) async {
    await _localDataSource.saveCart(cart);
  }

  // ============================================
  // SAUVEGARDER POUR PLUS TARD
  // ============================================

  @override
  Future<Cart> saveForLater(int itemId) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      items[index] = items[index].copyWith(isSavedForLater: true);
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> moveToCart(int itemId) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      items[index] = items[index].copyWith(isSavedForLater: false);
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> saveMultipleForLater(List<int> itemIds) async {
    var cart = await getCart();
    for (final itemId in itemIds) {
      cart = await saveForLater(itemId);
    }
    return cart;
  }

  @override
  Future<Cart> moveMultipleToCart(List<int> itemIds) async {
    var cart = await getCart();
    for (final itemId in itemIds) {
      cart = await moveToCart(itemId);
    }
    return cart;
  }

  // ============================================
  // CODE PROMO
  // ============================================

  @override
  Future<Cart> applyCoupon(String code) async {
    final currentCart = await getCart();
    final normalizedCode = code.toUpperCase().trim();

    double discount = 0;

    switch (normalizedCode) {
      case 'PROMO10':
        discount = currentCart.subtotal * 0.10;
        break;
      case 'PROMO20':
        discount = currentCart.subtotal * 0.20;
        break;
      case 'LIVRAISON':
        discount = currentCart.shippingFee;
        break;
      case 'FIXE5000':
        discount = 5000;
        break;
      default:
        throw Exception('Code promo invalide');
    }

    // Limiter le discount au sous-total
    if (discount > currentCart.subtotal) {
      discount = currentCart.subtotal;
    }

    final newCart = currentCart.copyWith(
      couponCode: normalizedCode,
      couponDiscount: discount,
    );

    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<Cart> removeCoupon() async {
    final currentCart = await getCart();

    final newCart = currentCart.copyWith(
      couponCode: null,
      couponDiscount: 0,
    );

    await _localDataSource.saveCart(newCart);
    return newCart;
  }

  @override
  Future<bool> validateCoupon(String code) async {
    try {
      await applyCoupon(code);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableCoupons() async {
    return const ['PROMO10', 'PROMO20', 'LIVRAISON', 'FIXE5000'];
  }

  // ============================================
  // SYNCHRONISATION
  // ============================================

  @override
  Future<Cart> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel si connecté
    return await getCart();
  }

  @override
  Future<Cart?> getAbandonedCart() async {
    return await _localDataSource.getAbandonedCart();
  }

  @override
  Future<void> clearAbandonedCart() async {
    await _localDataSource.clearAbandonedCart();
  }

  @override
  Future<Cart> restoreAbandonedCart() async {
    final abandonedCart = await _localDataSource.getAbandonedCart();
    if (abandonedCart != null && !abandonedCart.isEmpty) {
      await _localDataSource.saveCart(abandonedCart);
      await _localDataSource.clearAbandonedCart();
      return abandonedCart;
    }
    return await getCart();
  }

  @override
  Future<bool> isCartSynced() async {
    // Pour l'instant, le panier local est toujours "synced"
    return true;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  @override
  Future<void> saveCartSnapshot() async {
    await _localDataSource.saveCartSnapshot();
  }

  @override
  Future<Cart> restoreCartSnapshot() async {
    return await _localDataSource.restoreCartSnapshot() ?? const Cart();
  }

  @override
  Future<void> clearCartSnapshot() async {
    await _localDataSource.clearCartSnapshot();
  }
}