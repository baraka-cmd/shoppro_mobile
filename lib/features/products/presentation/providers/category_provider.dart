// Provider des catégories
// Gère l'état des catégories dans l'application

import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

enum CategoryStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoryProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  CategoryProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  CategoryStatus _status = CategoryStatus.initial;
  String? _errorMessage;

  // ============================================
  // LISTES
  // ============================================

  List<Category> _categories = [];
  Category? _selectedCategory;

  // ============================================
  // GETTERS
  // ============================================

  CategoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CategoryStatus.loading;
  bool get hasError => _status == CategoryStatus.error;
  bool get hasCategories => _categories.isNotEmpty;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;

  /// Catégories racines (sans parent)
  List<Category> get rootCategories {
    return _categories.where((category) => category.isRoot).toList();
  }

  /// Catégories en vedette
  List<Category> get featuredCategories {
    return _categories.where((category) => category.isFeatured).toList();
  }

  /// Catégories actives
  List<Category> get activeCategories {
    return _categories.where((category) => category.isActive).toList();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  /// Charger toutes les catégories
  Future<void> loadCategories() async {
    _setStatus(CategoryStatus.loading);
    _clearError();

    try {
      _categories = await _productRepository.getCategories();
      _setStatus(CategoryStatus.loaded);
    } catch (e) {
      _setError(e.toString());
      _setStatus(CategoryStatus.error);
    }

    notifyListeners();
  }

  /// Rafraîchir les catégories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // ============================================
  // SÉLECTION
  // ============================================

  /// Sélectionner une catégorie
  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Désélectionner la catégorie
  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }

  // ============================================
  // RECHERCHE
  // ============================================

  /// Rechercher une catégorie par nom
  List<Category> searchCategories(String query) {
    if (query.trim().isEmpty) {
      return _categories;
    }

    return _categories.where((category) {
      return category.name.toLowerCase().contains(query.toLowerCase()) ||
          category.slug.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Rechercher une catégorie par ID
  Category? getCategoryById(int id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  // ============================================
  // MÉTHODES PRIVÉES
  // ============================================

  void _setStatus(CategoryStatus newStatus) {
    _status = newStatus;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message.replaceFirst('Exception: ', '');
  }
}