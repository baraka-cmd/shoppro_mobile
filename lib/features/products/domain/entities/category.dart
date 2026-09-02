// ============================================
// ENTITÉ CATEGORY (DOMAINE)
// ============================================
// Représente une catégorie de produits avec
// hiérarchie complète, images et statistiques.
// ============================================

class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;

  // Image
  final String? image;
  final String? icon;

  // Hiérarchie
  final int? parentId;
  final Category? parent;
  final List<Category> children;
  final List<Subcategory> subcategories;

  // Statistiques
  final int? productsCount;
  final int totalProductsCount;

  // Statut
  final bool isActive;
  final bool isFeatured;
  final int position;

  // Dates
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.icon,
    this.parentId,
    this.parent,
    this.children = const [],
    this.subcategories = const [],
    this.productsCount,
    this.totalProductsCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.position = 0,
    this.createdAt,
  });

  // ============================================
  // GETTERS STATISTIQUES
  // ============================================

  /// Nombre total de produits (directs + sous-catégories)
  int get effectiveProductsCount => productsCount ?? totalProductsCount;

  /// Formatage du compteur (ex: 248, 1.2k)
  String get formattedProductsCount {
    final count = effectiveProductsCount;
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  // ============================================
  // GETTERS HIÉRARCHIE
  // ============================================

  /// La catégorie a-t-elle des enfants ?
  bool get hasChildren => children.isNotEmpty;

  /// La catégorie a-t-elle des sous-catégories ?
  bool get hasSubcategories => subcategories.isNotEmpty;

  /// La catégorie est-elle racine ?
  bool get isRoot => parentId == null;

  /// La catégorie a-t-elle une hiérarchie ?
  bool get hasHierarchy => hasChildren || hasSubcategories;

  /// Nombre total de sous-catégories (enfants + sous-catégories)
  int get totalSubcategoriesCount => children.length + subcategories.length;

  // ============================================
  // GETTERS IMAGE
  // ============================================

  /// URL complète de l'image
  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return 'http://127.0.0.1:8000/storage/$image';
  }

  /// L'image est-elle disponible ?
  bool get hasImage => image != null && image!.isNotEmpty;

  // ============================================
  // GETTERS STATUT
  // ============================================

  /// La catégorie est-elle réellement visible ?
  bool get isVisible => isActive && (isFeatured || position > 0 || productsCount != null);

  // ============================================
  // VALIDATION
  // ============================================

  /// La catégorie a-t-elle des données valides ?
  bool get isValid => id > 0 && name.isNotEmpty && slug.isNotEmpty;

  // ============================================
  // MÉTHODES
  // ============================================

  /// Copier avec modifications
  Category copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    String? icon,
    int? parentId,
    Category? parent,
    List<Category>? children,
    List<Subcategory>? subcategories,
    int? productsCount,
    int? totalProductsCount,
    bool? isActive,
    bool? isFeatured,
    int? position,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      parent: parent ?? this.parent,
      children: children ?? this.children,
      subcategories: subcategories ?? this.subcategories,
      productsCount: productsCount ?? this.productsCount,
      totalProductsCount: totalProductsCount ?? this.totalProductsCount,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, products: $effectiveProductsCount, '
        'children: ${children.length}, subcategories: ${subcategories.length})';
  }
}

// ============================================
// SOUS-CATÉGORIE
// ============================================

class Subcategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String? icon;
  final int categoryId;
  final int position;
  final bool isActive;

  const Subcategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.icon,
    required this.categoryId,
    this.position = 0,
    this.isActive = true,
  });

  /// URL complète de l'image
  String get fullImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http')) return image!;
    return 'http://127.0.0.1:8000/storage/$image';
  }

  /// L'image est-elle disponible ?
  bool get hasImage => image != null && image!.isNotEmpty;

  /// La sous-catégorie a-t-elle des données valides ?
  bool get isValid => id > 0 && name.isNotEmpty && slug.isNotEmpty;

  /// Copier avec modifications
  Subcategory copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? image,
    String? icon,
    int? categoryId,
    int? position,
    bool? isActive,
  }) {
    return Subcategory(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      categoryId: categoryId ?? this.categoryId,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Subcategory(id: $id, name: $name, categoryId: $categoryId)';
  }
}