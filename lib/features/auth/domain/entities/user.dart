// Entité User (Domaine)
// 
// Cette classe représente un utilisateur dans la couche domaine.
// Elle ne dépend d'aucun framework ou bibliothèque externe.

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? country;
  final String? city;
  final List<String> roles;
  final int totalOrders;
  final double totalSpent;
  final bool emailVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    this.firstName,
    this.lastName,
    this.country,
    this.city,
    this.roles = const [],
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.emailVerified = false,
  });

  // Nom complet (prénom + nom ou name)
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }

  // L'utilisateur est-il admin ?
  bool get isAdmin => roles.contains('admin');

  // L'utilisateur est-il vendeur ?
  bool get isSeller => roles.contains('seller');

  // L'utilisateur est-il client ?
  bool get isClient => roles.contains('client');

  // Copier avec des modifications
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    String? phone,
    String? firstName,
    String? lastName,
    String? country,
    String? city,
    List<String>? roles,
    int? totalOrders,
    double? totalSpent,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      city: city ?? this.city,
      roles: roles ?? this.roles,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'country': country,
      'city': city,
      'roles': roles,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'email_verified': emailVerified,
    };
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}