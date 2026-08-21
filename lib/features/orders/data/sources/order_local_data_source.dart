// Source de données locale des commandes
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

class OrderLocalDataSource {
  static final OrderLocalDataSource _instance = OrderLocalDataSource._internal();
  factory OrderLocalDataSource() => _instance;
  OrderLocalDataSource._internal();

  static const String _ordersKey = 'orders_data';

  /// Sauvegarder les commandes
  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = jsonEncode(
      orders.map((o) => o.toJson()).toList(),
    );
    await prefs.setString(_ordersKey, ordersJson);
  }

  /// Récupérer les commandes
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey);

    if (ordersJson == null || ordersJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(ordersJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Effacer toutes les commandes
  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
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
}