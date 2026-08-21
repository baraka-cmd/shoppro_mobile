// Entité Category (Domaine)
// Représente une catégorie de produits dans la couche domaine

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

  /// Nombre total de produits (directs + sous-catégories)
  int get effectiveProductsCount => productsCount ?? totalProductsCount;

  /// La catégorie a-t-elle des enfants ?
  bool get hasChildren => children.isNotEmpty;

  /// La catégorie a-t-elle des sous-catégories ?
  bool get hasSubcategories => subcategories.isNotEmpty;

  /// La catégorie est-elle racine ?
  bool get isRoot => parentId == null;

  /// URL de l'image
  String? get imageUrl => image;

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
    );
  }
}

// Sous-catégorie
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

  /// URL de l'image
  String? get imageUrl => image;

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
}