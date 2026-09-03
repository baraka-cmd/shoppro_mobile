// ============================================
// SOURCE DE DONNÉES LOCALE DES ADRESSES - PREMIUM
// ============================================
// Gère la sauvegarde et la récupération dans
// SharedPreferences avec snapshot et gestion d'erreurs.
// ============================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/address.dart';
import '../models/address_model.dart';

class AddressLocalDataSource {
  static final AddressLocalDataSource _instance = AddressLocalDataSource._internal();
  factory AddressLocalDataSource() => _instance;
  AddressLocalDataSource._internal();

  static const String _addressesKey = 'addresses_data';
  static const String _addressesSnapshotKey = 'addresses_snapshot_data';

  // ============================================
  // ADRESSES PRINCIPALES
  // ============================================

  /// Sauvegarder les adresses
  Future<void> saveAddresses(List<Address> addresses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(
        addresses.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_addressesKey, addressesJson);
    } catch (e) {
      debugPrint('❌ Erreur saveAddresses: $e');
    }
  }

  /// Récupérer les adresses
  Future<List<Address>> getAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_addressesKey);

      if (addressesJson == null || addressesJson.isEmpty) {
        return [];
      }

      final List<dynamic> data = jsonDecode(addressesJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => AddressModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Erreur getAddresses: $e');
      return [];
    }
  }

  /// Effacer toutes les adresses
  Future<void> clearAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_addressesKey);
    } catch (e) {
      debugPrint('❌ Erreur clearAddresses: $e');
    }
  }

  /// Récupérer le nombre d'adresses
  Future<int> getAddressesCount() async {
    final addresses = await getAddresses();
    return addresses.length;
  }

  /// Vérifier si des adresses existent
  Future<bool> hasAddresses() async {
    final addresses = await getAddresses();
    return addresses.isNotEmpty;
  }

  // ============================================
  // SNAPSHOT (ANNULATION)
  // ============================================

  /// Sauvegarder le snapshot des adresses
  Future<void> saveAddressesSnapshot() async {
    try {
      final addresses = await getAddresses();
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = jsonEncode(
        addresses.map((a) => a.toJson()).toList(),
      );
      await prefs.setString(_addressesSnapshotKey, snapshotJson);
    } catch (e) {
      debugPrint('❌ Erreur saveAddressesSnapshot: $e');
    }
  }

  /// Restaurer le snapshot des adresses
  Future<List<Address>?> restoreAddressesSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapshotJson = prefs.getString(_addressesSnapshotKey);

      if (snapshotJson == null || snapshotJson.isEmpty) {
        return null;
      }

      final List<dynamic> data = jsonDecode(snapshotJson);
      final addresses = data
          .whereType<Map<String, dynamic>>()
          .map((json) => AddressModel.fromJson(json))
          .toList();

      await saveAddresses(addresses);
      await clearAddressesSnapshot();
      return addresses;
    } catch (e) {
      debugPrint('❌ Erreur restoreAddressesSnapshot: $e');
      return null;
    }
  }

  /// Effacer le snapshot
  Future<void> clearAddressesSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_addressesSnapshotKey);
    } catch (e) {
      debugPrint('❌ Erreur clearAddressesSnapshot: $e');
    }
  }

  // ============================================
  // UTILITAIRES
  // ============================================

  /// Effacer toutes les données des adresses
  Future<void> clearAll() async {
    await clearAddresses();
    await clearAddressesSnapshot();
  }

  /// Vérifier si un snapshot existe
  Future<bool> hasSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_addressesSnapshotKey);
    } catch (e) {
      return false;
    }
  }
}