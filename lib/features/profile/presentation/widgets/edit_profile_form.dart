// ============================================
// FORMULAIRE DE MODIFICATION DU PROFIL - PREMIUM
// ============================================
// Contient tous les champs avec validation
// complète. Design ShopPro.
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_textfield.dart';

class EditProfileForm extends StatefulWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final String? selectedLanguage;
  final String? selectedCurrency;
  final ValueChanged<String?>? onLanguageChanged;
  final ValueChanged<String?>? onCurrencyChanged;

  const EditProfileForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.countryController,
    required this.cityController,
    required this.addressController,
    this.selectedLanguage,
    this.selectedCurrency,
    this.onLanguageChanged,
    this.onCurrencyChanged,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final List<String> _languages = ['Français', 'English', 'Swahili'];
  final List<String> _currencies = ['FCFA', 'USD', 'CDF'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================
        // SECTION : INFORMATIONS PERSONNELLES
        // ============================================
        const Text(
          'INFORMATIONS PERSONNELLES',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 15),

        // Prénom
        AuthTextField(
          controller: widget.firstNameController,
          label: 'Prénom',
          hint: 'Ex : Félix',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: Validators.validateName,
        ),

        // Nom
        AuthTextField(
          controller: widget.lastNameController,
          label: 'Nom',
          hint: 'Ex : Baraka',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: Validators.validateName,
        ),

        // Email (désactivé)
        AuthTextField(
          controller: widget.emailController,
          label: 'Adresse email',
          hint: 'exemple@email.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.validateEmail,
          enabled: false,
        ),

        // Téléphone
        AuthTextField(
          controller: widget.phoneController,
          label: 'Téléphone',
          hint: 'Ex : +243 99 000 00 00',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: Validators.validatePhone,
        ),

        const SizedBox(height: 25),

        // ============================================
        // SECTION : ADRESSE
        // ============================================
        const Text(
          'ADRESSE',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 15),

        // Pays
        AuthTextField(
          controller: widget.countryController,
          label: 'Pays',
          hint: 'Ex : RDC',
          icon: Icons.flag_outlined,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le pays est obligatoire';
            }
            return null;
          },
        ),

        // Ville
        AuthTextField(
          controller: widget.cityController,
          label: 'Ville',
          hint: 'Ex : Goma',
          icon: Icons.location_city_outlined,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La ville est obligatoire';
            }
            return null;
          },
        ),

        // Adresse complète
        AuthTextField(
          controller: widget.addressController,
          label: 'Adresse complète',
          hint: 'Ex : Katindo, Avenue du Port',
          icon: Icons.location_on_outlined,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'adresse est obligatoire';
            }
            return null;
          },
        ),

        const SizedBox(height: 25),

        // ============================================
        // SECTION : PRÉFÉRENCES
        // ============================================
        const Text(
          'PRÉFÉRENCES',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 15),

        // Langue
        _buildDropdown(
          label: 'Langue',
          icon: Icons.language,
          value: widget.selectedLanguage,
          items: _languages,
          onChanged: widget.onLanguageChanged,
        ),

        const SizedBox(height: 20),

        // Devise
        _buildDropdown(
          label: 'Devise',
          icon: Icons.attach_money,
          value: widget.selectedCurrency,
          items: _currencies,
          onChanged: widget.onCurrencyChanged,
        ),
      ],
    );
  }

  // ============================================
  // DROPDOWN PERSONNALISÉ
  // ============================================

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
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

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            borderRadius: BorderRadius.circular(14),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}