// Implémentation du repository du panier
// Gère la logique métier du panier avec stockage local

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

  @override
  Future<Cart> getCart() async {
    final cart = await _localDataSource.getCart();
    return cart ?? const Cart();
  }

  @override
  Future<Cart> addItem(CartItem item) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    // Vérifier si l'article existe déjà
    final existingIndex = items.indexWhere(
      (existing) =>
          existing.productId == item.productId &&
          existing.variantColor == item.variantColor &&
          existing.variantSize == item.variantSize,
    );

    if (existingIndex >= 0) {
      // Incrémenter la quantité
      final existingItem = items[existingIndex];
      final newQuantity = existingItem.quantity + item.quantity;

      if (newQuantity <= existingItem.maxQuantity &&
          newQuantity <= existingItem.stock) {
        items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      }
    } else {
      // Ajouter le nouvel article
      items.add(item);
    }

    final newCart = currentCart.copyWith(items: items);
    await _localDataSource.saveCart(newCart);
    return newCart;
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
  Future<Cart> updateQuantity(int itemId, int quantity) async {
    final currentCart = await getCart();
    final items = [...currentCart.items];

    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      final item = items[index];
      final newQuantity = quantity.clamp(1, item.stock > 0 ? item.stock : item.maxQuantity);
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
  Future<Cart> applyCoupon(String code) async {
    final currentCart = await getCart();

    // Simuler des codes promo
    double discount = 0;
    final normalizedCode = code.toUpperCase().trim();

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
  Future<bool> isCartEmpty() async {
    return await _localDataSource.isCartEmpty();
  }

  @override
  Future<int> getCartCount() async {
    return await _localDataSource.getCartCount();
  }

  @override
  Future<void> saveCart(Cart cart) async {
    await _localDataSource.saveCart(cart);
  }

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
}