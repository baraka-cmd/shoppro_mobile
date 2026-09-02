// ============================================
// PAGE : AdminSettingsScreen
// ============================================
// Écran des paramètres de l'application.
// Design moderne avec sections groupées.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Sections de paramètres en cartes
// - Champs organisés par groupe
// - Bouton Enregistrer
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
import '../providers/admin_setting_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_error_state.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran des paramètres de l'application.
///
/// Affiche :
/// - Les paramètres groupés par catégorie
/// - Les champs modifiables
/// - Le bouton Enregistrer
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final _appNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _shippingFeeController = TextEditingController();
  final _freeShippingThresholdController = TextEditingController();
  final _taxRateController = TextEditingController();

  // ============================================
  // ÉTAT
  // ============================================

  bool _isSaving = false;
  String _selectedCurrency = 'FCFA';
  String _selectedLanguage = 'Français';
  bool _maintenanceMode = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSettingProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _storeAddressController.dispose();
    _shippingFeeController.dispose();
    _freeShippingThresholdController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  // ============================================
  // BUILD
  // ============================================

  @override
Widget build(BuildContext context) {
  return AdminScaffold(
    title: 'Marques',
    subtitle: 'Gérez vos marques et partenaires',
    currentRoute: AppRoutes.adminBrands,
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
    child: _buildContent(),
  );
}
  // ============================================
  // CONTENU PRINCIPAL
  // ============================================

  Widget _buildContent() {
    return Consumer<AdminSettingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: AdminLoadingState(
              type: AdminLoadingType.form,
            ),
          );
        }

        if (provider.hasError) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AdminErrorState(
              message: provider.errorMessage ?? 'Erreur inconnue',
              onRetry: provider.loadSettings,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // SECTION : BOUTIQUE
              // ============================================
              _buildSectionCard(
                title: 'Informations de la boutique',
                icon: Icons.storefront_outlined,
                children: [
                  _buildTextField(
                    controller: _appNameController,
                    label: 'Nom de l\'application',
                    icon: Icons.business_outlined,
                    hint: 'ShopPro',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Devise par défaut',
                          value: _selectedCurrency,
                          items: const ['FCFA', 'EUR', 'USD', 'XAF'],
                          onChanged: (value) {
                            setState(() => _selectedCurrency = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Langue par défaut',
                          value: _selectedLanguage,
                          items: const ['Français', 'English', 'Español'],
                          onChanged: (value) {
                            setState(() => _selectedLanguage = value!);
                          },
                        ),
                      ),
                    ],
                  ),
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
                    controller: _contactEmailController,
                    label: 'Email de contact',
                    icon: Icons.email_outlined,
                    hint: 'contact@shoppro.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactPhoneController,
                    label: 'Téléphone de contact',
                    icon: Icons.phone_outlined,
                    hint: '+237 6 00 00 00 00',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextArea(
                    controller: _storeAddressController,
                    label: 'Adresse de la boutique',
                    hint: 'Douala, Cameroun...',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================================
              // SECTION : LIVRAISON
              // ============================================
              _buildSectionCard(
                title: 'Paramètres de livraison',
                icon: Icons.local_shipping_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _shippingFeeController,
                          label: 'Frais de livraison (FCFA)',
                          icon: Icons.attach_money,
                          hint: '2000',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _freeShippingThresholdController,
                          label: 'Livraison gratuite dès (FCFA)',
                          icon: Icons.local_offer_outlined,
                          hint: '50000',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _taxRateController,
                    label: 'Taux de taxe (%)',
                    icon: Icons.percent,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================================
              // SECTION : NOTIFICATIONS
              // ============================================
              _buildSectionCard(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                children: [
                  _buildSwitchRow(
                    label: 'Notifications par email',
                    subtitle: 'Recevoir les alertes par email',
                    value: _emailNotifications,
                    onChanged: (value) => setState(() => _emailNotifications = value),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchRow(
                    label: 'Notifications push',
                    subtitle: 'Recevoir les alertes sur mobile',
                    value: _pushNotifications,
                    onChanged: (value) => setState(() => _pushNotifications = value),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchRow(
                    label: 'Notifications SMS',
                    subtitle: 'Recevoir les alertes par SMS',
                    value: _smsNotifications,
                    onChanged: (value) => setState(() => _smsNotifications = value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ============================================
              // SECTION : MAINTENANCE
              // ============================================
              _buildSectionCard(
                title: 'Maintenance',
                icon: Icons.build_outlined,
                children: [
                  _buildSwitchRow(
                    label: 'Mode maintenance',
                    subtitle: 'Désactiver l\'accès à l\'application',
                    value: _maintenanceMode,
                    onChanged: (value) => setState(() => _maintenanceMode = value),
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
                    child: _buildResetButton(),
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
      },
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
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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
        TextField(
          controller: controller,
          maxLines: 3,
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
    required String value,
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
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

  /// Construit le bouton Réinitialiser.
  Widget _buildResetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _resetSettings(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColorDark),
          ),
          child: const Text(
            'Réinitialiser',
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

  Future<void> _save() async {
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres enregistrés avec succès'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetSettings() {
    _appNameController.clear();
    _contactEmailController.clear();
    _contactPhoneController.clear();
    _storeAddressController.clear();
    _shippingFeeController.clear();
    _freeShippingThresholdController.clear();
    _taxRateController.clear();
    setState(() {
      _selectedCurrency = 'FCFA';
      _selectedLanguage = 'Français';
      _maintenanceMode = false;
      _emailNotifications = true;
      _pushNotifications = true;
      _smsNotifications = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres réinitialisés'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}