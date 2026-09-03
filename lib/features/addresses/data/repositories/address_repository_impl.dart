// ============================================
// IMPLÉMENTATION DU REPOSITORY DES ADRESSES - PREMIUM
// ============================================
// Gère la logique métier avec stockage local,
// défaut intelligent et snapshot.
// ============================================

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/address_model.dart';
import '../sources/address_local_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalDataSource _localDataSource;

  AddressRepositoryImpl({AddressLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? AddressLocalDataSource();

  // ============================================
  // LECTURE
  // ============================================

  @override
  Future<List<Address>> getAddresses() async {
    final addresses = await _localDataSource.getAddresses();
    addresses.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      // Trier par date de création (plus récent en premier)
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });
    return addresses;
  }

  @override
  Future<List<Address>> getActiveAddresses() async {
    final addresses = await getAddresses();
    return addresses.where((a) => a.isActive).toList();
  }

  @override
  Future<Address?> getAddressById(int addressId) async {
    final addresses = await getAddresses();
    for (final address in addresses) {
      if (address.id == addressId) {
        return address;
      }
    }
    return null;
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
    return await _localDataSource.getAddressesCount();
  }

  @override
  Future<bool> hasAddresses() async {
    return await _localDataSource.hasAddresses();
  }

  // ============================================
  // CRÉATION
  // ============================================

  @override
  Future<List<Address>> addAddress(Address address) async {
    final addresses = await getAddresses();

    // Si c'est la première adresse, la définir comme défaut
    if (addresses.isEmpty) {
      address = address.copyWith(isDefault: true);
    }

    // Si cette adresse est définie comme défaut, retirer le défaut des autres
    if (address.isDefault) {
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
    }

    addresses.add(address);
    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  @override
  Future<List<Address>> addAddresses(List<Address> newAddresses) async {
    var addresses = await getAddresses();

    for (var address in newAddresses) {
      if (addresses.isEmpty) {
        address = address.copyWith(isDefault: true);
      }
      addresses.add(address);
    }

    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  // ============================================
  // MODIFICATION
  // ============================================

  @override
  Future<List<Address>> updateAddress(Address address) async {
    final addresses = await getAddresses();
    final index = addresses.indexWhere((a) => a.id == address.id);

    if (index >= 0) {
      if (address.isDefault) {
        for (int i = 0; i < addresses.length; i++) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }

      addresses[index] = address;
      await _localDataSource.saveAddresses(addresses);
    }

    return addresses;
  }

  @override
  Future<List<Address>> setDefaultAddress(int addressId) async {
    final addresses = await getAddresses();

    for (int i = 0; i < addresses.length; i++) {
      addresses[i] = addresses[i].copyWith(
        isDefault: addresses[i].id == addressId,
      );
    }

    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  @override
  Future<List<Address>> toggleAddressActive(int addressId) async {
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
  // SUPPRESSION
  // ============================================

  @override
  Future<List<Address>> removeAddress(int addressId) async {
    final addresses = await getAddresses();
    Address? removedAddress;

    for (final address in addresses) {
      if (address.id == addressId) {
        removedAddress = address;
        break;
      }
    }

    addresses.removeWhere((a) => a.id == addressId);

    if (removedAddress != null &&
        removedAddress.isDefault &&
        addresses.isNotEmpty) {
      addresses[0] = addresses[0].copyWith(isDefault: true);
    }

    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  @override
  Future<List<Address>> removeAddresses(List<int> addressIds) async {
    var addresses = await getAddresses();
    addresses.removeWhere((a) => addressIds.contains(a.id));
    await _localDataSource.saveAddresses(addresses);
    return addresses;
  }

  @override
  Future<void> clearAddresses() async {
    await _localDataSource.clearAddresses();
  }

  // ============================================
  // SAUVEGARDE
  // ============================================

  @override
  Future<void> saveAddresses(List<Address> addresses) async {
    await _localDataSource.saveAddresses(addresses);
  }

  @override
  Future<List<Address>> syncWithBackend() async {
    // TODO: Synchroniser avec l'API Laravel
    return await getAddresses();
  }

  @override
  Future<bool> isAddressesSynced() async {
    return true;
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