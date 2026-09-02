// ============================================
// PAGE : AdminBrandFormScreen
// ============================================
// Écran de création/modification de marque.
// Design moderne avec formulaire organisé.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Formulaire en carte
// - Sections : Infos, Logo, Options
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
import '../providers/admin_brand_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../products/domain/entities/brand.dart';
import '../providers/admin_brand_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de formulaire marque.
///
/// Permet de :
/// - Créer une nouvelle marque
/// - Modifier une marque existante
class AdminBrandFormScreen extends StatefulWidget {
  /// ID de la marque à modifier (null = création)
  final int? brandId;

  const AdminBrandFormScreen({super.key, this.brandId});

  @override
  State<AdminBrandFormScreen> createState() => _AdminBrandFormScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminBrandFormScreenState extends State<AdminBrandFormScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();

  // ============================================
  // ÉTAT
  // ============================================

  bool _isSaving = false;
  bool _isEditMode = false;
  bool _isActive = true;
  bool _isFeatured = false;
  String? _logoPath;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.brandId != null;
    if (_isEditMode) {
      _loadBrand();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadBrand() async {
  try {
    final provider = context.read<AdminBrandProvider>();
    final brandId = widget.brandId;

    if (brandId == null) return;

    final brand = provider.getBrandById(brandId);

    if (brand != null) {
      setState(() {
        _nameController.text = brand.name;
        _descriptionController.text = brand.description ?? '';
        _websiteController.text = brand.website ?? '';
        _emailController.text = brand.email ?? '';
        _phoneController.text = brand.phone ?? '';
        _countryController.text = brand.country ?? '';
        _isActive = brand.isActive;
        _isFeatured = brand.isFeatured;
        _logoPath = brand.logo;
      });
    }
  } catch (e) {
    debugPrint('Erreur _loadBrand: $e');
  }
}

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
  title: _isEditMode ? 'Modifier la bannière' : 'Nouvelle bannière',
  subtitle: _isEditMode
      ? 'Modifiez les informations de la bannière'
      : 'Créez une nouvelle bannière',
  currentRoute: AppRoutes.adminBanners,
  onNavigate: (route) {
    if (route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
    }
  },
  onNotificationsTap: () {
    Navigator.of(context).pushNamed(AppRoutes.adminNotifications);
  },
  onLogout: () {
    // Déconnexion
  },
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: _buildForm(),
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
                label: 'Nom de la marque *',
                hint: 'Ex: Samsung',
                icon: Icons.storefront_outlined,
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
                hint: 'Description de la marque...',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _countryController,
                label: 'Pays d\'origine',
                hint: 'Ex: Corée du Sud',
                icon: Icons.public,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : LOGO
          // ============================================
          _buildSectionCard(
            title: 'Logo de la marque',
            icon: Icons.image_outlined,
            children: [
              _buildLogoUploader(),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : CONTACT
          // ============================================
          _buildSectionCard(
            title: 'Coordonnées de contact',
            icon: Icons.contact_mail_outlined,
            children: [
              _buildTextField(
                controller: _websiteController,
                label: 'Site web',
                hint: 'https://www.exemple.com',
                icon: Icons.language,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'contact@exemple.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      hint: '+237 6 00 00 00 00',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
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
                label: 'Marque active',
                subtitle: 'Visible dans le catalogue',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchRow(
                label: 'Marque en vedette',
                subtitle: 'Mise en avant sur la page d\'accueil',
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================
          // BOUTONS D'ACTION
          // ============================================
          Row(
            children: [
              Expanded(
                child: _buildCancelButton(),
              ),
              const SizedBox(width: 16),
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
  // SECTION CARD
  // ============================================

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
  // UPLOADER DE LOGO
  // ============================================

  Widget _buildLogoUploader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Zone de logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderColor),
            ),
            child: _logoPath != null
                ? ClipOval(
                    child: Image.network(
                      _logoPath!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildLogoPlaceholder();
                      },
                    ),
                  )
                : _buildLogoPlaceholder(),
          ),
          const SizedBox(height: 12),
          // Bouton upload
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _pickLogo(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Choisir un logo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Formats acceptés : PNG, JPG (max 2MB)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder du logo.
  Widget _buildLogoPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 36,
            color: AppColors.textLight,
          ),
          SizedBox(height: 4),
          Text(
            'Logo',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHAMPS
  // ============================================

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
          maxLines: 4,
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

  Future<void> _pickLogo() async {
    // Simuler la sélection d'un logo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sélection de logo à implémenter'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final provider = context.read<AdminBrandProvider>();

    // Créer un objet Brand (à adapter selon ton entité)
    final brand = Brand(
      id: widget.brandId ?? 0,
      name: _nameController.text.trim(),
      slug: _nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
      logo: _logoPath,
      isActive: _isActive,
      isFeatured: _isFeatured,
    );

    bool success;
    if (_isEditMode) {
      success = await provider.updateBrand(brand);
    } else {
      success = await provider.createBrand(brand);
    }

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Marque modifiée avec succès' : 'Marque créée avec succès'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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