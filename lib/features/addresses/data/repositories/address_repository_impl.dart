// ============================================
// IMPLÉMENTATION DU REPOSITORY DES ADRESSES - PREMIUM
// ============================================
// Source principale : API Laravel
// Source secondaire : cache local (fallback offline)
// Gère : lecture, création, modification,
//        suppression, défaut, snapshot
// ============================================

import 'package:flutter/foundation.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../sources/address_api.dart';
import '../sources/address_local_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressApi _api;
  final AddressLocalDataSource _localDataSource;

  AddressRepositoryImpl({
    AddressApi? api,
    AddressLocalDataSource? localDataSource,
  })  : _api = api ?? AddressApi(),
        _localDataSource = localDataSource ?? AddressLocalDataSource();

  // ============================================
  // LECTURE (API + fallback local)
  // ============================================

  @override
  Future<List<Address>> getAddresses() async {
    try {
      // 1. Récupérer depuis l'API
      final addresses = await _api.getAddresses();

      // 2. Mettre à jour le cache local
      await _localDataSource.saveAddresses(addresses);

      // 3. Trier : défaut en premier, puis plus récent
      addresses.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      return addresses;
    } catch (e) {
      debugPrint('⚠️ API getAddresses échouée, fallback cache local: $e');

      // Fallback : cache local
      final cached = await _localDataSource.getAddresses();
      cached.sort((a, b) {
        if (a.isDefault != b.isDefault) {
          return a.isDefault ? -1 : 1;
        }
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
      return cached;
    }
  }

  @override
  Future<List<Address>> getActiveAddresses() async {
    final addresses = await getAddresses();
    return addresses.where((a) => a.isActive).toList();
  }

  @override
  Future<Address?> getAddressById(int addressId) async {
    try {
      return await _api.getAddressById(addressId);
    } catch (e) {
      debugPrint('⚠️ API getAddressById échouée, fallback local: $e');

      final addresses = await _localDataSource.getAddresses();
      for (final address in addresses) {
        if (address.id == addressId) return address;
      }
      return null;
    }
  }

  @override
  Future<Address?> getDefaultAddress() async {
    final addresses = await getAddresses();
    for (final address in addresses) {
      if (address.isDefault && address.isActive) {
        return address;
      }
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  @override
  Future<List<Address>> getAddressesByType(String type) async {
    final addresses = await getAddresses();
    return addresses.where((a) => a.type == type).toList();
  }

  @override
  Future<int> getAddressesCount() async {
    final addresses = await getAddresses();
    return addresses.length;
  }

  @override
  Future<bool> hasAddresses() async {
    final addresses = await getAddresses();
    return addresses.isNotEmpty;
  }

  // ============================================
  // CRÉATION (API)
  // ============================================

  @override
  Future<Address> createAddress({
    required String fullName,
    required String phone,
    String? email,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? state,
    String? postalCode,
    String? country,
    String type = 'home',
    bool isDefault = false,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
  }) async {
    try {
      // 1. Créer côté serveur
      final address = await _api.createAddress(
        fullName: fullName,
        phone: phone,
        email: email,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        type: type,
        isDefault: isDefault,
        latitude: latitude,
        longitude: longitude,
        deliveryInstructions: deliveryInstructions,
      );

      // 2. Ajouter au cache local
      final cached = await _localDataSource.getAddresses();
      cached.add(address);
      await _localDataSource.saveAddresses(cached);

      debugPrint('✅ Adresse créée côté serveur : ${address.id}');
      return address;
    } catch (e) {
      debugPrint('❌ Erreur createAddress: $e');
      rethrow;
    }
  }

  // ============================================
  // MODIFICATION (API)
  // ============================================

  @override
  Future<Address> updateAddress({
    required int id,
    String? fullName,
    String? phone,
    String? email,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? type,
    bool? isDefault,
    double? latitude,
    double? longitude,
    String? deliveryInstructions,
  }) async {
    try {
      // 1. Mettre à jour côté serveur
      final address = await _api.updateAddress(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        type: type,
        isDefault: isDefault,
        latitude: latitude,
        longitude: longitude,
        deliveryInstructions: deliveryInstructions,
      );

      // 2. Mettre à jour le cache local
      final cached = await _localDataSource.getAddresses();
      final index = cached.indexWhere((a) => a.id == id);
      if (index >= 0) {
        cached[index] = address;
        await _localDataSource.saveAddresses(cached);
      }

      debugPrint('✅ Adresse mise à jour : ${address.id}');
      return address;
    } catch (e) {
      debugPrint('❌ Erreur updateAddress: $e');
      rethrow;
    }
  }

  @override
  Future<Address> setDefaultAddress(int addressId) async {
    try {
      // 1. Définir par défaut côté serveur
      final address = await _api.setDefaultAddress(addressId);

      // 2. Mettre à jour le cache local
      final cached = await _localDataSource.getAddresses();
      for (int i = 0; i < cached.length; i++) {
        cached[i] = cached[i].copyWith(
          isDefault: cached[i].id == addressId,
        );
      }
      await _localDataSource.saveAddresses(cached);

      debugPrint('✅ Adresse par défaut mise à jour : ${address.id}');
      return address;
    } catch (e) {
      debugPrint('❌ Erreur setDefaultAddress: $e');
      rethrow;
    }
  }

  @override
  Future<List<Address>> toggleAddressActive(int addressId) async {
    // Local uniquement (l'API n'a pas d'endpoint toggle)
    final addresses = await getAddresses();
    final index = addresses.indexWhere((a) => a.id == addressId);

    if (index >= 0) {
      addresses[index] = addresses[index].copyWith(
        isActive: !addresses[index].isActive,
      );
      await _localDataSource.saveAddresses(addresses);
    }

    return addresses;
  }

  // ============================================
  // SUPPRESSION (API)
  // ============================================

  @override
  Future<void> deleteAddress(int addressId) async {
    try {
      // 1. Supprimer côté serveur
      await _api.deleteAddress(addressId);

      // 2. Retirer du cache local
      final cached = await _localDataSource.getAddresses();
      cached.removeWhere((a) => a.id == addressId);
      await _localDataSource.saveAddresses(cached);

      debugPrint('✅ Adresse supprimée : $addressId');
    } catch (e) {
      debugPrint('❌ Erreur deleteAddress: $e');
      rethrow;
    }
  }

  @override
  Future<List<Address>> removeAddresses(List<int> addressIds) async {
    // Local uniquement (batch delete non supporté par l'API pour l'instant)
    final addresses = await getAddresses();
    addresses.removeWhere((a) => addressIds.contains(a.id));
    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  @override
  Future<void> clearAddresses() async {
    await _localDataSource.clearAddresses();
  }

  // ============================================
  // SAUVEGARDE (CACHE LOCAL)
  // ============================================

  @override
  Future<void> saveAddresses(List<Address> addresses) async {
    await _localDataSource.saveAddresses(addresses);
  }

  @override
  Future<List<Address>> syncWithBackend() async {
    try {
      final addresses = await _api.getAddresses();
      await _localDataSource.saveAddresses(addresses);
      debugPrint('✅ Synchronisation réussie : ${addresses.length} adresses');
      return addresses;
    } catch (e) {
      debugPrint('❌ Erreur syncWithBackend: $e');
      return await _localDataSource.getAddresses();
    }
  }

  @override
  Future<bool> isAddressesSynced() async {
    try {
      final cached = await _localDataSource.getAddresses();
      return cached.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  @override
  Future<void> saveAddressesSnapshot() async {
    await _localDataSource.saveAddressesSnapshot();
  }

  @override
  Future<List<Address>> restoreAddressesSnapshot() async {
    return await _localDataSource.restoreAddressesSnapshot() ?? [];
  }

  @override
  Future<void> clearAddressesSnapshot() async {
    await _localDataSource.clearAddressesSnapshot();
  }
}