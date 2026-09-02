📦 FICHIER : docs/05-widgets.md

---

```markdown
# 🎨 WIDGETS RÉUTILISABLES - SHOPPRO

---

## 📋 LISTE DE TOUS LES WIDGETS PAR CATÉGORIE

---

## 🔐 AUTHENTIFICATION

### AuthTextField
- **Fichier** : `features/auth/presentation/widgets/auth_textfield.dart`
- **Usage** : Champ de texte avec icône et label
- **Options** : validator, keyboardType, suffixIcon

### PasswordTextField
- **Fichier** : `features/auth/presentation/widgets/password_textfield.dart`
- **Usage** : Champ mot de passe avec toggle visibilité
- **Options** : showStrengthIndicator

### PasswordStrengthIndicator
- **Fichier** : `features/auth/presentation/widgets/password_strength_indicator.dart`
- **Usage** : Indicateur de force du mot de passe
- **Options** : password (String)

### SocialButton
- **Fichier** : `features/auth/presentation/widgets/social_button.dart`
- **Usage** : Bouton connexion sociale
- **Options** : google, facebook, apple

### RoleBadge
- **Fichier** : `features/auth/presentation/widgets/role_badge.dart`
- **Usage** : Badge de rôle utilisateur

### RoleGuard
- **Fichier** : `features/auth/presentation/widgets/role_guard.dart`
- **Usage** : Protection conditionnelle par rôle

---

## 📦 PRODUITS

### ProductCard
- **Fichier** : `features/products/presentation/widgets/product_card.dart`
- **Usage** : Carte produit standard (verticale)
- **Options** : onTap, onAddToCart, onToggleFavorite

### ProductGridItem
- **Fichier** : `features/products/presentation/widgets/product_grid_item.dart`
- **Usage** : Élément de grille (2 colonnes)
- **Options** : onTap, onAddToCart

### ProductListItem
- **Fichier** : `features/products/presentation/widgets/product_list_item.dart`
- **Usage** : Élément de liste (horizontal)
- **Options** : onTap, onAddToCart

### ProductGallery
- **Fichier** : `features/products/presentation/widgets/product_gallery.dart`
- **Usage** : Galerie d'images avec zoom
- **Options** : showThumbnails, showDots, autoPlay

### DiscountBadge
- **Fichier** : `features/products/presentation/widgets/discount_badge.dart`
- **Usage** : Badge de réduction (-X%)
- **Options** : percentage, amount, size, style

### StockIndicator
- **Fichier** : `features/products/presentation/widgets/stock_indicator.dart`
- **Usage** : Indicateur de stock
- **Options** : dot, badge, progress

### FeaturedBadge
- **Fichier** : `features/products/presentation/widgets/featured_badge.dart`
- **Usage** : Badge "Vedette"

### NewBadge
- **Fichier** : `features/products/presentation/widgets/new_badge.dart`
- **Usage** : Badge "Nouveau"

### PriceDisplay
- **Fichier** : `features/products/presentation/widgets/price_display.dart`
- **Usage** : Affichage simple du prix

### DiscountPriceDisplay
- **Fichier** : `features/products/presentation/widgets/discount_price_display.dart`
- **Usage** : Prix avec réduction (ancien, nouveau, %)

### ShimmerProductCard
- **Fichier** : `features/products/presentation/widgets/shimmer_product_card.dart`
- **Usage** : Animation de chargement
- **Variantes** : ShimmerProductGrid, ShimmerProductList, ShimmerProductHorizontal

### VariationSelector
- **Fichier** : `features/products/presentation/widgets/variation_selector.dart`
- **Usage** : Sélection couleur/taille

### QuantitySelector
- **Fichier** : `features/products/presentation/widgets/quantity_selector.dart`
- **Usage** : Sélecteur de quantité

### SpecificationsSection
- **Fichier** : `features/products/presentation/widgets/specifications_section.dart`
- **Usage** : Tableau des spécifications

### ReviewsSection
- **Fichier** : `features/products/presentation/widgets/reviews_section.dart`
- **Usage** : Section des avis

### ReviewCard
- **Fichier** : `features/products/presentation/widgets/review_card.dart`
- **Usage** : Carte d'avis individuel

### RecentlyViewedSection
- **Fichier** : `features/products/presentation/widgets/recently_viewed_section.dart`
- **Usage** : Produits récemment consultés

---

## 🏷️ CATÉGORIES

### CategoryChip
- **Fichier** : `features/categories/presentation/widgets/category_chip.dart`
- **Usage** : Chip de catégorie sélectionnable

### CategoryListItem
- **Fichier** : `features/categories/presentation/widgets/category_list_item.dart`
- **Usage** : Élément de liste catégorie

### CategoryHeader
- **Fichier** : `features/categories/presentation/widgets/category_header.dart`
- **Usage** : Header avec image de catégorie

### SubcategoryChip
- **Fichier** : `features/categories/presentation/widgets/subcategory_chip.dart`
- **Usage** : Chip de sous-catégorie

### FilterBar
- **Fichier** : `features/categories/presentation/widgets/filter_bar.dart`
- **Usage** : Barre de filtres et tri

### SortSheet
- **Fichier** : `features/categories/presentation/widgets/sort_sheet.dart`
- **Usage** : Bottom sheet de tri

### FilterSheet
- **Fichier** : `features/categories/presentation/widgets/filter_sheet.dart`
- **Usage** : Bottom sheet de filtres

---

## 🔍 RECHERCHE

### CustomSearchBar
- **Fichier** : `features/search/presentation/widgets/search_bar.dart`
- **Usage** : Barre de recherche avec debounce

### SearchHistory
- **Fichier** : `features/search/presentation/widgets/search_history.dart`
- **Usage** : Historique des recherches

### SearchSuggestions
- **Fichier** : `features/search/presentation/widgets/search_suggestions.dart`
- **Usage** : Suggestions en temps réel

---

## 🛒 PANIER

### CartItemWidget
- **Fichier** : `features/cart/presentation/widgets/cart_item_widget.dart`
- **Usage** : Élément du panier

### CartSummary
- **Fichier** : `features/cart/presentation/widgets/cart_summary.dart`
- **Usage** : Récapitulatif des totaux

### CouponField
- **Fichier** : `features/cart/presentation/widgets/coupon_field.dart`
- **Usage** : Champ code promo

### EmptyCart
- **Fichier** : `features/cart/presentation/widgets/empty_cart.dart`
- **Usage** : État vide du panier

### FreeShippingProgress
- **Fichier** : `features/cart/presentation/widgets/free_shipping_progress.dart`
- **Usage** : Barre progression livraison gratuite

### CartBadge
- **Fichier** : `features/cart/presentation/widgets/cart_badge.dart`
- **Usage** : Badge compteur panier

---

## ❤️ FAVORIS

### FavoriteItemWidget
- **Fichier** : `features/favorites/presentation/widgets/favorite_item_widget.dart`
- **Usage** : Élément favori

### EmptyFavorites
- **Fichier** : `features/favorites/presentation/widgets/empty_favorites.dart`
- **Usage** : État vide des favoris

### FavoriteBadge
- **Fichier** : `features/favorites/presentation/widgets/favorite_badge.dart`
- **Usage** : Badge compteur favoris

---

## 📦 COMMANDES

### OrderCard
- **Fichier** : `features/orders/presentation/widgets/order_card.dart`
- **Usage** : Carte de commande

### OrderStatusBadge
- **Fichier** : `features/orders/presentation/widgets/order_status_badge.dart`
- **Usage** : Badge de statut avec couleur

### OrderTimeline
- **Fichier** : `features/orders/presentation/widgets/order_timeline.dart`
- **Usage** : Timeline de suivi

### EmptyOrders
- **Fichier** : `features/orders/presentation/widgets/empty_orders.dart`
- **Usage** : État vide des commandes

### AddressSelector
- **Fichier** : `features/orders/presentation/widgets/address_selector.dart`
- **Usage** : Sélection d'adresse

### ShippingSelector
- **Fichier** : `features/orders/presentation/widgets/shipping_selector.dart`
- **Usage** : Sélection de livraison

### PaymentSelector
- **Fichier** : `features/orders/presentation/widgets/payment_selector.dart`
- **Usage** : Sélection de paiement

---

## 🧭 NAVIGATION

### RoleBasedNavigation
- **Fichier** : `features/navigation/presentation/widgets/role_based_navigation.dart`
- **Usage** : Bottom navigation selon rôle

### RoleBasedAppBar
- **Fichier** : `features/navigation/presentation/widgets/role_based_appbar.dart`
- **Usage** : AppBar selon rôle

### RoleBasedDrawer
- **Fichier** : `features/navigation/presentation/widgets/role_based_drawer.dart`
- **Usage** : Drawer selon rôle

---

## 🏠 HOME

### HomeAppBar
- **Fichier** : `features/home/presentation/widgets/home_appbar.dart`
- **Usage** : AppBar avec recherche et badges

### BannerCarousel
- **Fichier** : `features/home/presentation/widgets/banner_carousel.dart`
- **Usage** : Carousel de bannières

### CategoryGrid
- **Fichier** : `features/home/presentation/widgets/category_grid.dart`
- **Usage** : Grille des catégories

---

## 📊 TOTAL : ~60 WIDGETS
```

---

📋 RÉSUMÉ

Ce fichier documente :

· ✅ Tous les widgets par catégorie
· ✅ Leurs fichiers
· ✅ Leurs usages
· ✅ Leurs options

---

---

## 🔄 WIDGETS AJOUTÉS (31/08/2026)

### 💳 Paiement
- **PaymentMethodCard** : Carte de méthode de paiement
- **PaymentSummary** : Résumé du paiement
- **PaymentConfirmationDialog** : Dialog de confirmation

### 🔔 Notifications
- **NotificationCard** : Carte de notification
- **NotificationBadge** : Badge compteur
- **EmptyNotifications** : État vide

### 📦 Stock
- **StockIndicatorWidget** : Indicateur de stock avec barre
- **StockMovementCard** : Carte de mouvement
- **StockAlertBanner** : Bannière d'alerte

### 🏠 Home (nouveaux)
- **FlashSaleSection** : Section avec timer
- **BestSellersSection** : Section avec badges
- **RecommendedSection** : Section recommandés
- **AdBanner** : Bannière publicitaire
- **BlogSection** : Section blog
- **BlogCard** : Carte d'article
- **DynamicSections** : Sections configurables
- **DynamicSectionItem** : Item de section

### 📍 Adresses
- **AddressCard** : Carte d'adresse
- **EmptyAddresses** : État vide
- **AddressTypeBadge** : Badge type