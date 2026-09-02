// ============================================
// ENTITÉ : AdminSetting
// ============================================
// Représente un paramètre de configuration de l'application.
// Cette entité est pure (pas de dépendances Flutter) et contient
// toutes les informations nécessaires pour la gestion des paramètres :
// - Paramètres généraux (nom, logo, devise)
// - Paramètres de livraison
// - Paramètres de paiement
// - Paramètres de notification
// - Paramètres de sécurité
// ============================================

/// Type de valeur d'un paramètre
enum AdminSettingType {
  string('string', 'Texte'),
  integer('integer', 'Nombre entier'),
  float('float', 'Nombre décimal'),
  boolean('boolean', 'Booléen'),
  json('json', 'JSON'),
  array('array', 'Tableau'),
  file('file', 'Fichier');

  final String code;
  final String displayName;

  const AdminSettingType(this.code, this.displayName);

  static AdminSettingType fromCode(String? code) {
    return AdminSettingType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AdminSettingType.string,
    );
  }
}

/// Groupe d'un paramètre
enum AdminSettingGroup {
  general('general', 'Général'),
  store('store', 'Boutique'),
  shipping('shipping', 'Livraison'),
  payment('payment', 'Paiement'),
  notifications('notifications', 'Notifications'),
  security('security', 'Sécurité'),
  seo('seo', 'SEO'),
  social('social', 'Réseaux sociaux'),
  email('email', 'Email'),
  api('api', 'API');

  final String code;
  final String displayName;

  const AdminSettingGroup(this.code, this.displayName);

  static AdminSettingGroup fromCode(String? code) {
    return AdminSettingGroup.values.firstWhere(
      (group) => group.code == code,
      orElse: () => AdminSettingGroup.general,
    );
  }
}

/// Entité représentant un paramètre de configuration
class AdminSetting {
  // ============================================
  // INFORMATIONS DE BASE
  // ============================================

  /// Identifiant unique
  final int id;

  /// Clé unique du paramètre (ex: "app_name", "currency")
  final String key;

  /// Valeur du paramètre (stockée en String)
  final String value;

  /// Groupe du paramètre
  final AdminSettingGroup group;

  /// Type de la valeur
  final AdminSettingType type;

  /// Description du paramètre
  final String? description;

  // ============================================
  // VISIBILITÉ
  // ============================================

  /// Paramètre public (visible par les clients) ?
  final bool isPublic;

  /// Paramètre actif ?
  final bool isActive;

  // ============================================
  // DATES
  // ============================================

  /// Date de création
  final DateTime createdAt;

  /// Date de dernière mise à jour
  final DateTime updatedAt;

  // ============================================
  // CONSTRUCTEUR
  // ============================================

  const AdminSetting({
    required this.id,
    required this.key,
    required this.value,
    required this.group,
    required this.type,
    this.description,
    this.isPublic = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // ============================================
  // GETTERS CALCULÉS
  // ============================================

  /// Vrai si le paramètre est du groupe général
  bool get isGeneral => group == AdminSettingGroup.general;

  /// Vrai si le paramètre est du groupe boutique
  bool get isStore => group == AdminSettingGroup.store;

  /// Vrai si le paramètre est du groupe livraison
  bool get isShipping => group == AdminSettingGroup.shipping;

  /// Vrai si le paramètre est du groupe paiement
  bool get isPayment => group == AdminSettingGroup.payment;

  /// Vrai si le paramètre est du groupe notifications
  bool get isNotifications => group == AdminSettingGroup.notifications;

  /// Vrai si le paramètre est du groupe sécurité
  bool get isSecurity => group == AdminSettingGroup.security;

  /// Vrai si le paramètre est du groupe SEO
  bool get isSeo => group == AdminSettingGroup.seo;

  /// Vrai si le paramètre est du groupe réseaux sociaux
  bool get isSocial => group == AdminSettingGroup.social;

  /// Vrai si le paramètre est du groupe email
  bool get isEmail => group == AdminSettingGroup.email;

  /// Vrai si le paramètre est du groupe API
  bool get isApi => group == AdminSettingGroup.api;

  /// Vrai si le paramètre est un booléen
  bool get isBoolean => type == AdminSettingType.boolean;

  /// Vrai si le paramètre est un nombre
  bool get isNumber => type == AdminSettingType.integer || type == AdminSettingType.float;

  /// Vrai si le paramètre est un texte
  bool get isString => type == AdminSettingType.string;

  /// Vrai si le paramètre est un fichier
  bool get isFile => type == AdminSettingType.file;

  /// Vrai si le paramètre est un JSON
  bool get isJson => type == AdminSettingType.json;

  /// Vrai si le paramètre est un tableau
  bool get isArray => type == AdminSettingType.array;

  /// Vrai si le paramètre est public
  bool get isPublicSetting => isPublic;

  /// Vrai si le paramètre est privé
  bool get isPrivate => !isPublic;

  /// Vrai si la valeur est vide
  bool get isEmpty => value.isEmpty;

  /// Vrai si la valeur n'est pas vide
  bool get isNotEmpty => value.isNotEmpty;

  /// Longueur de la valeur
  int get valueLength => value.length;

  /// Vrai si la valeur est "true" ou "1"
  bool get boolValue {
    return value.toLowerCase() == 'true' || value == '1';
  }

  /// Valeur convertie en entier
  int get intValue {
    return int.tryParse(value) ?? 0;
  }

  /// Valeur convertie en décimal
  double get doubleValue {
    return double.tryParse(value) ?? 0;
  }

  /// Valeur affichée (tronquée si trop longue)
  String get displayValue {
    if (isBoolean) {
      return boolValue ? '✅ Activé' : '❌ Désactivé';
    }
    if (isFile) {
      return '📁 $value';
    }
    if (value.length > 100) {
      return '${value.substring(0, 100)}...';
    }
    return value;
  }

  /// Clé affichée avec formatage
  String get displayKey {
    return key.replaceAll('_', ' ').toUpperCase();
  }

  /// Groupe avec emoji
  String get groupWithIcon {
    switch (group) {
      case AdminSettingGroup.general:
        return '⚙️ ${group.displayName}';
      case AdminSettingGroup.store:
        return '🏪 ${group.displayName}';
      case AdminSettingGroup.shipping:
        return '🚚 ${group.displayName}';
      case AdminSettingGroup.payment:
        return '💳 ${group.displayName}';
      case AdminSettingGroup.notifications:
        return '🔔 ${group.displayName}';
      case AdminSettingGroup.security:
        return '🔒 ${group.displayName}';
      case AdminSettingGroup.seo:
        return '🔍 ${group.displayName}';
      case AdminSettingGroup.social:
        return '📱 ${group.displayName}';
      case AdminSettingGroup.email:
        return '📧 ${group.displayName}';
      case AdminSettingGroup.api:
        return '🔌 ${group.displayName}';
    }
  }

  /// Type avec emoji
  String get typeWithIcon {
    switch (type) {
      case AdminSettingType.string:
        return '📝 ${type.displayName}';
      case AdminSettingType.integer:
        return '🔢 ${type.displayName}';
      case AdminSettingType.float:
        return '🔢 ${type.displayName}';
      case AdminSettingType.boolean:
        return '✅ ${type.displayName}';
      case AdminSettingType.json:
        return '📋 ${type.displayName}';
      case AdminSettingType.array:
        return '📊 ${type.displayName}';
      case AdminSettingType.file:
        return '📁 ${type.displayName}';
    }
  }

  /// Formatage de la date de mise à jour
  String get updatedAtFormatted => _formatDate(updatedAt);

  /// Formatage de la date de création
  String get createdAtFormatted => _formatDate(createdAt);

  /// Vrai si le paramètre a été modifié récemment (moins de 7 jours)
  bool get isRecentlyUpdated {
    final difference = DateTime.now().difference(updatedAt);
    return difference.inDays <= 7;
  }

  // ============================================
  // HELPERS PRIVÉS
  // ============================================

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
      'key': key,
      'value': value,
      'group': group.code,
      'type': type.code,
      'description': description,
      'is_public': isPublic,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crée une entité à partir d'une Map
  factory AdminSetting.fromJson(Map<String, dynamic> json) {
    return AdminSetting(
      id: (json['id'] as num?)?.toInt() ?? 0,
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      group: AdminSettingGroup.fromCode(json['group'] as String?),
      type: AdminSettingType.fromCode(json['type'] as String?),
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  // ============================================
  // COPYWITH
  // ============================================

  /// Crée une copie avec des champs modifiés
  AdminSetting copyWith({
    int? id,
    String? key,
    String? value,
    AdminSettingGroup? group,
    AdminSettingType? type,
    String? description,
    bool? isPublic,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminSetting(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      group: group ?? this.group,
      type: type ?? this.type,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================
  // ÉGALITÉ ET HASHCODE
  // ============================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminSetting && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  // ============================================
  // TOSTRING
  // ============================================

  @override
  String toString() {
    return 'AdminSetting(id: $id, key: $key, value: $displayValue, '
        'group: ${group.displayName}, type: ${type.displayName})';
  }
}