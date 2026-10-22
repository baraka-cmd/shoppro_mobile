// ============================================
// WIDGET : SellerProductStepInfo
// ============================================
// Étape 1 du formulaire produit : Informations de base.
//
// Contient :
//   - Nom du produit (obligatoire)
//   - Catégorie (dropdown, obligatoire)
//   - Marque (dropdown, optionnel)
//   - Description courte (optionnelle, max 200 caractères)
//   - Description complète (optionnelle, textarea)
//
// Design :
//   - Champs aérés avec SellerFormField
//   - Dropdown custom stylé (mêmes couleurs que les champs)
//   - Scroll vertical pour petits écrans
//   - Padding uniforme avec les autres étapes
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Domain
import '../../domain/entities/seller_product.dart';

// Presentation
import 'seller_form_field.dart';
import '../pages/seller_product_form_state.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerProductStepInfo extends StatelessWidget {
  /// State du formulaire (source de vérité).
  final SellerProductFormState formState;

  /// Liste des catégories disponibles (chargées par le parent).
  final List<SellerProductCategory> categories;

  /// Liste des marques disponibles (chargées par le parent).
  final List<SellerProductBrand> brands;

  /// Indique si les catégories/marques sont en cours de chargement.
  final bool isLoadingMetadata;

  /// Callback quand la catégorie change.
  final void Function(int?)? onCategoryChanged;

  /// Callback quand la marque change.
  final void Function(int?)? onBrandChanged;

  /// Callback pour recharger les métadonnées (catégories/marques).
  final VoidCallback? onReloadMetadata;

  const SellerProductStepInfo({
    super.key,
    required this.formState,
    this.categories = const [],
    this.brands = const [],
    this.isLoadingMetadata = false,
    this.onCategoryChanged,
    this.onBrandChanged,
    this.onReloadMetadata,
  });

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formState.infoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // EN-TÊTE DE L'ÉTAPE
            // ============================================
            _buildHeader(),

            const SizedBox(height: 24),

            // ============================================
            // NOM DU PRODUIT
            // ============================================
            SellerFormField(
              label: 'Nom du produit',
              hint: 'Ex: iPhone 15 Pro Max 256 Go',
              controller: formState.nameController,
              isRequired: true,
              maxLength: 255,
              prefixIcon: Icons.inventory_2_outlined,
              showClearButton: true,
              validator: formState.validateName,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 20),

            // ============================================
            // CATÉGORIE
            // ============================================
            _buildCategoryDropdown(context),

            const SizedBox(height: 20),

            // ============================================
            // MARQUE
            // ============================================
            _buildBrandDropdown(context),

            const SizedBox(height: 20),

            // ============================================
            // DESCRIPTION COURTE
            // ============================================
            SellerFormField(
              label: 'Description courte',
              hint: 'Résumé en une phrase (optionnel)',
              helperText: 'Apparaîtra dans les listes et résultats de recherche',
              controller: formState.shortDescriptionController,
              isRequired: false,
              maxLines: 2,
              maxLength: 200,
              showClearButton: true,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 20),

            // ============================================
            // DESCRIPTION COMPLÈTE
            // ============================================
            SellerFormField(
              label: 'Description complète',
              hint:
                  'Décrivez votre produit : caractéristiques, avantages, utilisation...',
              helperText:
                  'Une description détaillée améliore vos chances de vente',
              controller: formState.descriptionController,
              isRequired: false,
              maxLines: 8,
              maxLength: 5000,
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ============================================
  // EN-TÊTE
  // ============================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de base',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Présentez votre produit aux clients',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // DROPDOWN CATÉGORIE
  // ============================================

  Widget _buildCategoryDropdown(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel('Catégorie', isRequired: true),
      const SizedBox(height: 8),
      if (isLoadingMetadata)
        _buildMetadataLoading()
      else if (categories.isEmpty)
        _buildMetadataEmpty(
          onReload: onReloadMetadata,
          message: 'Aucune catégorie disponible',
        )
      else
        _buildDropdown<int>(
          context: context, // ✅ Fonctionne maintenant
          value: formState.selectedCategoryId,
          hint: 'Sélectionner une catégorie',
          prefixIcon: Icons.category_outlined,
          items: categories.map((cat) {
            return DropdownMenuItem<int>(
              value: cat.id,
              child: Text(
                cat.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            formState.selectedCategoryId = value;
            onCategoryChanged?.call(value);
          },
        ),
    ],
  );
}

Widget _buildBrandDropdown(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _buildLabel('Marque', isRequired: false),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Optionnel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (isLoadingMetadata)
        _buildMetadataLoading()
      else if (brands.isEmpty)
        _buildMetadataEmpty(
          onReload: onReloadMetadata,
          message: 'Aucune marque disponible',
        )
      else
        _buildDropdown<int>(
          context: context, // ✅ Fonctionne maintenant
          value: formState.selectedBrandId,
          hint: 'Sélectionner une marque',
          prefixIcon: Icons.business_outlined,
          items: brands.map((brand) {
            return DropdownMenuItem<int>(
              value: brand.id,
              child: Text(
                brand.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            formState.selectedBrandId = value;
            onBrandChanged?.call(value);
          },
        ),
    ],
  );
}

  // ============================================
  // DROPDOWN GÉNÉRIQUE
  // ============================================

  Widget _buildDropdown<T>({
  required BuildContext context,
  required T? value,
  required String hint,
  required IconData prefixIcon,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: AppColors.textTertiary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              prefixIcon,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.warning,
              width: 1.5,
            ),
          ),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: 350,
      ),
    ),
  );
}


  // ============================================
  // HELPERS UI
  // ============================================

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 2),
          const Text(
            '*',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataLoading() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.warning,
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataEmpty({
    required String message,
    required VoidCallback? onReload,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warningDark,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.warningDark,
              ),
            ),
          ),
          if (onReload != null)
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: AppColors.warningDark,
              ),
              onPressed: onReload,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }
}