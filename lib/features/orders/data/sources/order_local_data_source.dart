// ============================================
// SOURCE DE DONNÉES LOCALE DES COMMANDES - PREMIUM
// ============================================
// Gère la sauvegarde et la récupération dans
// SharedPreferences avec snapshot et gestion d'erreurs.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

class OrderLocalDataSource {
  static final OrderLocalDataSource _instance = OrderLocalDataSource._internal();
  factory OrderLocalDataSource() => _instance;
  OrderLocalDataSource._internal();

  static const String _ordersKey = 'orders_data';
  static const String _ordersSnapshotKey = 'orders_snapshot_data';

  // ============================================
  // COMMANDES PRINCIPALES
  // ============================================

  /// Sauvegarder les commandes
  Future<void> saveOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(
        orders.map((o) => o.toJson()).toList(),
      );
      await prefs.setString(_ordersKey, ordersJson);
    } catch (e) {
      debugPrint('❌ Erreur saveOrders: $e');
    }
  }

  /// Récupérer les commandes
  Future<List<Order>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);

      if (ordersJson == null || ordersJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(ordersJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getOrders: $e');
      return [];
    }
  }

  /// Effacer toutes les commandes
  Future<void> clearOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
    } catch (e) {
      debugPrint('❌ Erreur clearOrders: $e');
    }
  }

  /// Récupérer le nombre de commandes
  Future<int> getOrdersCount() async {
    final orders = await getOrders();
    return orders.length;
  }

  /// Vérifier si des commandes existent
  Future<bool> hasOrders() async {
    final orders = await getOrders();
    return orders.isNotEmpty;
  }

  // ============================================
  // SNAPSHOT (ANNULATION)
  // ============================================

  /// Sauvegarder le snapshot des commandes
  Future<void> saveOrdersSnapshot() async {
    try {
      final orders = await getOrders();
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = jsonEncode(
        orders.map((o) => o.toJson()).toList(),
      );
      await prefs.setString(_ordersSnapshotKey, snapshotJson);
    } catch (e) {
      debugPrint('❌ Erreur saveOrdersSnapshot: $e');
    }
  }

  /// Restaurer le snapshot des commandes
  Future<List<Order>?> restoreOrdersSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = prefs.getString(_ordersSnapshotKey);

      if (snapshotJson == null || snapshotJson.isEmpty) {
        return null;
      }

      final List<dynamic> data = jsonDecode(snapshotJson);
      final orders = data
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderModel.fromJson(json))
          .toList();

      await saveOrders(orders);
      await clearOrdersSnapshot();
      return orders;
    } catch (e) {
      debugPrint('❌ Erreur restoreOrdersSnapshot: $e');
      return null;
    }
  }

  /// Effacer le snapshot
  Future<void> clearOrdersSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersSnapshotKey);
    } catch (e) {
      debugPrint('❌ Erreur clearOrdersSnapshot: $e');
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Effacer toutes les données des commandes
  Future<void> clearAll() async {
    await clearOrders();
    await clearOrdersSnapshot();
  }

  /// Vérifier si un snapshot existe
  Future<bool> hasSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_ordersSnapshotKey);
    } catch (e) {
      return false;
    }
  }
}