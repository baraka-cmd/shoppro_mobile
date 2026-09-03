// ============================================
// SOURCE DE DONNÉES LOCALE DES PAIEMENTS - PREMIUM
// ============================================
// Gère la sauvegarde et la récupération dans
// SharedPreferences avec snapshot et gestion d'erreurs.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

class PaymentLocalDataSource {
  static final PaymentLocalDataSource _instance = PaymentLocalDataSource._internal();
  factory PaymentLocalDataSource() => _instance;
  PaymentLocalDataSource._internal();

  static const String _paymentsKey = 'payments_data';
  static const String _paymentsSnapshotKey = 'payments_snapshot_data';

  // ============================================
  // PAIEMENTS PRINCIPAUX
  // ============================================

  /// Sauvegarder les paiements
  Future<void> savePayments(List<Payment> payments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = jsonEncode(
        payments.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_paymentsKey, paymentsJson);
    } catch (e) {
      debugPrint('❌ Erreur savePayments: $e');
    }
  }

  /// Récupérer les paiements
  Future<List<Payment>> getPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentsJson = prefs.getString(_paymentsKey);

      if (paymentsJson == null || paymentsJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(paymentsJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getPayments: $e');
      return [];
    }
  }

  /// Effacer tous les paiements
  Future<void> clearPayments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_paymentsKey);
    } catch (e) {
      debugPrint('❌ Erreur clearPayments: $e');
    }
  }

  /// Récupérer le nombre de paiements
  Future<int> getPaymentsCount() async {
    final payments = await getPayments();
    return payments.length;
  }

  // ============================================
  // SNAPSHOT (ANNULATION)
  // ============================================

  /// Sauvegarder le snapshot des paiements
  Future<void> savePaymentsSnapshot() async {
    try {
      final payments = await getPayments();
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = jsonEncode(
        payments.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_paymentsSnapshotKey, snapshotJson);
    } catch (e) {
      debugPrint('❌ Erreur savePaymentsSnapshot: $e');
    }
  }

  /// Restaurer le snapshot des paiements
  Future<List<Payment>?> restorePaymentsSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = prefs.getString(_paymentsSnapshotKey);

      if (snapshotJson == null || snapshotJson.isEmpty) {
        return null;
      }

      final List<dynamic> data = jsonDecode(snapshotJson);
      final payments = data
          .whereType<Map<String, dynamic>>()
          .map((json) => PaymentModel.fromJson(json))
          .toList();

      await savePayments(payments);
      await clearPaymentsSnapshot();
      return payments;
    } catch (e) {
      debugPrint('❌ Erreur restorePaymentsSnapshot: $e');
      return null;
    }
  }

  /// Effacer le snapshot
  Future<void> clearPaymentsSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_paymentsSnapshotKey);
    } catch (e) {
      debugPrint('❌ Erreur clearPaymentsSnapshot: $e');
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Effacer toutes les données des paiements
  Future<void> clearAll() async {
    await clearPayments();
    await clearPaymentsSnapshot();
  }

  /// Vérifier si un snapshot existe
  Future<bool> hasSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_paymentsSnapshotKey);
    } catch (e) {
      return false;
    }
  }
}