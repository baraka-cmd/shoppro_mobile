// Enumération des rôles utilisateur
// Définit les rôles disponibles et leurs propriétés

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum UserRole {
  admin,
  seller,
  client,
  guest;

  /// Récupérer le rôle depuis une chaîne
  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'seller':
      case 'vendeur':
        return UserRole.seller;
      case 'client':
        return UserRole.client;
      default:
        return UserRole.guest;
    }
  }

  /// Récupérer le rôle depuis une liste de rôles
  static UserRole fromList(List<String>? roles) {
    if (roles == null || roles.isEmpty) {
      return UserRole.guest;
    }

    if (roles.contains('admin')) {
      return UserRole.admin;
    }

    if (roles.contains('seller')) {
      return UserRole.seller;
    }

    if (roles.contains('client')) {
      return UserRole.client;
    }

    return UserRole.guest;
  }

  /// Libellé en français
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.seller:
        return 'Vendeur';
      case UserRole.client:
        return 'Client';
      case UserRole.guest:
        return 'Visiteur';
    }
  }

  /// Libellé court
  String get shortLabel {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.seller:
        return 'Vendeur';
      case UserRole.client:
        return 'Client';
      case UserRole.guest:
        return 'Invité';
    }
  }

  /// Icône du rôle
  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.seller:
        return Icons.storefront;
      case UserRole.client:
        return Icons.person;
      case UserRole.guest:
        return Icons.person_outline;
    }
  }

  /// Couleur principale du rôle
  Color get color {
    switch (this) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.seller:
        return AppColors.warning;
      case UserRole.client:
        return AppColors.primary;
      case UserRole.guest:
        return AppColors.textSecondary;
    }
  }

  /// Couleur de fond du badge
  Color get backgroundColor {
    switch (this) {
      case UserRole.admin:
        return AppColors.error.withValues(alpha: 0.1);
      case UserRole.seller:
        return AppColors.warning.withValues(alpha: 0.1);
      case UserRole.client:
        return AppColors.primary.withValues(alpha: 0.1);
      case UserRole.guest:
        return AppColors.textSecondary.withValues(alpha: 0.1);
    }
  }

  /// Niveau hiérarchique
  int get level {
    switch (this) {
      case UserRole.admin:
        return 100;
      case UserRole.seller:
        return 50;
      case UserRole.client:
        return 10;
      case UserRole.guest:
        return 0;
    }
  }

  /// Vérifier si c'est un admin
  bool get isAdmin => this == UserRole.admin;

  /// Vérifier si c'est un vendeur
  bool get isSeller => this == UserRole.seller;

  /// Vérifier si c'est un client
  bool get isClient => this == UserRole.client;

  /// Vérifier si c'est un invité
  bool get isGuest => this == UserRole.guest;

  /// Vérifier si le rôle a un niveau minimum
  bool hasMinLevel(int minLevel) => level >= minLevel;

  /// Vérifier si le rôle est supérieur ou égal à un autre
  bool isAtLeast(UserRole other) => level >= other.level;

  /// Vérifier si le rôle est inférieur à un autre
  bool isBelow(UserRole other) => level < other.level;

  /// Vérifier si le rôle a accès admin
  bool get hasAdminAccess => level >= UserRole.admin.level;

  /// Vérifier si le rôle a accès vendeur
  bool get hasSellerAccess => level >= UserRole.seller.level;

  /// Vérifier si le rôle a accès client
  bool get hasClientAccess => level >= UserRole.client.level;

  /// Liste des permissions du rôle
  List<String> get permissions {
    switch (this) {
      case UserRole.admin:
        return [
          'create-product',
          'read-product',
          'update-product',
          'delete-product',
          'create-order',
          'read-order',
          'update-order',
          'delete-order',
          'create-user',
          'read-user',
          'update-user',
          'delete-user',
          'manage-settings',
        ];
      case UserRole.seller:
        return [
          'create-product',
          'read-product',
          'update-product',
          'read-order',
          'update-order',
        ];
      case UserRole.client:
        return [
          'read-product',
          'create-order',
          'read-order',
        ];
      case UserRole.guest:
        return [
          'read-product',
        ];
    }
  }

  /// Vérifier si le rôle a une permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Vérifier si le rôle a plusieurs permissions
  bool hasAnyPermission(List<String> permissionsList) {
    return permissionsList.any((permission) => hasPermission(permission));
  }

  /// Vérifier si le rôle a toutes les permissions
  bool hasAllPermissions(List<String> permissionsList) {
    return permissionsList.every((permission) => hasPermission(permission));
  }
}