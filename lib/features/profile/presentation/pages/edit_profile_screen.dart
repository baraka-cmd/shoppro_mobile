// ============================================
// ÉCRAN DE MODIFICATION DU PROFIL - VERSION PREMIUM
// ============================================
// Formulaire complet avec photo, validation
// et sauvegarde. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/edit_profile_form.dart';
import '../widgets/profile_image_picker.dart';
import 'dart:io';
import '../../../../core/services/upload_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Contrôleurs
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;

  // État
  bool _isSaving = false;
  String? _errorMessage;
  String? _selectedImagePath;
  String? _selectedLanguage;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  // ============================================
  // INITIALISATION
  // ============================================

  void _initControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _countryController = TextEditingController(text: 'RDC');
    _cityController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _loadUserData() {
  final authProvider = context.read<AuthProvider>();
  final user = authProvider.user;



  if (user != null && mounted) {
    setState(() {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _countryController.text = user.country ?? 'RDC';
      _cityController.text = user.city ?? '';
      _addressController.text = user.address ?? '';  // ✅ AJOUTÉ
      _selectedLanguage = user.language ?? 'Français';
      _selectedCurrency = user.currency ?? 'FCFA';
    });
  }
}
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ============================================
  // SAUVEGARDE
  // ============================================

  Future<void> _handleSave() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isSaving = true;
    _errorMessage = null;
  });

  try {
    // ============================================
    // 1. UPLOADER LA PHOTO SI SÉLECTIONNÉE
    // ============================================
    String? uploadedAvatarUrl;

    if (_selectedImagePath != null) {
      debugPrint('📸 UPLOAD DE LA PHOTO: $_selectedImagePath');

      final uploadService = UploadService();
      uploadedAvatarUrl = await uploadService.uploadImage(
        imageFile: File(_selectedImagePath!),
        endpoint: '/auth/upload-avatar',
      );

      debugPrint('📸 AVATAR UPLOADÉ: $uploadedAvatarUrl');

      if (uploadedAvatarUrl == null) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Échec de l\'upload de la photo';
        });
        return;
      }
    }

    // ============================================
    // 2. METTRE À JOUR LE PROFIL
    // ============================================
    final authProvider = context.read<AuthProvider>();

    final data = {
      'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      'phone': _phoneController.text.trim(),
      'country': _countryController.text.trim(),
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'language': _selectedLanguage,
      'currency': _selectedCurrency,
    };

    debugPrint('📤 DONNÉES ENVOYÉES: $data');

    final success = await authProvider.updateProfile(data);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage;
      });
    }
  } catch (e) {
    debugPrint('❌ ERREUR SAUVEGARDE: $e');
    setState(() {
      _isSaving = false;
      _errorMessage = 'Erreur: $e';
    });
  }
}

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // PHOTO DE PROFIL
              // ============================================
              Center(
                child: ProfileImagePicker(
                  avatarUrl: user?.avatar,
                  name: user?.fullName ?? 'Utilisateur',
                  onImageSelected: (path) {
                    setState(() {
                      _selectedImagePath = path;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              // ============================================
              // MESSAGE D'ERREUR
              // ============================================
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.error,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ============================================
              // FORMULAIRE
              // ============================================
              EditProfileForm(
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                emailController: _emailController,
                phoneController: _phoneController,
                countryController: _countryController,
                cityController: _cityController,
                addressController: _addressController,
                selectedLanguage: _selectedLanguage,
                selectedCurrency: _selectedCurrency,
                onLanguageChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
                onCurrencyChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // ============================================
              // BOUTON ENREGISTRER
              // ============================================
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'ENREGISTRER LES MODIFICATIONS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}