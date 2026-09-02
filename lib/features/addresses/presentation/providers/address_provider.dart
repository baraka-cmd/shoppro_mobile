// Provider des adresses
// Gère l'état des adresses et les actions

import 'package:flutter/foundation.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../../data/repositories/address_repository_impl.dart';

enum AddressStatus {
  initial,
  loading,
  loaded,
  saving,
  deleting,
  error,
}

class AddressProvider extends ChangeNotifier {
  final AddressRepository _addressRepository;

  AddressProvider({AddressRepository? addressRepository})
      : _addressRepository = addressRepository ?? AddressRepositoryImpl();

  AddressStatus _status = AddressStatus.initial;
  List<Address> _addresses = [];
  String? _errorMessage;

  // Getters
  AddressStatus get status => _status;
  List<Address> get addresses => _addresses;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AddressStatus.loading;
  bool get isSaving => _status == AddressStatus.saving;
  bool get hasError => _status == AddressStatus.error;
  bool get isEmpty => _addresses.isEmpty;
  int get addressesCount => _addresses.length;

  /// Adresse par défaut
  Address? get defaultAddress {
    for (final address in _addresses) {
      if (address.isDefault) return address;
    }
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  /// Adresses par type
  List<Address> getHomeAddresses() => _addresses.where((a) => a.type == 'home').toList();
  List<Address> getWorkAddresses() => _addresses.where((a) => a.type == 'work').toList();
  List<Address> getOtherAddresses() => _addresses.where((a) => a.type == 'other').toList();

  /// Charger les adresses
  Future<void> loadAddresses() async {
    _setStatus(AddressStatus.loading);
    _clearError();

    try {
      _addresses = await _addressRepository.getAddresses();
      _setStatus(AddressStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
    }

    notifyListeners();
  }

  /// Ajouter une adresse
  Future<bool> addAddress(Address address) async {
    _setStatus(AddressStatus.saving);
    _clearError();

    try {
      _addresses = await _addressRepository.addAddress(address);
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour une adresse
  Future<bool> updateAddress(Address address) async {
    _setStatus(AddressStatus.saving);
    _clearError();

    try {
      _addresses = await _addressRepository.updateAddress(address);
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Supprimer une adresse
  Future<bool> removeAddress(int addressId) async {
    _setStatus(AddressStatus.deleting);

    try {
      _addresses = await _addressRepository.removeAddress(addressId);
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Définir une adresse comme défaut
  Future<bool> setDefaultAddress(int addressId) async {
    _setStatus(AddressStatus.saving);

    try {
      _addresses = await _addressRepository.setDefaultAddress(addressId);
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  /// Récupérer une adresse par ID
  Address? getAddressById(int addressId) {
    for (final address in _addresses) {
      if (address.id == addressId) {
        return address;
      }
    }
    return null;
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setStatus(AddressStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}