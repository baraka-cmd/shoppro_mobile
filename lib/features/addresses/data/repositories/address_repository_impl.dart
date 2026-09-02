// Implémentation du repository des adresses
// Gère la logique métier avec stockage local

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../models/address_model.dart';
import '../sources/address_local_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressLocalDataSource _localDataSource;

  AddressRepositoryImpl({AddressLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? AddressLocalDataSource();

  @override
  Future<List<Address>> getAddresses() async {
    final addresses = await _localDataSource.getAddresses();
    // Trier : défaut d'abord, puis par type
    addresses.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }
      return a.type.compareTo(b.type);
    });
    return addresses;
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
      if (address.isDefault) {
        return address;
      }
    }
    // Si pas de défaut, retourner la première
    return addresses.isNotEmpty ? addresses.first : null;
  }

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
  Future<List<Address>> updateAddress(Address address) async {
    final addresses = await getAddresses();
    final index = addresses.indexWhere((a) => a.id == address.id);

    if (index >= 0) {
      // Si cette adresse est définie comme défaut
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
  Future<List<Address>> removeAddress(int addressId) async {
    final addresses = await getAddresses();
    final removedAddress = addresses.where((a) => a.id == addressId).firstOrNull;

    addresses.removeWhere((a) => a.id == addressId);

    // Si l'adresse supprimée était la défaut, définir la première comme défaut
    if (removedAddress != null && removedAddress.isDefault && addresses.isNotEmpty) {
      addresses[0] = addresses[0].copyWith(isDefault: true);
    }

    await _localDataSource.saveAddresses(addresses);
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
  Future<void> clearAddresses() async {
    await _localDataSource.clearAddresses();
  }
}

// Extension firstOrNull
extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}