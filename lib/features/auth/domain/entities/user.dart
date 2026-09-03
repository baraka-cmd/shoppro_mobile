// ============================================
// ENTITÉ USER (DOMAINE) - VERSION PREMIUM
// ============================================
// Représente un utilisateur dans la couche domaine.
// Ne dépend d'aucun framework ou bibliothèque externe.
// ============================================

class User {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final String? address;

  // ============================================
  // STATUT DU COMPTE
  // ============================================

  final bool isActive;
  final bool isBanned;
  final bool isSuspended;
  final bool isVerified;

  // ============================================
  // PROFIL DÉTAILLÉ
  // ============================================

  final String? firstName;
  final String? lastName;
  final String? country;
  final String? city;
  final String? language;
  final String? currency;

  // ============================================
  // RÔLES ET PERMISSIONS
  // ============================================

  final List<String> roles;

  // ============================================
  // STATISTIQUES
  // ============================================

  final int totalOrders;
  final double totalSpent;
  final bool emailVerified;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    this.address,
    this.roles = const [],
    this.isActive = true,
    this.isBanned = false,
    this.isSuspended = false,
    this.isVerified = false,
    this.firstName,
    this.lastName,
    this.country,
    this.city,
    this.language,
    this.currency,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.emailVerified = false,
  });

  // ============================================
  // GETTERS DE NOM
  // ============================================

  /// Nom complet (prénom + nom ou name)
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return name;
  }

  /// Initiales pour l'avatar (ex: "Jean Dupont" → "JD")
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // ============================================
  // GETTERS DE RÔLE
  // ============================================

  bool get isAdmin => roles.contains('admin');
  bool get isSeller => roles.contains('seller');
  bool get isClient => roles.contains('client');

  /// Nom du rôle principal pour l'affichage
  String get roleName {
    if (isAdmin) return 'Administrateur';
    if (isSeller) return 'Vendeur';
    if (isClient) return 'Client';
    return 'Invité';
  }

  // ============================================
  // GETTERS DE STATUT
  // ============================================

  /// Vrai si le compte peut accéder à l'application
  bool get canAccess => isActive && !isBanned && !isSuspended;

  /// Vrai si l'email a été vérifié
  bool get hasVerifiedEmail => emailVerified || isVerified;

  // ============================================
  // GETTERS DE STATISTIQUES
  // ============================================

  /// Total dépensé formaté en FCFA
  String get totalSpentFormatted {
    final buffer = StringBuffer();
    final amountStr = totalSpent.round().toString();
    for (int i = 0; i < amountStr.length; i++) {
      buffer.write(amountStr[i]);
      final remaining = amountStr.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }
    return '$buffer FCFA';
  }

  /// Vrai si c'est un client fidèle (plus de 5 commandes)
  bool get isLoyalCustomer => totalOrders >= 5;

  // ============================================
  // COPYWITH
  // ============================================

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    String? phone,
    String? address,
    String? firstName,
    String? lastName,
    String? country,
    String? city,
    String? language,
    String? currency,
    List<String>? roles,
    int? totalOrders,
    double? totalSpent,
    bool? emailVerified,
    bool? isActive,
    bool? isBanned,
    bool? isSuspended,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      country: country ?? this.country,
      city: city ?? this.city,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      roles: roles ?? this.roles,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      isBanned: isBanned ?? this.isBanned,
      isSuspended: isSuspended ?? this.isSuspended,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // ============================================
  // CONVERSION JSON
  // ============================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'phone': phone,
      'address': address,
      'first_name': firstName,
      'last_name': lastName,
      'country': country,
      'city': city,
      'language': language,
      'currency': currency,
      'roles': roles,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'email_verified': emailVerified,
      'is_active': isActive,
      'is_banned': isBanned,
      'is_suspended': isSuspended,
      'is_verified': isVerified,
    };
  }

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, '
        'role: $roleName, active: $isActive, address: ${address ?? 'non définie'})';
  }
}