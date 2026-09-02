// ============================================
// ENTITÉ : AdminUser
// ============================================
// Représente un utilisateur vu depuis le backoffice admin.
// Cette entité est pure (pas de dépendances Flutter) et contient
// toutes les informations nécessaires pour la gestion des utilisateurs :
// - Informations personnelles
// - Rôles et permissions
// - Statistiques d'activité
// - Statut du compte
// ============================================

/// Rôle d'un utilisateur dans le système
enum AdminUserRole {
  admin('admin', 'Administrateur'),
  seller('seller', 'Vendeur'),
  client('client', 'Client');

  final String code;
  final String displayName;

  const AdminUserRole(this.code, this.displayName);

  /// Convertit un code en rôle
  static AdminUserRole fromCode(String? code) {
    return AdminUserRole.values.firstWhere(
      (role) => role.code == code,
      orElse: () => AdminUserRole.client,
    );
  }

  /// Convertit un nom d'affichage en rôle
  static AdminUserRole fromDisplayName(String? displayName) {
    return AdminUserRole.values.firstWhere(
      (role) => role.displayName == displayName,
      orElse: () => AdminUserRole.client,
    );
  }
}

/// Statut d'un compte utilisateur
enum AdminUserStatus {
  active('active', 'Actif'),
  inactive('inactive', 'Inactif'),
  banned('banned', 'Banni'),
  suspended('suspended', 'Suspendu');

  final String code;
  final String displayName;

  const AdminUserStatus(this.code, this.displayName);

  static AdminUserStatus fromCode(String? code) {
    return AdminUserStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => AdminUserStatus.inactive,
    );
  }
}

/// Entité représentant un utilisateur pour l'administration
class AdminUser {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  /// Identifiant unique
  final int id;

  /// Nom complet
  final String name;

  /// Adresse email
  final String email;

  /// Avatar (URL ou chemin)
  final String? avatar;

  /// Date de vérification de l'email
  final DateTime? emailVerifiedAt;

  /// Date de création du compte
  final DateTime createdAt;

  /// Date de dernière mise à jour
  final DateTime updatedAt;

  // ============================================
  // PROFIL DÉTAILLÉ
  // ============================================

  /// Prénom
  final String? firstName;

  /// Nom de famille
  final String? lastName;

  /// Numéro de téléphone
  final String? phone;

  /// Date de naissance
  final DateTime? birthDate;

  /// Genre (male, female, other)
  final String? gender;

  /// Pays
  final String? country;

  /// Ville
  final String? city;

  /// Adresse complète
  final String? address;

  /// Langue préférée
  final String language;

  /// Devise préférée
  final String currency;

  // ============================================
  // RÔLES ET PERMISSIONS
  // ============================================

  /// Rôles de l'utilisateur
  final List<AdminUserRole> roles;

  /// Permissions de l'utilisateur
  final List<String> permissions;

  // ============================================
  // STATUT
  // ============================================

  /// Statut du compte
  final AdminUserStatus status;

  /// Compte actif ?
  final bool isActive;

  /// Email vérifié ?
  final bool isVerified;

  // ============================================
  // STATISTIQUES D'ACTIVITÉ
  // ============================================

  /// Nombre total de commandes
  final int totalOrders;

  /// Montant total dépensé
  final double totalSpent;

  /// Nombre de favoris
  final int favoritesCount;

  /// Nombre d'avis postés
  final int reviewsCount;

  /// Date de dernière connexion
  final DateTime? lastLoginAt;

  /// Date de dernière activité
  final DateTime? lastActivityAt;

  // ============================================
  // PRÉFÉRENCES DE NOTIFICATION
  // ============================================

  /// Abonné à la newsletter ?
  final bool newsletterSubscribed;

  /// Notifications SMS activées ?
  final bool smsNotifications;

  /// Notifications Push activées ?
  final bool pushNotifications;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.firstName,
    this.lastName,
    this.phone,
    this.birthDate,
    this.gender,
    this.country,
    this.city,
    this.address,
    this.language = 'fr',
    this.currency = 'FCFA',
    this.roles = const [AdminUserRole.client],
    this.permissions = const [],
    this.status = AdminUserStatus.active,
    this.isActive = true,
    this.isVerified = false,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.favoritesCount = 0,
    this.reviewsCount = 0,
    this.lastLoginAt,
    this.lastActivityAt,
    this.newsletterSubscribed = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
  });

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  /// Nom complet avec prénom et nom si disponibles
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

  /// Vrai si l'utilisateur est admin
  bool get isAdmin => roles.contains(AdminUserRole.admin);

  /// Vrai si l'utilisateur est vendeur
  bool get isSeller => roles.contains(AdminUserRole.seller);

  /// Vrai si l'utilisateur est client
  bool get isClient => roles.contains(AdminUserRole.client);

  /// Nombre de rôles
  int get rolesCount => roles.length;

  /// Nombre de permissions
  int get permissionsCount => permissions.length;

  /// Vrai si l'utilisateur a des commandes
  bool get hasOrders => totalOrders > 0;

  /// Vrai si l'utilisateur a dépensé de l'argent
  bool get hasSpent => totalSpent > 0;

  /// Vrai si le compte est banni
  bool get isBanned => status == AdminUserStatus.banned;

  /// Vrai si le compte est suspendu
  bool get isSuspended => status == AdminUserStatus.suspended;

  /// Vrai si le compte est inactif
  bool get isInactive => status == AdminUserStatus.inactive;

  /// Formatage du total dépensé en FCFA
  String get totalSpentFormatted {
    return _formatCurrency(totalSpent);
  }

  /// Formatage de la date de création
  String get createdAtFormatted {
    return _formatDate(createdAt);
  }

  /// Formatage de la date de dernière connexion
  String get lastLoginFormatted {
    if (lastLoginAt == null) return 'Jamais';
    return _formatDate(lastLoginAt!);
  }

  /// Formatage de la date de dernière activité
  String get lastActivityFormatted {
    if (lastActivityAt == null) return 'Jamais';
    return _formatDate(lastActivityAt!);
  }

  /// Vrai si l'utilisateur est actif récemment (moins de 7 jours)
  bool get isRecentlyActive {
    if (lastActivityAt == null) return false;
    final difference = DateTime.now().difference(lastActivityAt!);
    return difference.inDays <= 7;
  }

  /// Vrai si l'utilisateur n'a jamais commandé
  bool get isNewUser => totalOrders == 0;

  /// Vrai si l'utilisateur est un client fidèle (plus de 5 commandes)
  bool get isLoyalCustomer => totalOrders >= 5;

  /// Vrai si l'utilisateur est un gros dépensier (plus de 500 000 FCFA)
  bool get isHighSpender => totalSpent >= 500000;

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

  /// Formate un montant en FCFA avec séparateurs de milliers
  String _formatCurrency(double amount) {
    final buffer = StringBuffer();
    final amountStr = amount.round().toString();

    for (int i = 0; i < amountStr.length; i++) {
      buffer.write(amountStr[i]);
      final remaining = amountStr.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }

    return '$buffer FCFA';
  }

  /// Formate une date en format lisible
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================
  // SERIALIZATION
  // ============================================

  /// Convertit l'entité en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'country': country,
      'city': city,
      'address': address,
      'language': language,
      'currency': currency,
      'roles': roles.map((r) => r.code).toList(),
      'permissions': permissions,
      'status': status.code,
      'is_active': isActive,
      'is_verified': isVerified,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'favorites_count': favoritesCount,
      'reviews_count': reviewsCount,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'newsletter_subscribed': newsletterSubscribed,
      'sms_notifications': smsNotifications,
      'push_notifications': pushNotifications,
    };
  }

  /// Crée une entité à partir d'une Map
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      language: json['language'] as String? ?? 'fr',
      currency: json['currency'] as String? ?? 'FCFA',
      roles: (json['roles'] as List?)
          ?.map((r) => AdminUserRole.fromCode(r as String?))
          .toList() ?? const [AdminUserRole.client],
      permissions: (json['permissions'] as List?)
          ?.map((p) => p as String)
          .toList() ?? const [],
      status: AdminUserStatus.fromCode(json['status'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.tryParse(json['last_activity_at'] as String)
          : null,
      newsletterSubscribed: json['newsletter_subscribed'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés
  AdminUser copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? country,
    String? city,
    String? address,
    String? language,
    String? currency,
    List<AdminUserRole>? roles,
    List<String>? permissions,
    AdminUserStatus? status,
    bool? isActive,
    bool? isVerified,
    int? totalOrders,
    double? totalSpent,
    int? favoritesCount,
    int? reviewsCount,
    DateTime? lastLoginAt,
    DateTime? lastActivityAt,
    bool? newsletterSubscribed,
    bool? smsNotifications,
    bool? pushNotifications,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      newsletterSubscribed: newsletterSubscribed ?? this.newsletterSubscribed,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminUser &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(id, email);

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminUser(id: $id, name: $fullName, email: $email, '
        'roles: $rolesCount, status: ${status.displayName}, '
        'orders: $totalOrders, spent: $totalSpentFormatted)';
  }
}