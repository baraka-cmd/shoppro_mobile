// ============================================
// ÉCRAN DE FORMULAIRE D'ADRESSE - VERSION PREMIUM
// ============================================
// Permet d'ajouter ou modifier une adresse
// adaptée au contexte RDC. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/address_provider.dart';
import '../../domain/entities/address.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address;

  const AddressFormScreen({
    super.key,
    this.address,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _provinceController;
  late final TextEditingController _cityController;
  late final TextEditingController _communeController;
  late final TextEditingController _quartierController;
  late final TextEditingController _avenueController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _additionalInfoController;
  late final TextEditingController _deliveryInstructionsController;

  String _selectedType = 'home';
  bool _isDefault = false;
  bool _hasGps = false;
  double? _latitude;
  double? _longitude;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadAddressData();
  }

  // ============================================
  // INITIALISATION
  // ============================================

  void _initControllers() {
    _labelController = TextEditingController();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _provinceController = TextEditingController();
    _cityController = TextEditingController();
    _communeController = TextEditingController();
    _quartierController = TextEditingController();
    _avenueController = TextEditingController();
    _landmarkController = TextEditingController();
    _additionalInfoController = TextEditingController();
    _deliveryInstructionsController = TextEditingController();
  }

  void _loadAddressData() {
    if (widget.address != null) {
      _labelController.text = widget.address!.label;
      _fullNameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phone;
      _emailController.text = widget.address!.email ?? '';
      _provinceController.text = widget.address!.province;
      _cityController.text = widget.address!.city;
      _communeController.text = widget.address!.commune;
      _quartierController.text = widget.address!.quartier ?? '';
      _avenueController.text = widget.address!.avenue ?? '';
      _landmarkController.text = widget.address!.landmark ?? '';
      _additionalInfoController.text = widget.address!.additionalInfo ?? '';
      _deliveryInstructionsController.text =
          widget.address!.deliveryInstructions ?? '';
      _selectedType = widget.address!.type;
      _isDefault = widget.address!.isDefault;
      _hasGps = widget.address!.hasGps;
      _latitude = widget.address!.latitude;
      _longitude = widget.address!.longitude;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _communeController.dispose();
    _quartierController.dispose();
    _avenueController.dispose();
    _landmarkController.dispose();
    _additionalInfoController.dispose();
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  // ============================================
  // SAUVEGARDE
  // ============================================

  Future<void> _saveAddress() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<AddressProvider>();

      final address = Address(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch,
        label: _labelController.text.trim().isEmpty
            ? _getTypeLabel(_selectedType)
            : _labelController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        province: _provinceController.text.trim(),
        city: _cityController.text.trim(),
        commune: _communeController.text.trim(),
        quartier: _quartierController.text.trim().isEmpty
            ? null
            : _quartierController.text.trim(),
        avenue: _avenueController.text.trim().isEmpty
            ? null
            : _avenueController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        country: 'RDC',
        type: _selectedType,
        isDefault: _isDefault,
        latitude: _latitude,
        longitude: _longitude,
        deliveryInstructions: _deliveryInstructionsController.text.trim().isEmpty
            ? null
            : _deliveryInstructionsController.text.trim(),
        createdAt: widget.address?.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = _isEditing
          ? await provider.updateAddress(address)
          : await provider.addAddress(address);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Adresse modifiée !' : 'Adresse ajoutée !',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        setState(() {
          _errorMessage = provider.errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Erreur: $e';
        });
      }
    }
  }

  // ============================================
  // GPS (simulation)
  // ============================================

  void _useGpsLocation() {
    // Simuler la position GPS de Goma, RDC
    setState(() {
      _hasGps = true;
      _latitude = -1.6792;
      _longitude = 29.2236;
      if (_provinceController.text.isEmpty) {
        _provinceController.text = 'Nord-Kivu';
      }
      if (_cityController.text.isEmpty) {
        _cityController.text = 'Goma';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '📍 Position GPS enregistrée',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'home':
        return 'Maison';
      case 'work':
        return 'Travail';
      case 'shop':
        return 'Boutique';
      case 'parents':
        return 'Famille';
      default:
        return 'Autre';
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          _isEditing ? 'Modifier l\'adresse' : 'Ajouter une adresse',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ============================================
              // NOM DE L'ADRESSE
              // ============================================
              _buildTextField(
                controller: _labelController,
                label: 'Nom de l\'adresse',
                hint: 'Ex : Maison, Travail, Chez mes parents...',
                icon: Icons.label_outline,
              ),

              // ============================================
              // TYPE D'ADRESSE
              // ============================================
              const Text(
                'TYPE D\'ADRESSE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip('home', 'Domicile', Icons.home_outlined),
                  _buildTypeChip('work', 'Travail', Icons.work_outline),
                  _buildTypeChip('shop', 'Boutique', Icons.store_outlined),
                  _buildTypeChip('parents', 'Famille', Icons.family_restroom),
                  _buildTypeChip('other', 'Autre', Icons.location_on_outlined),
                ],
              ),

              const SizedBox(height: 20),

              // ============================================
              // NOM COMPLET
              // ============================================
              _buildTextField(
                controller: _fullNameController,
                label: 'Nom complet *',
                hint: 'Ex : Félix Baraka',
                icon: Icons.person_outline,
                validator: Validators.validateName,
              ),

              // ============================================
              // TÉLÉPHONE
              // ============================================
              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone *',
                hint: 'Ex : +243 99 000 00 00',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),

              // ============================================
              // EMAIL (OPTIONNEL)
              // ============================================
              _buildTextField(
                controller: _emailController,
                label: 'Email (optionnel)',
                hint: 'Ex : felix@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 5),
              const Divider(height: 1),
              const SizedBox(height: 15),

              // ============================================
              // PROVINCE
              // ============================================
              _buildTextField(
                controller: _provinceController,
                label: 'Province / Région *',
                hint: 'Ex : Nord-Kivu',
                icon: Icons.map_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La province est obligatoire';
                  }
                  return null;
                },
              ),

              // ============================================
              // VILLE
              // ============================================
              _buildTextField(
                controller: _cityController,
                label: 'Ville / Territoire *',
                hint: 'Ex : Goma',
                icon: Icons.location_city_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La ville est obligatoire';
                  }
                  return null;
                },
              ),

              // ============================================
              // COMMUNE
              // ============================================
              _buildTextField(
                controller: _communeController,
                label: 'Commune / Zone *',
                hint: 'Ex : Goma, Karisimbi',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La commune est obligatoire';
                  }
                  return null;
                },
              ),

              // ============================================
              // QUARTIER
              // ============================================
              _buildTextField(
                controller: _quartierController,
                label: 'Quartier (optionnel)',
                hint: 'Ex : Katindo, Himbi...',
                icon: Icons.home_work_outlined,
              ),

              // ============================================
              // AVENUE
              // ============================================
              _buildTextField(
                controller: _avenueController,
                label: 'Avenue / Rue (optionnel)',
                hint: 'Ex : Avenue du Port...',
                icon: Icons.add_road,
              ),

              // ============================================
              // POINT DE REPÈRE
              // ============================================
              _buildTextField(
                controller: _landmarkController,
                label: 'Point de repère (optionnel)',
                hint: 'Ex : Près de l\'église, derrière le marché...',
                icon: Icons.place_outlined,
              ),

              const SizedBox(height: 5),

              // ============================================
              // GPS
              // ============================================
              GestureDetector(
                onTap: _useGpsLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _hasGps
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasGps
                          ? AppColors.success
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _hasGps ? Icons.gps_fixed : Icons.gps_not_fixed,
                        size: 18,
                        color: _hasGps ? AppColors.success : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasGps
                            ? 'Position GPS enregistrée'
                            : 'Utiliser ma position GPS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _hasGps ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ============================================
              // INFORMATIONS COMPLÉMENTAIRES
              // ============================================
              _buildTextField(
                controller: _additionalInfoController,
                label: 'Informations complémentaires (optionnel)',
                hint: 'Ex : Porte bleue, 2ème étage...',
                icon: Icons.info_outline,
                maxLines: 2,
              ),

              // ============================================
              // INSTRUCTIONS DE LIVRAISON
              // ============================================
              _buildTextField(
                controller: _deliveryInstructionsController,
                label: 'Instructions de livraison (optionnel)',
                hint: 'Ex : Appeler à l\'arrivée',
                icon: Icons.info_outline,
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              // ============================================
              // CHECKBOX DÉFAUT
              // ============================================
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Définir comme adresse par défaut',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ============================================
              // BOUTON SAUVEGARDER
              // ============================================
              ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  disabledBackgroundColor: AppColors.borderColor,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'MODIFIER L\'ADRESSE' : 'AJOUTER L\'ADRESSE',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // CHIP DE TYPE
  // ============================================

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
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
              prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}