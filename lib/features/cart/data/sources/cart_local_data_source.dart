// ============================================
// SOURCE DE DONNÉES LOCALE DU PANIER - PREMIUM
// ============================================
// Gère la sauvegarde et la récupération dans
// SharedPreferences avec snapshot et synchronisation.
// ============================================

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/cart_model.dart';
import '../../domain/entities/cart.dart';

class CartLocalDataSource {
  static final CartLocalDataSource _instance = CartLocalDataSource._internal();
  factory CartLocalDataSource() => _instance;
  CartLocalDataSource._internal();

  static const String _cartKey = 'cart_data';
  static const String _abandonedCartKey = 'abandoned_cart_data';
  static const String _cartSnapshotKey = 'cart_snapshot_data';

  // ============================================
  // PANIER PRINCIPAL
  // ============================================

  /// Sauvegarder le panier
  Future<void> saveCart(Cart cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cart.toJson());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      debugPrint('❌ Erreur saveCart: $e');
    }
  }

  /// Récupérer le panier
  Future<Cart?> getCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null || cartJson.isEmpty) {
        return null;
      }

      final Map<String, dynamic> map = jsonDecode(cartJson);
      return CartModel.fromJson(map);
    } catch (e) {
      debugPrint('❌ Erreur getCart: $e');
      return null;
    }
  }

  /// Effacer le panier
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      debugPrint('❌ Erreur clearCart: $e');
    }
  }

  /// Vérifier si le panier est vide
  Future<bool> isCartEmpty() async {
    final cart = await getCart();
    return cart == null || cart.isEmpty;
  }

  /// Récupérer le nombre d'articles (quantités)
  Future<int> getCartCount() async {
    final cart = await getCart();
    return cart?.totalQuantity ?? 0;
  }

  // ============================================
  // PANIER ABANDONNÉ
  // ============================================

  /// Sauvegarder le panier abandonné
  Future<void> saveAbandonedCart(Cart cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(cart.toJson());
      await prefs.setString(_abandonedCartKey, cartJson);
    } catch (e) {
      debugPrint('❌ Erreur saveAbandonedCart: $e');
    }
  }

  /// Récupérer le panier abandonné
  Future<Cart?> getAbandonedCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_abandonedCartKey);

      if (cartJson == null || cartJson.isEmpty) {
        return null;
      }

      final Map<String, dynamic> map = jsonDecode(cartJson);
      return CartModel.fromJson(map);
    } catch (e) {
      debugPrint('❌ Erreur getAbandonedCart: $e');
      return null;
    }
  }

  /// Effacer le panier abandonné
  Future<void> clearAbandonedCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_abandonedCartKey);
    } catch (e) {
      debugPrint('❌ Erreur clearAbandonedCart: $e');
    }
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

  // ============================================
  // SNAPSHOT (ANNULATION)
  // ============================================

  /// Sauvegarder le snapshot du panier
  Future<void> saveCartSnapshot() async {
    try {
      final cart = await getCart();
      if (cart == null) return;

      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = jsonEncode(cart.toJson());
      await prefs.setString(_cartSnapshotKey, snapshotJson);
    } catch (e) {
      debugPrint('❌ Erreur saveCartSnapshot: $e');
    }
  }

  /// Restaurer le snapshot du panier
  Future<Cart?> restoreCartSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = prefs.getString(_cartSnapshotKey);

      if (snapshotJson == null || snapshotJson.isEmpty) {
        return null;
      }

      final Map<String, dynamic> map = jsonDecode(snapshotJson);
      final cart = CartModel.fromJson(map);
      await saveCart(cart);
      await clearCartSnapshot();
      return cart;
    } catch (e) {
      debugPrint('❌ Erreur restoreCartSnapshot: $e');
      return null;
    }
  }

  /// Effacer le snapshot
  Future<void> clearCartSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartSnapshotKey);
    } catch (e) {
      debugPrint('❌ Erreur clearCartSnapshot: $e');
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Effacer toutes les données du panier
  Future<void> clearAll() async {
    await clearCart();
    await clearAbandonedCart();
    await clearCartSnapshot();
  }

  /// Vérifier si un snapshot existe
  Future<bool> hasSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cartSnapshotKey);
    } catch (e) {
      return false;
    }
  }
}