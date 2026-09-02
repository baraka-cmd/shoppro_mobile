📦 FICHIER : docs/07-prochaines-etapes.md

---

```markdown
# 🚀 PROCHAINES ÉTAPES - SHOPPRO

---

## 📋 ORDRE DE PRIORITÉ

### 🔴 PRIORITÉ HAUTE (Corrections immédiates)

1. **Activer le bouton favori dans ProductDetailScreen**
   - Fichier : `features/products/presentation/pages/product_detail_screen.dart`
   - Ajouter l'appel à `FavoriteProvider.toggleFavorite()`

2. **Corriger l'onglet Profil**
   - Fichier : `features/home/presentation/pages/home_screen.dart`
   - Remplacer SnackBar par navigation vers `/profile`

3. **Ajouter le bouton "Mes Commandes" dans Home**
   - Fichier : `features/home/presentation/pages/home_screen.dart`
   - Ajouter une section de navigation vers `/orders`

4. **Corriger les overflow dans CartScreen**
   - Fichier : `features/cart/presentation/widgets/cart_item_widget.dart`
   - Ajouter `Flexible` sur les textes de prix

---

### 🟡 PRIORITÉ MOYENNE (Phase 9 : Adresses)

1. **Créer AddressListScreen**
   - Liste des adresses
   - Ajout/Modification/Suppression
   - Adresse par défaut

2. **Créer AddressFormScreen**
   - Formulaire d'adresse
   - Validation
   - Géolocalisation

3. **Files à créer**
```

features/addresses/
├── domain/
│   ├── entities/address.dart
│   └── repositories/address_repository.dart
├── data/
│   ├── models/address_model.dart
│   ├── repositories/address_repository_impl.dart
│   └── sources/address_local_data_source.dart
└── presentation/
├── pages/address_list_screen.dart
├── pages/address_form_screen.dart
├── widgets/address_card.dart
└── providers/address_provider.dart

```

---

### 🟡 PRIORITÉ MOYENNE (Phase 10 : Paiement)

1. **Intégrer Mobile Money**
   - MTN Mobile Money
   - Orange Money
   - API de paiement

2. **Intégrer Stripe**
   - Paiement par carte
   - Webhook de confirmation

3. **Files à créer**
```

features/payment/
├── domain/
│   ├── entities/payment.dart
│   └── repositories/payment_repository.dart
├── data/
│   ├── models/payment_model.dart
│   ├── repositories/payment_repository_impl.dart
│   └── sources/payment_api.dart
└── presentation/
├── pages/payment_screen.dart
├── widgets/payment_method_card.dart
└── providers/payment_provider.dart

```

---

### 🟡 PRIORITÉ MOYENNE (Phase 11 : Notifications)

1. **Notifications locales**
   - Notifications de commande
   - Notifications de livraison

2. **Push notifications**
   - Firebase Cloud Messaging
   - Token device

3. **Files à créer**
```

features/notifications/
├── presentation/
│   ├── pages/notifications_screen.dart
│   ├── widgets/notification_card.dart
│   └── providers/notification_provider.dart
└── services/
└── notification_service.dart

```

---

### 🟠 PRIORITÉ IMPORTANTE (Phase 12 : Dashboard Admin)

1. **Dashboard Admin**
   - Statistiques (produits, commandes, utilisateurs)
   - CRUD produits
   - CRUD catégories
   - Gestion utilisateurs

2. **Files à créer**
```

features/admin/
├── presentation/
│   ├── pages/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_products_screen.dart
│   │   ├── admin_users_screen.dart
│   │   └── admin_orders_screen.dart
│   └── widgets/
│       ├── admin_stat_card.dart
│       └── admin_product_table.dart
└── providers/
└── admin_provider.dart

```

---

### 🟠 PRIORITÉ IMPORTANTE (Phase 13 : Dashboard Vendeur)

1. **Dashboard Vendeur**
   - Mes produits (CRUD)
   - Commandes reçues
   - Statistiques de vente

2. **Files à créer**
```

features/seller/
├── presentation/
│   ├── pages/
│   │   ├── seller_dashboard_screen.dart
│   │   ├── seller_products_screen.dart
│   │   ├── seller_orders_screen.dart
│   │   └── seller_stats_screen.dart
│   └── widgets/
│       ├── seller_stat_card.dart
│       └── seller_product_card.dart
└── providers/
└── seller_provider.dart

```

---

### 🟢 PRIORITÉ BASSE (Phase 14 : Optimisation)

1. **Tests**
   - Tests unitaires
   - Tests de widgets

2. **Performance**
   - Optimisation des listes
   - Cache des images

3. **Sécurité**
   - Validation des entrées
   - Rate limiting

---

### 🟢 PRIORITÉ BASSE (Phase 15 : Déploiement)

1. **Génération APK**
   ```bash
   flutter build apk --release
```

2. Publication Play Store
   · Icône
   · Captures d'écran
   · Description
   · Version

---

📝 NOTE POUR LE NOUVEAU CHAT

Quand tu reprends dans un nouveau chat :

1. Lis tous les fichiers dans docs/
2. Commence par les corrections HAUTE priorité
3. Puis continue avec les phases dans l'ordre
4. Garde la même architecture (Clean Architecture)
5. Utilise les mêmes conventions (Poppins, couleurs, patterns)

```

---

## 📋 RÉSUMÉ

Ce fichier documente :
- ✅ Les corrections prioritaires
- ✅ Les phases futures
- ✅ Les fichiers à créer
- ✅ L'ordre de priorité

---

## 🔄 MISE À JOUR (31/08/2026)

### ✅ Phases terminées depuis la dernière doc :
- Phase 9 : Adresses
- Phase 10 : Paiement (simulation)
- Phase 11 : Notifications
- Phase 12 : Dashboard Home complet
- Phase 13 : Stocks (structure)

### 🔴 PRIORITÉS ACTUELLES :

1. **Dashboard Admin**
   - CRUD produits, catégories, bannières
   - Gestion utilisateurs
   - Statistiques

2. **Dashboard Vendeur**
   - Mes produits
   - Mes stocks
   - Commandes reçues

3. **Redirection par rôle après login**
   - Client → Home
   - Vendeur → Dashboard vendeur
   - Admin → Dashboard admin
```

---
