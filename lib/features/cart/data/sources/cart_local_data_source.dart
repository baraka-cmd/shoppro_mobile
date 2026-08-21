// Source de données locale du panier
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_model.dart';
import '../../domain/entities/cart.dart';

class CartLocalDataSource {
  static final CartLocalDataSource _instance = CartLocalDataSource._internal();
  factory CartLocalDataSource() => _instance;
  CartLocalDataSource._internal();

  static const String _cartKey = 'cart_data';
  static const String _abandonedCartKey = 'abandoned_cart_data';

  /// Sauvegarder le panier
  Future<void> saveCart(Cart cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart.toJson());
    await prefs.setString(_cartKey, cartJson);
  }

  /// Récupérer le panier
  Future<Cart?> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson == null || cartJson.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> map = jsonDecode(cartJson);
      return CartModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Effacer le panier
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  /// Vérifier si le panier est vide
  Future<bool> isCartEmpty() async {
    final cart = await getCart();
    return cart == null || cart.isEmpty;
  }

  /// Récupérer le nombre d'articles
  Future<int> getCartCount() async {
    final cart = await getCart();
    return cart?.totalQuantity ?? 0;
  }

  /// Sauvegarder le panier abandonné
  Future<void> saveAbandonedCart(Cart cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart.toJson());
    await prefs.setString(_abandonedCartKey, cartJson);
  }

  /// Récupérer le panier abandonné
  Future<Cart?> getAbandonedCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_abandonedCartKey);

    if (cartJson == null || cartJson.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> map = jsonDecode(cartJson);
      return CartModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Effacer le panier abandonné
  Future<void> clearAbandonedCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_abandonedCartKey);
  }

  /// Sauvegarder le panier actuel comme abandonné
  Future<void> markAsAbandoned() async {
    final cart = await getCart();
    if (cart != null && !cart.isEmpty) {
      await saveAbandonedCart(cart);
      await clearCart();
    }
  }

  /// Restaurer le panier abandonné
  Future<Cart?> restoreAbandonedCart() async {
    final abandonedCart = await getAbandonedCart();
    if (abandonedCart != null) {
      await saveCart(abandonedCart);
      await clearAbandonedCart();
      return abandonedCart;
    }
    return null;
  }
}