// Modèle User (Data)
// 
// Cette classe gère la sérialisation/désérialisation JSON.
// Elle convertit les données API en entité User.

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatar,
    super.phone,
    super.firstName,
    super.lastName,
    super.country,
    super.city,
    super.roles,
    super.totalOrders,
    super.totalSpent,
    super.emailVerified,
  });

  // Créer un UserModel depuis JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      phone: json['profile']?['phone'] as String?,
      firstName: json['profile']?['first_name'] as String?,
      lastName: json['profile']?['last_name'] as String?,
      country: json['profile']?['country'] as String?,
      city: json['profile']?['city'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role['name'] as String)
              .toList() ??
          [],
      totalOrders: json['stats']?['total_orders'] as int? ?? 0,
      totalSpent: (json['stats']?['total_spent'] as num?)?.toDouble() ?? 0,
      emailVerified: json['email_verified_at'] != null,
    );
  }

  // Convertir en JSON
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    return {
      'id': json['id'],
      'name': json['name'],
      'email': json['email'],
      'avatar': json['avatar'],
      'profile': {
        'phone': json['phone'],
        'first_name': json['first_name'],
        'last_name': json['last_name'],
        'country': json['country'],
        'city': json['city'],
      },
      'roles': json['roles'].map((role) => {'name': role}).toList(),
      'stats': {
        'total_orders': json['total_orders'],
        'total_spent': json['total_spent'],
      },
    };
  }
}