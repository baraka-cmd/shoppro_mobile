// Écran de formulaire d'adresse
// Permet d'ajouter ou modifier une adresse

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

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _deliveryInstructionsController;

  String _selectedType = 'home';
  bool _isDefault = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadAddressData();
  }

  // Initialiser les contrôleurs
  void _initControllers() {
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController(text: 'Cameroun');
    _deliveryInstructionsController = TextEditingController();
  }

  // Charger les données si modification
  void _loadAddressData() {
    if (widget.address != null) {
      _fullNameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phone;
      _emailController.text = widget.address!.email ?? '';
      _addressLine1Controller.text = widget.address!.addressLine1;
      _addressLine2Controller.text = widget.address!.addressLine2 ?? '';
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state ?? '';
      _postalCodeController.text = widget.address!.postalCode ?? '';
      _countryController.text = widget.address!.country;
      _deliveryInstructionsController.text = widget.address!.deliveryInstructions ?? '';
      _selectedType = widget.address!.type;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _deliveryInstructionsController.dispose();
    super.dispose();
  }

  // Sauvegarder l'adresse
Future<void> _saveAddress() async {
  FocusScope.of(context).unfocus();

  print('=== SAVE ADDRESS START ===');

  if (!_formKey.currentState!.validate()) {
    print('VALIDATION ÉCHOUE');
    return;
  }
  print('VALIDATION OK');

  setState(() {
    _isSaving = true;
    _errorMessage = null;
  });

  try {
    final provider = context.read<AddressProvider>();
    print('PROVIDER TROUVÉ: ${provider.addressesCount} adresses');

    final address = Address(
      id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      addressLine1: _addressLine1Controller.text.trim(),
      addressLine2: _addressLine2Controller.text.trim().isEmpty
          ? null
          : _addressLine2Controller.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
      type: _selectedType,
      isDefault: _isDefault,
      deliveryInstructions: _deliveryInstructionsController.text.trim().isEmpty
          ? null
          : _deliveryInstructionsController.text.trim(),
    );
    print('ADDRESS CRÉÉE: ${address.fullName}');

    final success = _isEditing
        ? await provider.updateAddress(address)
        : await provider.addAddress(address);
    print('RÉSULTAT: $success');

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      print('SUCCÈS - NAVIGATION RETOUR');
      
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
        ),
      );

      // Utiliser addPostFrameCallback pour éviter les blocages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } else {
      print('ERREUR: ${provider.errorMessage}');
      setState(() {
        _errorMessage = provider.errorMessage;
      });
    }
  } catch (e) {
    print('EXCEPTION: $e');
    print('STACKTRACE: ${StackTrace.current}');
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  print('=== SAVE ADDRESS END ===');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              // Message d'erreur
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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

              // Type d'adresse
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
              Row(
                children: [
                  _buildTypeChip('home', 'Domicile', Icons.home),
                  const SizedBox(width: 8),
                  _buildTypeChip('work', 'Travail', Icons.work),
                  const SizedBox(width: 8),
                  _buildTypeChip('other', 'Autre', Icons.location_on),
                ],
              ),

              const SizedBox(height: 20),

              // Nom complet
              _buildTextField(
                controller: _fullNameController,
                label: 'Nom complet',
                hint: 'Ex : Jean Kamga',
                icon: Icons.person,
                validator: Validators.validateName,
              ),

              // Téléphone
              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone',
                hint: 'Ex : +237 6 00 00 00 00',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),

              // Email (optionnel)
              _buildTextField(
                controller: _emailController,
                label: 'Email (optionnel)',
                hint: 'Ex : jean@email.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              // Adresse ligne 1
              _buildTextField(
                controller: _addressLine1Controller,
                label: 'Adresse ligne 1',
                hint: 'Ex : Bonamoussadi, Rue 123',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'adresse est obligatoire';
                  }
                  return null;
                },
              ),

              // Adresse ligne 2 (optionnel)
              _buildTextField(
                controller: _addressLine2Controller,
                label: 'Adresse ligne 2 (optionnel)',
                hint: 'Ex : Près de la pharmacie',
                icon: Icons.location_on_outlined,
              ),

              // Ville
              _buildTextField(
                controller: _cityController,
                label: 'Ville',
                hint: 'Ex : Douala',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La ville est obligatoire';
                  }
                  return null;
                },
              ),

              // Région (optionnel)
              _buildTextField(
                controller: _stateController,
                label: 'Région (optionnel)',
                hint: 'Ex : Littoral',
                icon: Icons.map,
              ),

              // Code postal (optionnel)
              _buildTextField(
                controller: _postalCodeController,
                label: 'Code postal (optionnel)',
                hint: 'Ex : BP 0000',
                icon: Icons.markunread_mailbox,
              ),

              // Pays
              _buildTextField(
                controller: _countryController,
                label: 'Pays',
                hint: 'Ex : Cameroun',
                icon: Icons.flag,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le pays est obligatoire';
                  }
                  return null;
                },
              ),

              // Instructions de livraison (optionnel)
              _buildTextField(
                controller: _deliveryInstructionsController,
                label: 'Instructions de livraison (optionnel)',
                hint: 'Ex : Appeler à l\'arrivée',
                icon: Icons.info,
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              // Checkbox défaut
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

              // Bouton sauvegarder
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

  // Chip de type
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1.5,
          ),
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

  // Champ de texte
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