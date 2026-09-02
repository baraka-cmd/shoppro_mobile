📦 FICHIER : docs/02-structure.md

---

```markdown
# 📂 STRUCTURE COMPLÈTE DES FICHIERS - SHOPPRO

---

## 🌳 ARBORESCENCE COMPLÈTE

```

shoppro_mobile/
├── lib/
│   ├── main.dart                          # Point d'entrée
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart         # URLs et endpoints API
│   │   │   ├── app_colors.dart            # Couleurs
│   │   │   └── app_constants.dart         # Constantes globales
│   │   │
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Thème clair
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart            # Client Dio avec intercepteurs
│   │   │   └── secure_storage.dart        # Stockage sécurisé
│   │   │
│   │   ├── services/
│   │   │   ├── token_service.dart         # Gestion des tokens
│   │   │   ├── navigation_service.dart    # Navigation globale
│   │   │   └── upload_service.dart        # Upload de fichiers
│   │   │
│   │   ├── utils/
│   │   │   └── validators.dart            # Validateurs de formulaires
│   │   │
│   │   └── middleware/
│   │       └── auth_middleware.dart       # Vérification authentification
│   │
│   ├── features/
│   │   │
│   │   ├── auth/                          # 🔐 Authentification
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── user.dart
│   │   │   │   │   └── user_role.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   │   └── sources/
│   │   │   │       └── auth_api.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── splash_screen.dart
│   │   │       │   ├── onboarding_screen.dart
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   └── forgot_password_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── auth_textfield.dart
│   │   │       │   ├── password_textfield.dart
│   │   │       │   ├── social_button.dart
│   │   │       │   ├── role_badge.dart
│   │   │       │   ├── role_guard.dart
│   │   │       │   └── password_strength_indicator.dart
│   │   │       └── providers/
│   │   │           └── auth_provider.dart
│   │   │
│   │   ├── products/                      # 📦 Produits
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── product.dart
│   │   │   │   │   ├── product_image.dart
│   │   │   │   │   ├── category.dart
│   │   │   │   │   └── brand.dart
│   │   │   │   └── repositories/
│   │   │   │       └── product_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── product_model.dart
│   │   │   │   │   ├── product_image_model.dart
│   │   │   │   │   ├── category_model.dart
│   │   │   │   │   └── brand_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── product_repository_impl.dart
│   │   │   │   └── sources/
│   │   │   │       ├── product_api.dart
│   │   │   │       ├── category_api.dart
│   │   │   │       └── brand_api.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── product_list_screen.dart
│   │   │       │   ├── product_grid_screen.dart
│   │   │       │   └── product_detail_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── product_card.dart
│   │   │       │   ├── product_grid_item.dart
│   │   │       │   ├── product_list_item.dart
│   │   │       │   ├── product_gallery.dart
│   │   │       │   ├── discount_badge.dart
│   │   │       │   ├── stock_indicator.dart
│   │   │       │   ├── featured_badge.dart
│   │   │       │   ├── new_badge.dart
│   │   │       │   ├── price_display.dart
│   │   │       │   ├── discount_price_display.dart
│   │   │       │   ├── shimmer_product_card.dart
│   │   │       │   ├── featured_products_section.dart
│   │   │       │   ├── popular_products_section.dart
│   │   │       │   ├── recent_products_section.dart
│   │   │       │   ├── on_sale_products_section.dart
│   │   │       │   ├── variation_selector.dart
│   │   │       │   ├── quantity_selector.dart
│   │   │       │   ├── product_info_section.dart
│   │   │       │   ├── specifications_section.dart
│   │   │       │   ├── reviews_section.dart
│   │   │       │   ├── review_card.dart
│   │   │       │   ├── add_review_sheet.dart
│   │   │       │   ├── share_button.dart
│   │   │       │   └── recently_viewed_section.dart
│   │   │       └── providers/
│   │   │           ├── product_provider.dart
│   │   │           ├── category_provider.dart
│   │   │           └── brand_provider.dart
│   │   │
│   │   ├── categories/                    # 🏷️ Catégories
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── category_list_screen.dart
│   │   │       │   └── category_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── category_chip.dart
│   │   │           ├── category_list_item.dart
│   │   │           ├── category_header.dart
│   │   │           ├── subcategory_chip.dart
│   │   │           ├── filter_bar.dart
│   │   │           ├── sort_sheet.dart
│   │   │           └── filter_sheet.dart
│   │   │
│   │   ├── search/                        # 🔍 Recherche
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── search_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── search_bar.dart
│   │   │       │   ├── search_history.dart
│   │   │       │   └── search_suggestions.dart
│   │   │       └── providers/
│   │   │           └── search_provider.dart
│   │   │
│   │   ├── cart/                          # 🛒 Panier
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── cart.dart
│   │   │   │   │   └── cart_item.dart
│   │   │   │   └── repositories/
│   │   │   │       └── cart_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── cart_model.dart
│   │   │   │   │   └── cart_item_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── cart_repository_impl.dart
│   │   │   │   └── sources/
│   │   │   │       └── cart_local_data_source.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── cart_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── cart_item_widget.dart
│   │   │       │   ├── cart_summary.dart
│   │   │       │   ├── coupon_field.dart
│   │   │       │   ├── empty_cart.dart
│   │   │       │   ├── free_shipping_progress.dart
│   │   │       │   ├── cart_suggestions.dart
│   │   │       │   ├── cart_badge.dart
│   │   │       │   ├── add_to_cart_animation.dart
│   │   │       │   └── saved_for_later_section.dart
│   │   │       └── providers/
│   │   │           └── cart_provider.dart
│   │   │
│   │   ├── favorites/                     # ❤️ Favoris
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── favorite.dart
│   │   │   │   └── repositories/
│   │   │   │       └── favorite_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── favorite_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── favorite_repository_impl.dart
│   │   │   │   └── sources/
│   │   │   │       └── favorite_local_data_source.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   └── favorites_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── favorite_item_widget.dart
│   │   │       │   ├── empty_favorites.dart
│   │   │       │   └── favorite_badge.dart
│   │   │       └── providers/
│   │   │           └── favorite_provider.dart
│   │   │
│   │   ├── orders/                        # 📦 Commandes
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── order.dart
│   │   │   │   │   └── order_item.dart
│   │   │   │   └── repositories/
│   │   │   │       └── order_repository.dart
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── order_model.dart
│   │   │   │   │   └── order_item_model.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── order_repository_impl.dart
│   │   │   │   └── sources/
│   │   │   │       └── order_local_data_source.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── orders_screen.dart
│   │   │       │   ├── order_detail_screen.dart
│   │   │       │   └── checkout_screen.dart
│   │   │       ├── widgets/
│   │   │       │   ├── order_card.dart
│   │   │       │   ├── order_status_badge.dart
│   │   │       │   ├── order_timeline.dart
│   │   │       │   ├── empty_orders.dart
│   │   │       │   ├── address_selector.dart
│   │   │       │   ├── shipping_selector.dart
│   │   │       │   └── payment_selector.dart
│   │   │       └── providers/
│   │   │           └── order_provider.dart
│   │   │
│   │   ├── navigation/                    # 🧭 Navigation
│   │   │   └── presentation/
│   │   │       └── widgets/
│   │   │           ├── role_based_navigation.dart
│   │   │           ├── role_based_appbar.dart
│   │   │           ├── role_based_drawer.dart
│   │   │           └── role_dashboard.dart
│   │   │
│   │   ├── profile/                       # 👤 Profil
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── profile_screen.dart
│   │   │       │   ├── edit_profile_screen.dart
│   │   │       │   └── change_password_screen.dart
│   │   │       └── widgets/
│   │   │           ├── profile_header.dart
│   │   │           ├── profile_menu_item.dart
│   │   │           ├── profile_stats_card.dart
│   │   │           ├── edit_profile_form.dart
│   │   │           ├── profile_image_picker.dart
│   │   │           └── avatar_uploader.dart
│   │   │
│   │   └── home/                          # 🏠 Accueil
│   │       └── presentation/
│   │           ├── pages/
│   │           │   └── home_screen.dart
│   │           └── widgets/
│   │               ├── home_appbar.dart
│   │               ├── banner_carousel.dart
│   │               └── category_grid.dart
│   │
│   └── routes/
│       ├── app_routes.dart                # Définition des routes
│       └── route_generator.dart           # Génération des routes
│
├── assets/
│   └── images/                            # Images locales
│
├── pubspec.yaml                           # Dépendances
└── analysis_options.yaml                  # Lint rules

```

---

## 📊 STATISTIQUES

| Dossier | Nombre de fichiers |
|---------|-------------------|
| core/ | ~12 fichiers |
| auth/ | ~15 fichiers |
| products/ | ~30 fichiers |
| categories/ | ~10 fichiers |
| search/ | ~6 fichiers |
| cart/ | ~15 fichiers |
| favorites/ | ~10 fichiers |
| orders/ | ~15 fichiers |
| navigation/ | ~5 fichiers |
| profile/ | ~10 fichiers |
| home/ | ~5 fichiers |
| routes/ | 2 fichiers |
| **TOTAL** | **~135 fichiers Dart** |
```

---

📋 RÉSUMÉ

Ce fichier documente :

· ✅ Arborescence complète
· ✅ Chaque fichier et son rôle
· ✅ Organisation par feature
· ✅ Statistiques des fichiers

---

## 🔄 NOUVEAUX DOSSIERS (31/08/2026)

```

features/
├── payment/                 # 💳 Paiement (10 fichiers)
├── notifications/           # 🔔 Notifications (10 fichiers)
├── stock/                   # 📦 Stocks (12 fichiers)
├── addresses/               # 📍 Adresses (11 fichiers)
└── home/
├── data/
│   ├── models/banner_model.dart
│   └── sources/banner_api.dart
└── presentation/
├── providers/banner_provider.dart
└── widgets/
├── flash_sale_section.dart
├── best_sellers_section.dart
├── recommended_section.dart
├── ad_banner.dart
├── blog_section.dart
├── blog_card.dart
├── dynamic_sections.dart
└── dynamic_section_item.dart

```
```

---
