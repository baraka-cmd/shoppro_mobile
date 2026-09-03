// ============================================
// PROVIDER DES ADRESSES - VERSION PREMIUM
// ============================================
// Gère l'état des adresses avec actions complètes,
// défaut intelligent et annulation.
// ============================================

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

  // ============================================
  // ÉTAT
  // ============================================

  AddressStatus _status = AddressStatus.initial;
  List<Address> _addresses = [];
  String? _errorMessage;
  int _updatingAddressId = -1;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  AddressStatus get status => _status;
  List<Address> get addresses => _addresses;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AddressStatus.loading;
  bool get isSaving => _status == AddressStatus.saving;
  bool get isDeleting => _status == AddressStatus.deleting;
  bool get hasError => _status == AddressStatus.error;
  bool get isEmpty => _addresses.isEmpty;
  int get addressesCount => _addresses.length;

  /// ID de l'adresse en cours de mise à jour
  int get updatingAddressId => _updatingAddressId;

  // ============================================
  // GETTERS DÉRIVÉS
  // ============================================

  /// Adresse par défaut
  Address? get defaultAddress {
    for (final address in _addresses) {
      if (address.isDefault && address.isActive) return address;
    }
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  /// Adresses actives
  List<Address> get activeAddresses {
    return _addresses.where((a) => a.isActive).toList();
  }

  /// Adresses avec GPS
  List<Address> get addressesWithGps {
    return _addresses.where((a) => a.hasGps).toList();
  }

  /// Adresses par type
  List<Address> getHomeAddresses() =>
      _addresses.where((a) => a.type == 'home').toList();
  List<Address> getWorkAddresses() =>
      _addresses.where((a) => a.type == 'work').toList();
  List<Address> getShopAddresses() =>
      _addresses.where((a) => a.type == 'shop').toList();
  List<Address> getOtherAddresses() =>
      _addresses.where((a) => a.type == 'other').toList();

  // ============================================
  // CHARGEMENT
  // ============================================

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

  /// Rafraîchir les adresses
  Future<void> refreshAddresses() async {
    await loadAddresses();
  }

  // ============================================
  // AJOUT
  // ============================================

  /// Ajouter une adresse
  Future<bool> addAddress(Address address) async {
    _setStatus(AddressStatus.saving);
    _clearError();

    try {
      await _addressRepository.saveAddressesSnapshot();
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

  // ============================================
  // MODIFICATION
  // ============================================

  /// Mettre à jour une adresse
  Future<bool> updateAddress(Address address) async {
    _setStatus(AddressStatus.saving);
    _updatingAddressId = address.id;
    _clearError();

    try {
      await _addressRepository.saveAddressesSnapshot();
      _addresses = await _addressRepository.updateAddress(address);
      _updatingAddressId = -1;
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingAddressId = -1;
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // SUPPRESSION
  // ============================================

  /// Supprimer une adresse
  Future<bool> removeAddress(int addressId) async {
    _setStatus(AddressStatus.deleting);
    _updatingAddressId = addressId;

    try {
      await _addressRepository.saveAddressesSnapshot();
      _addresses = await _addressRepository.removeAddress(addressId);
      _updatingAddressId = -1;
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingAddressId = -1;
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // ADRESSE PAR DÉFAUT
  // ============================================

  /// Définir une adresse comme défaut
  Future<bool> setDefaultAddress(int addressId) async {
    _setStatus(AddressStatus.saving);
    _updatingAddressId = addressId;

    try {
      await _addressRepository.saveAddressesSnapshot();
      _addresses = await _addressRepository.setDefaultAddress(addressId);
      _updatingAddressId = -1;
      _setStatus(AddressStatus.loaded);
      notifyListeners();
      return true;
    } catch (e) {
      _updatingAddressId = -1;
      _setError(e.toString());
      _setStatus(AddressStatus.error);
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Récupérer une adresse par ID
  Address? getAddressById(int addressId) {
    for (final address in _addresses) {
      if (address.id == addressId) {
        return address;
      }
    }
    return null;
  }

  // ============================================
  // ANNULATION (Undo)
  // ============================================

  /// Annuler la dernière action
  Future<bool> undoLastAction() async {
    try {
      final restored = await _addressRepository.restoreAddressesSnapshot();
      if (restored != null) {
        _addresses = restored;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(AddressStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AddressProvider(status: $_status, addresses: ${_addresses.length}, '
        'default: ${defaultAddress?.id ?? 'none'}, updating: $_updatingAddressId)';
  }
}