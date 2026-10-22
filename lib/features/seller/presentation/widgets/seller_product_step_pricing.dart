// ============================================
// WIDGET : SellerProductStepPricing
// ============================================
// Étape 3 du formulaire produit : Prix, Stock & SKU.
//
// Contient :
//   - Prix normal (obligatoire)
//   - Prix réduit (optionnel, avec aperçu de la réduction)
//   - Stock initial (obligatoire)
//   - Stock minimum pour alerte (optionnel)
//   - SKU / Code unique (obligatoire)
//   - Code-barres EAN/UPC (optionnel)
//
// Design :
//   - Champs de prix avec préfixe "FCFA"
//   - Aperçu en temps réel de la réduction (-X%)
//   - Cartes de section (Prix / Stock / Identifiants)
//   - Compteur de caractères sur le SKU
//   - Validation inline
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Presentation
import 'seller_form_field.dart';
import '../pages/seller_product_form_state.dart';

// ============================================
// WIDGET PRINCIPAL
// ============================================

class SellerProductStepPricing extends StatefulWidget {
  /// State du formulaire (source de vérité).
  final SellerProductFormState formState;

  const SellerProductStepPricing({
    super.key,
    required this.formState,
  });

  @override
  State<SellerProductStepPricing> createState() =>
      _SellerProductStepPricingState();
}

class _SellerProductStepPricingState extends State<SellerProductStepPricing> {
  // Pour rafraîchir l'aperçu de la réduction en temps réel
  double? _discountPercent;

  @override
  void initState() {
    super.initState();
    widget.formState.priceController.addListener(_updateDiscountPercent);
    widget.formState.discountPriceController.addListener(_updateDiscountPercent);
    _updateDiscountPercent();
  }

  @override
  void dispose() {
    widget.formState.priceController.removeListener(_updateDiscountPercent);
    widget.formState.discountPriceController.removeListener(_updateDiscountPercent);
    super.dispose();
  }

  void _updateDiscountPercent() {
    final price = double.tryParse(widget.formState.priceController.text.trim());
    final discount = double.tryParse(
      widget.formState.discountPriceController.text.trim(),
    );

    if (price == null || price <= 0 || discount == null || discount <= 0) {
      if (mounted) setState(() => _discountPercent = null);
      return;
    }

    if (discount >= price) {
      if (mounted) setState(() => _discountPercent = null);
      return;
    }

    final percent = ((price - discount) / price) * 100;
    if (mounted) setState(() => _discountPercent = percent);
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: widget.formState.pricingFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(),

            const SizedBox(height: 24),

            // ============================================
            // SECTION PRIX
            // ============================================
            _buildSection(
              icon: Icons.payments_outlined,
              title: 'Prix',
              subtitle: 'Définissez le prix de vente',
              children: [
                // Prix normal
                SellerFormField(
                  label: 'Prix normal',
                  hint: 'Ex: 15000',
                  helperText: 'Le prix auquel vous vendez ce produit',
                  controller: widget.formState.priceController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  inputFormatters: SellerProductFormState.priceInputFormatters,
                  suffixWidget: _buildSuffixUnit('FCFA'),
                  validator: widget.formState.validatePrice,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Prix réduit
                SellerFormField(
                  label: 'Prix réduit',
                  hint: 'Ex: 12000',
                  helperText:
                      'Laissez vide si pas de promotion (doit être < prix normal)',
                  controller: widget.formState.discountPriceController,
                  keyboardType: TextInputType.number,
                  isRequired: false,
                  inputFormatters: SellerProductFormState.priceInputFormatters,
                  suffixWidget: _buildSuffixUnit('FCFA'),
                  validator: widget.formState.validateDiscountPrice,
                  textInputAction: TextInputAction.next,
                ),

                // Aperçu de la réduction
                if (_discountPercent != null) ...[
                  const SizedBox(height: 12),
                  _buildDiscountPreview(),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // ============================================
            // SECTION STOCK
            // ============================================
            _buildSection(
              icon: Icons.inventory_2_outlined,
              title: 'Stock',
              subtitle: 'Quantité disponible à la vente',
              children: [
                // Stock
                SellerFormField(
                  label: 'Stock initial',
                  hint: 'Ex: 50',
                  helperText: 'Nombre d\'unités disponibles',
                  controller: widget.formState.stockController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  inputFormatters: SellerProductFormState.numberInputFormatters,
                  suffixWidget: _buildSuffixUnit('unités'),
                  validator: widget.formState.validateStock,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Stock minimum
                SellerFormField(
                  label: 'Stock minimum',
                  hint: 'Ex: 5',
                  helperText:
                      'Vous serez alerté quand le stock descend sous ce seuil',
                  controller: widget.formState.minStockController,
                  keyboardType: TextInputType.number,
                  isRequired: false,
                  inputFormatters: SellerProductFormState.numberInputFormatters,
                  suffixWidget: _buildSuffixUnit('unités'),
                  validator: widget.formState.validateMinStock,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ============================================
            // SECTION IDENTIFIANTS
            // ============================================
            _buildSection(
              icon: Icons.qr_code_2_rounded,
              title: 'Identifiants',
              subtitle: 'Références uniques du produit',
              children: [
                // SKU
                SellerFormField(
                  label: 'SKU (code unique)',
                  hint: 'Ex: IPHONE-15-001',
                  helperText:
                      'Référence interne du produit (lettres, chiffres, tirets)',
                  controller: widget.formState.skuController,
                  isRequired: true,
                  maxLength: 100,
                  inputFormatters: SellerProductFormState.skuInputFormatters,
                  prefixIcon: Icons.tag_rounded,
                  showClearButton: true,
                  validator: widget.formState.validateSku,
                  textInputAction: TextInputAction.next,
                ),

                // ✅ Bouton "Regénérer un SKU"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      widget.formState.regenerateSku();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    label: const Text(
                      'Regénérer un SKU',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Code-barres
                SellerFormField(
                  label: 'Code-barres (EAN/UPC)',
                  hint: 'Ex: 1234567890123',
                  helperText: 'Optionnel, utile pour scanner le produit',
                  controller: widget.formState.barcodeController,
                  keyboardType: TextInputType.number,
                  isRequired: false,
                  maxLength: 100,
                  prefixIcon: Icons.qr_code_scanner_rounded,
                  showClearButton: true,
                  textInputAction: TextInputAction.done,
                ),
              ],
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
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.payments_outlined,
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
                'Prix & Stock',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Finalisez la commercialisation',
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
    );
  }

  // ============================================
  // SECTION CARD
  // ============================================

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ============================================
  // SUFFIX UNIT
  // ============================================

  Widget _buildSuffixUnit(String unit) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        unit,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.warning,
        ),
      ),
    );
  }

  // ============================================
  // APERÇU DE LA RÉDUCTION
  // ============================================

  Widget _buildDiscountPreview() {
    final price = double.tryParse(widget.formState.priceController.text.trim());
    final discount =
        double.tryParse(widget.formState.discountPriceController.text.trim());

    if (price == null || discount == null) return const SizedBox.shrink();

    final savings = price - discount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.promoGradient.colors.first.withValues(alpha: 0.08),
            AppColors.promoGradient.colors.last.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.promo.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.promo,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '-${_discountPercent!.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Promotion appliquée',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.promoDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Économie client : ${_formatPrice(savings)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  String _formatPrice(double amount) {
    final buffer = StringBuffer();
    final str = amount.toStringAsFixed(0);

    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      final remaining = str.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(' ');
      }
    }

    return '${buffer.toString()} FCFA';
  }
}