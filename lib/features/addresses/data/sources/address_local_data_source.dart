// Source de données locale des adresses
// Gère la sauvegarde et la récupération dans SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/address.dart';
import '../models/address_model.dart';

class AddressLocalDataSource {
  static final AddressLocalDataSource _instance = AddressLocalDataSource._internal();
  factory AddressLocalDataSource() => _instance;
  AddressLocalDataSource._internal();

  static const String _addressesKey = 'addresses_data';

  /// Sauvegarder les adresses
  Future<void> saveAddresses(List<Address> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = jsonEncode(
      addresses.map((a) => a.toJson()).toList(),
    );
    await prefs.setString(_addressesKey, addressesJson);
  }

  /// Récupérer les adresses
  Future<List<Address>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString(_addressesKey);

    if (addressesJson == null || addressesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(addressesJson);
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => AddressModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Effacer toutes les adresses
  Future<void> clearAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressesKey);
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
}