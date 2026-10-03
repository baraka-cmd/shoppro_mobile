// ============================================
// PAGE : AdminUserCreateScreen (MOBILE SENIOR)
// ============================================
// Écran de création d'un utilisateur.
// - Formulaire complet avec validation
// - Upload de photo de profil (image_picker)
// - Sélection de rôle (Client / Vendeur / Admin)
// - Toggle actif/inactif
// - Design mobile-first avec sections
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Core
import '../../../../core/constants/app_colors.dart';

// Providers
import '../providers/admin_user_provider.dart';

// Entities
import '../../domain/entities/admin_user.dart';

class AdminUserCreateScreen extends StatefulWidget {
  const AdminUserCreateScreen({super.key});

  @override
  State<AdminUserCreateScreen> createState() => _AdminUserCreateScreenState();
}

class _AdminUserCreateScreenState extends State<AdminUserCreateScreen> {
  // ============================================
  // ÉTAT
  // ============================================

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'RDC');
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  // Sélections
  String _selectedRole = 'client';
  bool _isActive = true;
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  // Photo
  File? _avatarFile;

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Informations personnelles',
              icon: Icons.person_outline,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  hint: 'Ex : Jean Kamga',
                  icon: Icons.person_outline,
                  required: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  hint: 'Ex : jean@example.com',
                  icon: Icons.email_outlined,
                  required: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  hint: 'Ex : +243 99 000 00 00',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Localisation',
              icon: Icons.location_on_outlined,
              children: [
                _buildTextField(
                  controller: _countryController,
                  label: 'Pays',
                  hint: 'Ex : RDC',
                  icon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityController,
                  label: 'Ville',
                  hint: 'Ex : Goma',
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Adresse',
                  hint: 'Ex : Avenue du Port, 123',
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Rôle et permissions',
              icon: Icons.admin_panel_settings_outlined,
              children: [
                _buildRoleSelector(),
                const SizedBox(height: 16),
                _buildActiveToggle(),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Sécurité',
              icon: Icons.lock_outline,
              children: [
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Min. 6 caractères',
                  icon: Icons.lock_outline,
                  required: true,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordConfirmController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Retapez le mot de passe',
                  icon: Icons.lock_outline,
                  required: true,
                  obscureText: !_isPasswordConfirmVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordConfirmVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordConfirmVisible =
                            !_isPasswordConfirmVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer le mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ============================================
  // APPBAR
  // ============================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nouvel utilisateur',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Créer un compte',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION : AVATAR
  // ============================================

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showAvatarOptions,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: _avatarFile != null
                        ? DecorationImage(
                            image: FileImage(_avatarFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarFile == null
                      ? const Center(
                          child: Icon(
                            Icons.person_add_alt_1_outlined,
                            size: 42,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _avatarFile == null
                ? 'Ajouter une photo'
                : 'Modifier la photo',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'JPG, PNG — Max 5 Mo',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Photo de profil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (_avatarFile != null)
                _buildAvatarOption(
                  icon: Icons.delete_outline,
                  label: 'Supprimer la photo',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _avatarFile = null);
                  },
                ),
              _buildAvatarOption(
                icon: Icons.photo_camera_outlined,
                label: 'Prendre une photo',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAvatar(ImageSource.camera);
                },
              ),
              _buildAvatarOption(
                icon: Icons.photo_library_outlined,
                label: 'Choisir depuis la galerie',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null && mounted) {
        setState(() {
          _avatarFile = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Impossible de sélectionner la photo : $e');
    }
  }

  // ============================================
  // SECTION GÉNÉRIQUE
  // ============================================

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ============================================
  // CHAMP DE TEXTE
  // ============================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          validator: validator ?? (required ? _defaultValidator(label) : null),
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
            prefixIcon: Icon(icon, size: 18, color: AppColors.textTertiary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String? Function(String?)? _defaultValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Le champ $fieldName est obligatoire';
      }
      if (fieldName == 'Adresse email') {
        if (!value.contains('@') || !value.contains('.')) {
          return 'Adresse email invalide';
        }
      }
      if (fieldName == 'Mot de passe' && value.length < 6) {
        return 'Min. 6 caractères';
      }
      return null;
    };
  }

  // ============================================
  // SÉLECTEUR DE RÔLE
  // ============================================

  Widget _buildRoleSelector() {
    final roles = [
      {
        'value': 'client',
        'label': 'Client',
        'icon': Icons.person_outline,
        'color': AppColors.success,
      },
      {
        'value': 'seller',
        'label': 'Vendeur',
        'icon': Icons.storefront_outlined,
        'color': AppColors.warning,
      },
      {
        'value': 'admin',
        'label': 'Admin',
        'icon': Icons.admin_panel_settings_outlined,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rôle',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: roles.map((role) {
            final isSelected = _selectedRole == role['value'];
            final color = role['color'] as Color;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: role['value'] != 'admin' ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = role['value'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.12)
                          : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          role['icon'] as IconData,
                          size: 22,
                          color: isSelected ? color : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          role['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================
  // TOGGLE ACTIF
  // ============================================

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (_isActive ? AppColors.success : AppColors.textTertiary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isActive
                  ? Icons.check_circle_outline
                  : Icons.do_not_disturb_on_outlined,
              size: 18,
              color:
                  _isActive ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compte actif',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isActive
                      ? 'L\'utilisateur peut se connecter'
                      : 'L\'utilisateur ne peut pas se connecter',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isActive,
            activeColor: AppColors.success,
            onChanged: (value) {
              setState(() => _isActive = value);
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOTTOM BAR
  // ============================================

  Widget _buildBottomBar() {
    return Consumer<AdminUserProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isCreating;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Annuler
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ANNULER',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Créer
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      isLoading ? 'CRÉATION...' : 'CRÉER L\'UTILISATEUR',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // SOUMISSION
  // ============================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    // Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AdminUserProvider>();

    // Créer l'utilisateur
    final created = await provider.createUserSimple(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      isActive: _isActive,
      avatarFile: _avatarFile,
    );

    if (!mounted) return;

    if (created != null) {
      // Succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Utilisateur "${created.name}" créé avec succès',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } else {
      // Erreur
      _showError(provider.errorMessage ?? 'Erreur lors de la création');
      provider.clearError();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}