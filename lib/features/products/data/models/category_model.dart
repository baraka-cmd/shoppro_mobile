// Modèle Category (Data)
// Gère la sérialisation/désérialisation JSON de la catégorie

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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      
      // Image
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      
      // Hiérarchie
      parentId: json['parent_id'] as int?,
      parent: json['parent'] != null
          ? CategoryModel.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      children: _parseChildren(json['children']),
      subcategories: _parseSubcategories(json['subcategories']),
      
      // Statistiques
      productsCount: json['products_count'] as int?,
      totalProductsCount: json['total_products_count'] as int? ?? 0,
      
      // Statut
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      position: json['position'] as int? ?? 0,
      
      // Dates
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
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
      'parent': parent != null ? (parent as CategoryModel).toJson() : null,
      'children': children.map((child) => (child as CategoryModel).toJson()).toList(),
      'subcategories': subcategories.map((sub) {
        return {
          'id': sub.id,
          'name': sub.name,
          'slug': sub.slug,
          'description': sub.description,
          'image': sub.image,
          'icon': sub.icon,
          'category_id': sub.categoryId,
          'position': sub.position,
          'is_active': sub.isActive,
        };
      }).toList(),
      'products_count': productsCount,
      'total_products_count': totalProductsCount,
      'is_active': isActive,
      'is_featured': isFeatured,
      'position': position,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Parser les enfants
  static List<CategoryModel> _parseChildren(dynamic childrenJson) {
    if (childrenJson == null || childrenJson is! List) {
      return [];
    }

    return childrenJson
        .whereType<Map<String, dynamic>>()
        .map((childJson) => CategoryModel.fromJson(childJson))
        .toList();
  }

  /// Parser les sous-catégories
  static List<SubcategoryModel> _parseSubcategories(dynamic subcategoriesJson) {
    if (subcategoriesJson == null || subcategoriesJson is! List) {
      return [];
    }

    return subcategoriesJson
        .whereType<Map<String, dynamic>>()
        .map((subJson) => SubcategoryModel.fromJson(subJson))
        .toList();
  }
}

// Modèle de sous-catégorie
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
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      categoryId: json['category_id'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
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
}