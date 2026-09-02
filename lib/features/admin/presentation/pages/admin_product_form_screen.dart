// ============================================
// PAGE : AdminProductFormScreen
// ============================================
// Écran de création/modification de produit.
// Design moderne avec formulaire organisé en sections.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Formulaire en carte
// - Sections : Infos, Prix, Stock, Images
// - Boutons Annuler / Enregistrer
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Providers (même feature admin)
import '../providers/admin_product_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../../../products/domain/entities/product.dart';
import '../providers/admin_product_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de formulaire produit.
///
/// Permet de :
/// - Créer un nouveau produit
/// - Modifier un produit existant
class AdminProductFormScreen extends StatefulWidget {
  /// ID du produit à modifier (null = création)
  final int? productId;

  const AdminProductFormScreen({super.key, this.productId});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _skuController = TextEditingController();

  // ============================================
  // ÉTAT
  // ============================================

  bool _isSaving = false;
  bool _isEditMode = false;
  String? _selectedCategory;
  String? _selectedBrand;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isOnSale = false;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    if (_isEditMode) {
      // Charger les données du produit existant
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadProduct() async {
  try {
    final provider = context.read<AdminProductProvider>();
    final productId = widget.productId;

    if (productId == null) return;

    // Chercher le produit dans la liste déjà chargée
    final product = provider.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Produit introuvable'),
    );

    setState(() {
      _nameController.text = product.name;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      _discountPriceController.text = product.discountPrice?.toString() ?? '';
      _stockController.text = product.stock.toString();
      _minStockController.text = product.minStock.toString();
      _skuController.text = product.sku;
      _selectedCategory = product.category?.name;
      _selectedBrand = product.brand?.name;
      _isActive = product.isActive;
      _isFeatured = product.isFeatured;
      _isOnSale = product.isOnSale;
    });
  } catch (e) {
    debugPrint('Erreur _loadProduct: $e');
  }
}

  // ============================================
  // BUILD
  // ============================================

  @override
Widget build(BuildContext context) {
  return AdminScaffold(
    title: _isEditMode ? 'Modifier la promotion' : 'Nouvelle promotion',
    subtitle: _isEditMode
        ? 'Modifiez les informations de la promotion'
        : 'Créez une nouvelle promotion',
    currentRoute: AppRoutes.adminPromotions,
    onNavigate: (route) {
      if (route.isNotEmpty) {
        Navigator.of(context).pushNamed(route);
      }
    },
    onLogout: () {},
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildForm(),  // ✅ _buildForm() PAS _buildContent()
    ),
  );
}

// ============================================
  // FORMULAIRE
  // ============================================

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // SECTION : INFORMATIONS GÉNÉRALES
          // ============================================
          _buildSectionCard(
            title: 'Informations générales',
            icon: Icons.info_outline,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nom du produit *',
                hint: 'Ex: Samsung Galaxy S24 Ultra',
                icon: Icons.inventory_2_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextArea(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Description détaillée du produit...',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Catégorie *',
                      hint: 'Sélectionner',
                      value: _selectedCategory,
                      items: const ['Électronique', 'Mode', 'Maison', 'Sports'],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Marque',
                      hint: 'Sélectionner',
                      value: _selectedBrand,
                      items: const ['Samsung', 'Apple', 'Sony', 'Nike'],
                      onChanged: (value) {
                        setState(() => _selectedBrand = value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : PRIX ET STOCK
          // ============================================
          _buildSectionCard(
            title: 'Prix et Stock',
            icon: Icons.payments_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Prix (FCFA) *',
                      hint: 'Ex: 850000',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le prix est obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _discountPriceController,
                      label: 'Prix réduit (FCFA)',
                      hint: 'Ex: 799000',
                      icon: Icons.local_offer_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stock *',
                      hint: 'Ex: 50',
                      icon: Icons.warehouse_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le stock est obligatoire';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _minStockController,
                      label: 'Stock minimum',
                      hint: 'Ex: 5',
                      icon: Icons.warning_amber_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _skuController,
                label: 'SKU (Référence)',
                hint: 'Ex: SAM-S24U-001',
                icon: Icons.qr_code,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : OPTIONS
          // ============================================
          _buildSectionCard(
            title: 'Options',
            icon: Icons.tune,
            children: [
              _buildSwitchRow(
                label: 'Produit actif',
                subtitle: 'Visible dans le catalogue',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchRow(
                label: 'Produit en vedette',
                subtitle: 'Mis en avant sur la page d\'accueil',
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchRow(
                label: 'En promotion',
                subtitle: 'Afficher le prix réduit',
                value: _isOnSale,
                onChanged: (value) => setState(() => _isOnSale = value),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================
          // BOUTONS D'ACTION
          // ============================================
          Row(
            children: [
              // Bouton Annuler
              Expanded(
                child: _buildCancelButton(),
              ),
              const SizedBox(width: 16),
              // Bouton Enregistrer
              Expanded(
                child: _buildSaveButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS DE SECTION
  // ============================================

  /// Construit une carte de section.
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.info),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // ============================================
  // WIDGETS DE CHAMPS
  // ============================================

  /// Construit un champ texte.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textLight,
            ),
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: AppColors.textTertiary)
                : null,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  /// Construit une zone de texte.
  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  /// Construit un dropdown.
  Widget _buildDropdownField({
  required String label,
  required String hint,
  required String? value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : null,  // ✅ FIX
            isExpanded: true,
            hint: Text(
              hint,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textLight,
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          ),
        ),
      ),
    ],
  );
}
  /// Construit une rangée de switch.
  Widget _buildSwitchRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  // ============================================
  // BOUTONS
  // ============================================

  /// Construit le bouton Annuler.
  Widget _buildCancelButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _confirmCancel(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColorDark),
          ),
          child: const Text(
            'Annuler',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Construit le bouton Enregistrer.
  Widget _buildSaveButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _isSaving ? null : _save,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.save_outlined, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _isSaving ? 'Enregistrement...' : 'Enregistrer',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ACTIONS
  // ============================================

 

// ============================================
// MÉTHODE _save() CORRIGÉE
// ============================================

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final provider = context.read<AdminProductProvider>();

    // Créer un objet Product
    final product = Product(
      id: widget.productId ?? 0,
      name: _nameController.text.trim(),
      slug: _nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      currentPrice: double.tryParse(_discountPriceController.text.trim().isEmpty 
          ? _priceController.text.trim() 
          : _discountPriceController.text.trim()) ?? 0,
      discountPrice: _discountPriceController.text.trim().isEmpty 
          ? null 
          : double.tryParse(_discountPriceController.text.trim()),
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      minStock: int.tryParse(_minStockController.text.trim()) ?? 5,
      sku: _skuController.text.trim(),
      isActive: _isActive,
      isFeatured: _isFeatured,
      isOnSale: _isOnSale,
      isInStock: (int.tryParse(_stockController.text.trim()) ?? 0) > 0,
      stockStatus: (int.tryParse(_stockController.text.trim()) ?? 0) > 0 ? 'in_stock' : 'out_of_stock',
    );

    bool success;
    if (_isEditMode) {
      success = await provider.updateProduct(product);
    } else {
      success = await provider.createProduct(product);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Produit modifié avec succès' : 'Produit créé avec succès',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Erreur lors de l\'enregistrement',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    debugPrint('Erreur _save: $e');
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  Future<void> _confirmCancel() async {
    final result = await AdminConfirmDialog.show(
      context: context,
      title: 'Annuler les modifications ?',
      message: 'Les modifications non enregistrées seront perdues.',
      type: AdminDialogType.warning,
      confirmLabel: 'Quitter',
      cancelLabel: 'Rester',
    );

    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }
}