// ============================================
// MODÈLE CATEGORY (DATA)
// ============================================
// Gère la sérialisation/désérialisation JSON
// avec parsing robuste et anti-erreurs.
// ============================================

import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.image,
    super.icon,
    super.parentId,
    super.parent,
    super.children,
    super.subcategories,
    super.productsCount,
    super.totalProductsCount,
    super.isActive,
    super.isFeatured,
    super.position,
    super.createdAt,
  });

  /// Créer un CategoryModel depuis JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      description: _parseNullableString(json['description']),

      // Image
      image: _parseNullableString(json['image']),
      icon: _parseNullableString(json['icon']),

      // Hiérarchie
      parentId: _parseNullableInt(json['parent_id']),
      parent: json['parent'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      children: _parseChildren(json['children']),
      subcategories: _parseSubcategories(json['subcategories']),

      // Statistiques
      productsCount: _parseNullableInt(json['products_count']),
      totalProductsCount: _parseInt(json['total_products_count']),

      // Statut
      isActive: _parseBool(json['is_active'], defaultValue: true),
      isFeatured: _parseBool(json['is_featured'], defaultValue: false),
      position: _parseInt(json['position']),

      // Dates
      createdAt: _parseDate(json['created_at']),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'icon': icon,
      'parent_id': parentId,
      'parent': parent is CategoryModel
          ? (parent as CategoryModel).toJson()
          : null,
      'children': children
          .whereType<CategoryModel>()
          .map((child) => child.toJson())
          .toList(),
      'subcategories': subcategories
          .whereType<SubcategoryModel>()
          .map((sub) => sub.toJson())
          .toList(),
      'products_count': productsCount,
      'total_products_count': totalProductsCount,
      'is_active': isActive,
      'is_featured': isFeatured,
      'position': position,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Copier depuis l'entité
  static CategoryModel fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      slug: category.slug,
      description: category.description,
      image: category.image,
      icon: category.icon,
      parentId: category.parentId,
      parent: category.parent,
      children: category.children,
      subcategories: category.subcategories,
      productsCount: category.productsCount,
      totalProductsCount: category.totalProductsCount,
      isActive: category.isActive,
      isFeatured: category.isFeatured,
      position: category.position,
      createdAt: category.createdAt,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Parser les enfants
  static List<CategoryModel> _parseChildren(dynamic childrenJson) {
    if (childrenJson is! List) return [];
    return childrenJson
        .whereType<Map<String, dynamic>>()
        .map((childJson) => CategoryModel.fromJson(childJson))
        .toList();
  }

  /// Parser les sous-catégories
  static List<SubcategoryModel> _parseSubcategories(dynamic subcategoriesJson) {
    if (subcategoriesJson is! List) return [];
    return subcategoriesJson
        .whereType<Map<String, dynamic>>()
        .map((subJson) => SubcategoryModel.fromJson(subJson))
        .toList();
  }
}

// ============================================
// MODÈLE DE SOUS-CATÉGORIE
// ============================================

class SubcategoryModel extends Subcategory {
  const SubcategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.image,
    super.icon,
    required super.categoryId,
    super.position,
    super.isActive,
  });

  /// Créer depuis JSON
  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      description: _parseNullableString(json['description']),
      image: _parseNullableString(json['image']),
      icon: _parseNullableString(json['icon']),
      categoryId: _parseInt(json['category_id']),
      position: _parseInt(json['position']),
      isActive: _parseBool(json['is_active'], defaultValue: true),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'icon': icon,
      'category_id': categoryId,
      'position': position,
      'is_active': isActive,
    };
  }

  /// Copier depuis l'entité
  static SubcategoryModel fromEntity(Subcategory subcategory) {
    return SubcategoryModel(
      id: subcategory.id,
      name: subcategory.name,
      slug: subcategory.slug,
      description: subcategory.description,
      image: subcategory.image,
      icon: subcategory.icon,
      categoryId: subcategory.categoryId,
      position: subcategory.position,
      isActive: subcategory.isActive,
    );
  }

  // ============================================
  // HELPERS DE PARSING
  // ============================================

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final string = value.toString().trim();
    return string.isEmpty ? null : string;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }
}