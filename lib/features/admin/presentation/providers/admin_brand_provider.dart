// ============================================
// PROVIDER : AdminBrandProvider
// ============================================
// Provider de gestion d'état pour le CRUD des marques.
// Utilise AdminBrandApi directement.
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (autres features)
import '../../../products/domain/entities/brand.dart';

// Models (autres features)
import '../../../products/data/models/brand_model.dart';

// API Sources (même feature admin)
import '../../data/sources/admin_brand_api.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider marques admin
enum AdminBrandStatus {
  initial,
  loading,
  loaded,
  saving,
  deleting,
  error,
}

// ============================================
// CLASSE PRINCIPALE
// ============================================

/// Provider de gestion des marques pour l'administration.
///
/// Utilise AdminBrandApi pour les appels API directs.
class AdminBrandProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminBrandApi _api;

  // ============================================
  // ÉTAT
  // ============================================

  AdminBrandStatus _status = AdminBrandStatus.initial;
  List<Brand> _brands = [];
  String? _errorMessage;
  int? _selectedBrandId;

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  int _totalBrands = 0;
  int _activeBrands = 0;
  int _featuredBrands = 0;
  int _brandsWithProducts = 0;
  double _averageRating = 0;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminBrandProvider({AdminBrandApi? api}) : _api = api ?? AdminBrandApi();

  // ============================================
  // GETTERS
  // ============================================

  AdminBrandStatus get status => _status;
  List<Brand> get brands => List.unmodifiable(_brands);
  String? get errorMessage => _errorMessage;
  int? get selectedBrandId => _selectedBrandId;
  bool get isLoading => _status == AdminBrandStatus.loading;
  bool get isLoaded => _status == AdminBrandStatus.loaded;
  bool get isSaving => _status == AdminBrandStatus.saving;
  bool get isDeleting => _status == AdminBrandStatus.deleting;
  bool get hasError => _status == AdminBrandStatus.error;
  int get brandsCount => _brands.length;
  bool get isEmpty => _brands.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);

  // Statistiques
  int get totalBrands => _totalBrands;
  int get activeBrands => _activeBrands;
  int get featuredBrands => _featuredBrands;
  int get brandsWithProducts => _brandsWithProducts;
  double get averageRating => _averageRating;

  /// Marques actives
  List<Brand> get activeBrandList =>
      _brands.where((b) => b.isActive).toList();

  /// Marques en vedette
  List<Brand> get featuredBrandList =>
      _brands.where((b) => b.isFeatured).toList();

  /// Marques avec produits
  List<Brand> get brandsWithProductList =>
      _brands.where((b) => b.productsCount > 0).toList();

  /// Marques triées par note
  List<Brand> get brandsByRating {
    final sorted = [..._brands];
    sorted.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sorted;
  }

  /// Marque sélectionnée
  Brand? get selectedBrand {
    if (_selectedBrandId == null) return null;
    try {
      return _brands.firstWhere((b) => b.id == _selectedBrandId);
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge toutes les marques.
  Future<void> loadBrands() async {
  _status = AdminBrandStatus.loading;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _api.getBrands();
    final data = response['data'];

    if (data is List) {
      // ✅ CONVERSION CORRECTE : Model → Entity
      _brands = data
    .whereType<Map>()
    .map((e) {
      final model = BrandModel.fromJson(Map<String, dynamic>.from(e));
      return Brand(
        id: model.id,
        name: model.name,
        slug: model.slug,
        description: model.description,
        logo: model.logo,
        website: model.website,
        email: model.email,
        phone: model.phone,
        country: model.country,
        productsCount: model.productsCount,
        averageRating: model.averageRating,
        isActive: model.isActive,
        isFeatured: model.isFeatured,
      );
    })
    .toList();
    }

    _computeStatistics();
    _status = AdminBrandStatus.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminBrandStatus.error;
    debugPrint('Erreur loadBrands: $e');
  }

  notifyListeners();
}

  /// Rafraîchit sans loader.
  Future<void> refreshBrands() async {
  try {
    final response = await _api.getBrands();
    final data = response['data'];

    if (data is List) {
      _brands = data
          .whereType<Map>()
          .map((e) {
            final model = BrandModel.fromJson(Map<String, dynamic>.from(e));
            return Brand(
              id: model.id,
              name: model.name,
              slug: model.slug,
              description: model.description,
              logo: model.logo,
              website: model.website,
              email: model.email,
              phone: model.phone,
              country: model.country,
              productsCount: model.productsCount,
              averageRating: model.averageRating,
              isActive: model.isActive,
              isFeatured: model.isFeatured,
            );
          })
          .toList();
    }

    _computeStatistics();
    _status = AdminBrandStatus.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    debugPrint('Erreur refreshBrands: $e');
  }

  notifyListeners();
}


  /// Sélectionne une marque.
  void selectBrand(int? brandId) {
    _selectedBrandId = brandId;
    notifyListeners();
  }

  /// Désélectionne.
  void clearSelection() {
    _selectedBrandId = null;
    _selectedIds.clear();
    notifyListeners();
  }

  // ============================================
  // CRUD
  // ============================================

  /// Crée une nouvelle marque.
  Future<bool> createBrand(Brand brand) async {
  _status = AdminBrandStatus.saving;
  notifyListeners();

  try {
    // ✅ JSON SANS le champ slug (le serveur le génère)
    final json = {
      'name': brand.name,
      'description': brand.description,
      'logo': brand.logo,
      'website': brand.website,
      'email': brand.email,
      'phone': brand.phone,
      'country': brand.country,
      'is_active': brand.isActive,
      'is_featured': brand.isFeatured,
    };

    // ✅ Retirer les champs null
    json.removeWhere((key, value) => value == null);

    await _api.createBrand(json);
    _brands.insert(0, brand);
    _computeStatistics();
    _status = AdminBrandStatus.loaded;
    notifyListeners();
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminBrandStatus.error;
    debugPrint('Erreur createBrand: $e');
    notifyListeners();
    return false;
  }
}


  /// Met à jour une marque.
  Future<bool> updateBrand(Brand brand) async {
  _status = AdminBrandStatus.saving;
  notifyListeners();

  try {
    // ✅ JSON sans slug
    final json = {
      'name': brand.name,
      'description': brand.description,
      'logo': brand.logo,
      'website': brand.website,
      'email': brand.email,
      'phone': brand.phone,
      'country': brand.country,
      'is_active': brand.isActive,
      'is_featured': brand.isFeatured,
    };

    json.removeWhere((key, value) => value == null);

    await _api.updateBrand(brand.id, json);
    final index = _brands.indexWhere((b) => b.id == brand.id);
    if (index != -1) {
      _brands[index] = brand;
    }
    _computeStatistics();
    _status = AdminBrandStatus.loaded;
    notifyListeners();
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminBrandStatus.error;
    debugPrint('Erreur updateBrand: $e');
    notifyListeners();
    return false;
  }
}


  /// Supprime une marque.
  Future<bool> deleteBrand(int id) async {
    _status = AdminBrandStatus.deleting;
    notifyListeners();

    try {
      await _api.deleteBrand(id);
      _brands.removeWhere((b) => b.id == id);
      _selectedIds.remove(id);
      if (_selectedBrandId == id) {
        _selectedBrandId = null;
      }
      _computeStatistics();
      _status = AdminBrandStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminBrandStatus.error;
      debugPrint('Erreur deleteBrand: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Recherche une marque par nom.
  List<Brand> searchByName(String query) {
    if (query.trim().isEmpty) return _brands;
    return _brands
        .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Récupère une marque par son ID.
  Brand? getBrandById(int id) {
    try {
      return _brands.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Filtre par pays.
  List<Brand> filterByCountry(String country) {
    return _brands.where((b) => b.country == country).toList();
  }

  /// Récupère les pays disponibles.
  List<String> get availableCountries {
    final countries = _brands
        .where((b) => b.country != null && b.country!.isNotEmpty)
        .map((b) => b.country!)
        .toSet()
        .toList();
    countries.sort();
    return countries;
  }

  // ============================================
  // SÉLECTION MULTIPLE
  // ============================================

  /// Toggle la sélection.
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  /// Sélectionne tout.
  void selectAll() {
    _selectedIds.clear();
    _selectedIds.addAll(_brands.map((b) => b.id));
    notifyListeners();
  }

  /// Vérifie la sélection.
  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Calcule les statistiques.
  void _computeStatistics() {
    _totalBrands = _brands.length;
    _activeBrands = _brands.where((b) => b.isActive).length;
    _featuredBrands = _brands.where((b) => b.isFeatured).length;
    _brandsWithProducts = _brands.where((b) => b.productsCount > 0).length;

    final ratedBrands = _brands.where((b) => b.averageRating > 0).toList();
    if (ratedBrands.isNotEmpty) {
      _averageRating =
          ratedBrands.fold(0.0, (sum, b) => sum + b.averageRating) /
              ratedBrands.length;
    } else {
      _averageRating = 0;
    }
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminBrandStatus.initial;
    _brands = [];
    _errorMessage = null;
    _selectedBrandId = null;
    _selectedIds.clear();
    _totalBrands = 0;
    _activeBrands = 0;
    _featuredBrands = 0;
    _brandsWithProducts = 0;
    _averageRating = 0;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminBrandProvider(status: $_status, brands: ${_brands.length}, '
        'active: $_activeBrands, featured: $_featuredBrands, avg: ${_averageRating.toStringAsFixed(1)})';
  }
}