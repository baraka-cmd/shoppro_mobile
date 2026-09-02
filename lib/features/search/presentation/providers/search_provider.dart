// ============================================
// PROVIDER DE RECHERCHE - VERSION PREMIUM
// ============================================
// Gère la recherche, les suggestions intelligentes,
// l'historique local, la correction orthographique
// et les filtres avancés. Design ShopPro.
// ============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../products/data/repositories/product_repository_impl.dart';

enum SearchStatus {
  initial,
  searching,
  results,
  suggestions,
  error,
  empty,
}

class SearchProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  SearchProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  // ============================================
  // ÉTAT
  // ============================================

  SearchStatus _status = SearchStatus.initial;
  String _query = '';
  String? _errorMessage;
  List<Product> _results = [];
  List<Product> _suggestions = [];
  List<String> _history = [];
  Timer? _debounceTimer;

  // Filtres actifs
  int? _categoryId;
  int? _brandId;
  double? _minPrice;
  double? _maxPrice;
  bool? _inStock;
  double? _minRating;
  String _sortBy = 'created_at';
  String _sortDirection = 'desc';

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // ============================================
  // GETTERS DE BASE
  // ============================================

  SearchStatus get status => _status;
  String get query => _query;
  String? get errorMessage => _errorMessage;
  List<Product> get results => _results;
  List<Product> get suggestions => _suggestions;
  List<String> get history => _history;
  bool get isSearching => _status == SearchStatus.searching;
  bool get hasResults => _results.isNotEmpty;
  bool get hasSuggestions => _suggestions.isNotEmpty;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  /// Nombre de résultats
  int get resultsCount => _results.length;

  /// Filtres actifs
  bool get hasActiveFilters =>
      _categoryId != null ||
      _brandId != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _inStock != null ||
      _minRating != null;

  int get activeFiltersCount {
    var count = 0;
    if (_categoryId != null) count++;
    if (_brandId != null) count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_inStock != null) count++;
    if (_minRating != null) count++;
    return count;
  }

  // ============================================
  // RECHERCHE PRINCIPALE
  // ============================================

  /// Rechercher des produits avec debounce
  Future<void> search(String query) async {
    _query = query.trim();

    if (_query.isEmpty) {
      _clearSearch();
      return;
    }

    _status = SearchStatus.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _productRepository.searchProducts(
        query: _query,
        page: 1,
        perPage: 15,
      );

      if (results.isEmpty) {
        _status = SearchStatus.empty;
        _results = [];
      } else {
        _status = SearchStatus.results;
        _results = results;
        _currentPage = 1;
        _hasMore = await _productRepository.hasMoreProducts(page: 1);
      }

      // Sauvegarder dans l'historique
      await _addToHistory(_query);
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Charger plus de résultats (pagination)
  Future<void> loadMoreResults() async {
    if (_isLoadingMore || !_hasMore || _query.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newResults = await _productRepository.searchProducts(
        query: _query,
        page: nextPage,
        perPage: 15,
      );

      if (newResults.isNotEmpty) {
        _results = [..._results, ...newResults];
        _currentPage = nextPage;
        _hasMore = await _productRepository.hasMoreProducts(page: nextPage);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('❌ Erreur loadMoreResults: $e');
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // ============================================
  // SUGGESTIONS INTELLIGENTES (avec debounce)
  // ============================================

  /// Rechercher des suggestions avec debounce
  void searchSuggestionsDebounced(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      searchSuggestions(query);
    });
  }

  /// Rechercher des suggestions
  Future<void> searchSuggestions(String query) async {
    _query = query.trim();

    if (_query.isEmpty) {
      _status = SearchStatus.initial;
      _suggestions = [];
      notifyListeners();
      return;
    }

    try {
      final suggestions = await _productRepository.searchProducts(
        query: _query,
        page: 1,
        perPage: 5,
      );

      _suggestions = suggestions;
      _status = SearchStatus.suggestions;
    } catch (e) {
      _suggestions = [];
      debugPrint('❌ Erreur suggestions: $e');
    }

    notifyListeners();
  }

  // ============================================
  // RECHERCHE AVEC FILTRES
  // ============================================

  /// Filtrer les résultats
  Future<void> searchWithFilters({
    required String query,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    double? minRating,
    bool? onSale,
    String sortBy = 'created_at',
    String sortDirection = 'desc',
  }) async {
    _query = query.trim();
    _categoryId = categoryId;
    _brandId = brandId;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _inStock = inStock;
    _minRating = minRating;
    _sortBy = sortBy;
    _sortDirection = sortDirection;

    _status = SearchStatus.searching;
    notifyListeners();

    try {
      final results = await _productRepository.filterProducts(
        categoryId: categoryId,
        brandId: brandId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        inStock: inStock,
        minRating: minRating,
        onSale: onSale,
        sortBy: sortBy,
        sortDirection: sortDirection,
        page: 1,
      );

      _results = results;
      _status = results.isEmpty ? SearchStatus.empty : SearchStatus.results;
      _currentPage = 1;
    } catch (e) {
      _status = SearchStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    notifyListeners();
  }

  /// Effacer tous les filtres
  Future<void> clearFilters() async {
    _categoryId = null;
    _brandId = null;
    _minPrice = null;
    _maxPrice = null;
    _inStock = null;
    _minRating = null;
    await search(_query);
  }

  // ============================================
  // TRI LOCAL
  // ============================================

  /// Trier les résultats localement
  void sortResults(String sortBy, String sortDirection) {
    _sortBy = sortBy;
    _sortDirection = sortDirection;

    switch (sortBy) {
      case 'price':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.currentPrice.compareTo(b.currentPrice)
            : b.currentPrice.compareTo(a.currentPrice));
        break;
      case 'rating':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.averageRating.compareTo(b.averageRating)
            : b.averageRating.compareTo(a.averageRating));
        break;
      case 'popularity':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.salesCount.compareTo(b.salesCount)
            : b.salesCount.compareTo(a.salesCount));
        break;
      case 'name':
        _results.sort((a, b) => sortDirection == 'asc'
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      default:
        break;
    }

    notifyListeners();
  }

  // ============================================
  // CORRECTION ORTHOGRAPHIQUE (Levenshtein)
  // ============================================

  /// Corriger une faute de frappe
  String correctSpelling(String query, List<String> dictionary) {
    if (query.isEmpty || dictionary.isEmpty) return query;

    String bestMatch = query;
    int bestDistance = -1;

    for (final word in dictionary) {
      final distance = _levenshteinDistance(
        query.toLowerCase(),
        word.toLowerCase(),
      );

      if (bestDistance == -1 || distance < bestDistance) {
        bestDistance = distance;
        bestMatch = word;
      }
    }

    // Ne corriger que si la distance est faible (max 2 caractères)
    if (bestDistance > 2) {
      return query;
    }

    return bestMatch;
  }

  int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List<int>.filled(b.length + 1, 0),
    );

    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((min, value) => value < min ? value : min);
      }
    }

    return matrix[a.length][b.length];
  }

  // ============================================
  // HISTORIQUE
  // ============================================

  /// Charger l'historique
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _history = prefs.getStringList('search_history') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur loadHistory: $e');
    }
  }

  /// Effacer l'historique
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
      _history = [];
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur clearHistory: $e');
    }
  }

  

  /// Supprimer une entrée de l'historique
  Future<void> removeFromHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      await prefs.setStringList('search_history', _history);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur removeFromHistory: $e');
    }
  }

  /// Ajouter à l'historique
  Future<void> _addToHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];

      history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      history.insert(0, query);

      if (history.length > 10) {
        history.removeRange(10, history.length);
      }

      await prefs.setStringList('search_history', history);
      _history = history;
    } catch (e) {
      debugPrint('❌ Erreur _addToHistory: $e');
    }
  }

  // ============================================
  // EFFACEMENT
  // ============================================

  /// Effacer la recherche actuelle
  void _clearSearch() {
    _query = '';
    _results = [];
    _suggestions = [];
    _status = SearchStatus.initial;
    notifyListeners();
  }

  /// Effacer la recherche actuelle (publique)
  void clearSearch() {
    _clearSearch();
  }

  /// Effacer tout
  void clearAll() {
    _debounceTimer?.cancel();
    _clearSearch();
  }

  /// Effacer l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // DISPOSE
  // ============================================

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'SearchProvider(status: $_status, query: "$_query", '
        'results: ${_results.length}, suggestions: ${_suggestions.length}, '
        'history: ${_history.length}, filters: $activeFiltersCount)';
  }
}