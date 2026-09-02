// Source de données locale des paiements
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

class PaymentLocalDataSource {
  static final PaymentLocalDataSource _instance = PaymentLocalDataSource._internal();
  factory PaymentLocalDataSource() => _instance;
  PaymentLocalDataSource._internal();

  static const String _paymentsKey = 'payments_data';

  /// Sauvegarder les paiements
  Future<void> savePayments(List<Payment> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final paymentsJson = jsonEncode(
      payments.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_paymentsKey, paymentsJson);
  }

  /// Récupérer les paiements
  Future<List<Payment>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentsJson = prefs.getString(_paymentsKey);

    if (paymentsJson == null || paymentsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(paymentsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Effacer tous les paiements
  Future<void> clearPayments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paymentsKey);
  }

  /// Récupérer le nombre de paiements
  Future<int> getPaymentsCount() async {
    final payments = await getPayments();
    return payments.length;
  }
}