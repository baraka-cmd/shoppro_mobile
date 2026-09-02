// ============================================
// PROVIDER : AdminCategoryProvider
// ============================================
// Provider de gestion d'état pour le CRUD des catégories.
// Utilise AdminCategoryApi directement.
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Entities (autres features)
import '../../../products/domain/entities/category.dart';

// Models (autres features)
import '../../../products/data/models/category_model.dart';

// API Sources (même feature admin)
import '../../data/sources/admin_category_api.dart';

// ============================================
// ENUM D'ÉTAT
// ============================================

/// États possibles du provider catégories admin
enum AdminCategoryStatus {
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

/// Provider de gestion des catégories pour l'administration.
///
/// Utilise AdminCategoryApi pour les appels API directs.
class AdminCategoryProvider extends ChangeNotifier {
  // ============================================
  // DÉPENDANCES
  // ============================================

  final AdminCategoryApi _api;

  // ============================================
  // ÉTAT
  // ============================================

  AdminCategoryStatus _status = AdminCategoryStatus.initial;
  List<Category> _categories = [];
  String? _errorMessage;
  int? _selectedCategoryId;

  // Sélection
  final Set<int> _selectedIds = {};

  // Statistiques
  int _totalCategories = 0;
  int _rootCategories = 0;
  int _subCategories = 0;
  int _activeCategories = 0;
  int _featuredCategories = 0;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  AdminCategoryProvider({AdminCategoryApi? api}) : _api = api ?? AdminCategoryApi();

  // ============================================
  // GETTERS
  // ============================================

  AdminCategoryStatus get status => _status;
  List<Category> get categories => List.unmodifiable(_categories);
  String? get errorMessage => _errorMessage;
  int? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _status == AdminCategoryStatus.loading;
  bool get isLoaded => _status == AdminCategoryStatus.loaded;
  bool get isSaving => _status == AdminCategoryStatus.saving;
  bool get isDeleting => _status == AdminCategoryStatus.deleting;
  bool get hasError => _status == AdminCategoryStatus.error;
  int get categoriesCount => _categories.length;
  bool get isEmpty => _categories.isEmpty;
  bool get hasSelection => _selectedIds.isNotEmpty;
  int get selectedCount => _selectedIds.length;
  List<int> get selectedIds => List.unmodifiable(_selectedIds);

  // Statistiques
  int get totalCategories => _totalCategories;
  int get rootCategories => _rootCategories;
  int get subCategories => _subCategories;
  int get activeCategories => _activeCategories;
  int get featuredCategories => _featuredCategories;

  /// Catégories racines (sans parent)
  List<Category> get rootCategoryList =>
      _categories.where((c) => c.parentId == null).toList();

  /// Sous-catégories (avec parent)
  List<Category> get subCategoryList =>
      _categories.where((c) => c.parentId != null).toList();

  /// Catégories actives
  List<Category> get activeCategoryList =>
      _categories.where((c) => c.isActive).toList();

  /// Catégories en vedette
  List<Category> get featuredCategoryList =>
      _categories.where((c) => c.isFeatured).toList();

  /// Catégorie sélectionnée
  Category? get selectedCategory {
    if (_selectedCategoryId == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      return null;
    }
  }

  // ============================================
  // ACTIONS PRINCIPALES
  // ============================================

  /// Charge toutes les catégories.
  Future<void> loadCategories() async {
  _status = AdminCategoryStatus.loading;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _api.getCategories();
    final data = response['data'];

    if (data is List) {
      _categories = data
          .whereType<Map>()
          .map((e) {
            final model = CategoryModel.fromJson(Map<String, dynamic>.from(e));
            // ✅ CONVERSION Model → Entity
            return Category(
              id: model.id,
              name: model.name,
              slug: model.slug,
              description: model.description,
              icon: model.icon,
              position: model.position,
              parentId: model.parentId,
              isActive: model.isActive,
              isFeatured: model.isFeatured,
            );
          })
          .toList();
    }

    _computeStatistics();
    _status = AdminCategoryStatus.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminCategoryStatus.error;
    debugPrint('Erreur loadCategories: $e');
  }

  notifyListeners();
}

  /// Rafraîchit sans loader.
  Future<void> refreshCategories() async {
  try {
    final response = await _api.getCategories();
    final data = response['data'];

    if (data is List) {
      _categories = data
          .whereType<Map>()
          .map((e) {
            final model = CategoryModel.fromJson(Map<String, dynamic>.from(e));
            return Category(
              id: model.id,
              name: model.name,
              slug: model.slug,
              description: model.description,
              icon: model.icon,
              position: model.position,
              parentId: model.parentId,
              isActive: model.isActive,
              isFeatured: model.isFeatured,
            );
          })
          .toList();
    }

    _computeStatistics();
    _status = AdminCategoryStatus.loaded;
  } catch (e) {
    _errorMessage = e.toString();
    debugPrint('Erreur refreshCategories: $e');
  }

  notifyListeners();
}

  /// Sélectionne une catégorie.
  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Désélectionne la catégorie.
  void clearSelection() {
    _selectedCategoryId = null;
    _selectedIds.clear();
    notifyListeners();
  }

  // ============================================
  // CRUD
  // ============================================

  // ============================================
// Crée une nouvelle catégorie.
// ============================================
Future<bool> createCategory(Category category) async {
  _status = AdminCategoryStatus.saving;
  notifyListeners();

  try {
    // ✅ Conversion manuelle en JSON
    final json = {
      'name': category.name,
      'slug': category.slug,
      'description': category.description,
      'parent_id': category.parentId,
      'icon': category.icon,
      'position': category.position,
      'is_active': category.isActive,
      'is_featured': category.isFeatured,
    };

    await _api.createCategory(json);
    _categories.insert(0, category);
    _computeStatistics();
    _status = AdminCategoryStatus.loaded;
    notifyListeners();
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminCategoryStatus.error;
    debugPrint('Erreur createCategory: $e');
    notifyListeners();
    return false;
  }
}

// ============================================
// Met à jour une catégorie.
// ============================================
Future<bool> updateCategory(Category category) async {
  _status = AdminCategoryStatus.saving;
  notifyListeners();

  try {
    // ✅ Conversion manuelle en JSON
    final json = {
      'name': category.name,
      'slug': category.slug,
      'description': category.description,
      'parent_id': category.parentId,
      'icon': category.icon,
      'position': category.position,
      'is_active': category.isActive,
      'is_featured': category.isFeatured,
    };

    await _api.updateCategory(category.id, json);
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    _computeStatistics();
    _status = AdminCategoryStatus.loaded;
    notifyListeners();
    return true;
  } catch (e) {
    _errorMessage = e.toString();
    _status = AdminCategoryStatus.error;
    debugPrint('Erreur updateCategory: $e');
    notifyListeners();
    return false;
  }
}

Category? getCategoryByName(String name) {
  try {
    return _categories.firstWhere((c) => c.name == name);
  } catch (_) {
    return null;
  }
}
  
  /// Supprime une catégorie.
  Future<bool> deleteCategory(int id) async {
    _status = AdminCategoryStatus.deleting;
    notifyListeners();

    try {
      await _api.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      _selectedIds.remove(id);
      if (_selectedCategoryId == id) {
        _selectedCategoryId = null;
      }
      _computeStatistics();
      _status = AdminCategoryStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdminCategoryStatus.error;
      debugPrint('Erreur deleteCategory: $e');
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Recherche une catégorie par nom.
  List<Category> searchByName(String query) {
    if (query.trim().isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Récupère une catégorie par son ID.
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Récupère les sous-catégories d'une catégorie.
  List<Category> getSubcategories(int parentId) {
    return _categories.where((c) => c.parentId == parentId).toList();
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
    _selectedIds.addAll(_categories.map((c) => c.id));
    notifyListeners();
  }

  /// Vérifie la sélection.
  bool isSelected(int id) => _selectedIds.contains(id);

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Calcule les statistiques.
  void _computeStatistics() {
    _totalCategories = _categories.length;
    _rootCategories = _categories.where((c) => c.parentId == null).length;
    _subCategories = _categories.where((c) => c.parentId != null).length;
    _activeCategories = _categories.where((c) => c.isActive).length;
    _featuredCategories = _categories.where((c) => c.isFeatured).length;
  }

  // ============================================
  // RÉINITIALISATION
  // ============================================

  /// Réinitialise le provider.
  void reset() {
    _status = AdminCategoryStatus.initial;
    _categories = [];
    _errorMessage = null;
    _selectedCategoryId = null;
    _selectedIds.clear();
    _totalCategories = 0;
    _rootCategories = 0;
    _subCategories = 0;
    _activeCategories = 0;
    _featuredCategories = 0;
    notifyListeners();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminCategoryProvider(status: $_status, categories: ${_categories.length}, '
        'root: $_rootCategories, sub: $_subCategories, featured: $_featuredCategories)';
  }
}