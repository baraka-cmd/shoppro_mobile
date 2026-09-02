// ============================================
// PAGE : AdminPromotionFormScreen
// ============================================
// Écran de création/modification de promotion.
// Design moderne avec formulaire organisé.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Formulaire en carte
// - Sections : Type, Réduction, Période, Règles
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
import '../providers/admin_promotion_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/admin_promotion.dart';
import '../providers/admin_promotion_provider.dart';


// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de formulaire promotion.
///
/// Permet de :
/// - Créer une nouvelle promotion
/// - Modifier une promotion existante
class AdminPromotionFormScreen extends StatefulWidget {
  /// ID de la promotion à modifier (null = création)
  final int? promotionId;

  const AdminPromotionFormScreen({super.key, this.promotionId});

  @override
  State<AdminPromotionFormScreen> createState() => _AdminPromotionFormScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminPromotionFormScreenState extends State<AdminPromotionFormScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // ============================================
  // ÉTAT
  // ============================================

  bool _isSaving = false;
  bool _isEditMode = false;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _showCountdown = true;

  String _selectedType = 'discount';
  String _selectedDiscountType = 'percentage';
  DateTime? _startDate;
  DateTime? _endDate;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.promotionId != null;
    if (_isEditMode) {
      _loadPromotion();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minimumOrderController.dispose();
    _usageLimitController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadPromotion() async {
  try {
    final provider = context.read<AdminPromotionProvider>();
    final promotionId = widget.promotionId;

    if (promotionId == null) return;

    final promotion = provider.promotions.firstWhere(
      (p) => p.id == promotionId,
      orElse: () => throw Exception('Promotion introuvable'),
    );

    setState(() {
      _nameController.text = promotion.name;
      _descriptionController.text = promotion.description ?? '';
      _discountValueController.text = promotion.discountValue.toString();
      _minimumOrderController.text = promotion.minimumOrder.toString();
      _usageLimitController.text = promotion.usageLimit?.toString() ?? '';
      _selectedType = promotion.type.code;
      _selectedDiscountType = promotion.discountType.code;
      _startDate = promotion.startDate;
      _endDate = promotion.endDate;
      _startDateController.text = _formatDate(promotion.startDate);
      _endDateController.text = _formatDate(promotion.endDate);
      _isActive = promotion.isActive;
      _isFeatured = promotion.isFeatured;
      _showCountdown = promotion.showCountdown;
    });
  } catch (e) {
    debugPrint('Erreur _loadPromotion: $e');
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
          // SECTION : TYPE DE PROMOTION
          // ============================================
          _buildSectionCard(
            title: 'Type de promotion',
            icon: Icons.local_offer_outlined,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Nom de la promotion *',
                hint: 'Ex: Soldes d\'été',
                icon: Icons.label_outline,
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
                hint: 'Description de la promotion...',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : RÉDUCTION
          // ============================================
          _buildSectionCard(
            title: 'Réduction',
            icon: Icons.percent,
            children: [
              // Type de réduction
              _buildDiscountTypeSelector(),
              const SizedBox(height: 16),
              // Valeur de réduction
              _buildTextField(
                controller: _discountValueController,
                label: _selectedDiscountType == 'percentage'
                    ? 'Pourcentage de réduction (%) *'
                    : 'Montant de réduction (FCFA) *',
                hint: _selectedDiscountType == 'percentage' ? 'Ex: 25' : 'Ex: 5000',
                icon: _selectedDiscountType == 'percentage'
                    ? Icons.percent
                    : Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La valeur est obligatoire';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Valeur invalide';
                  }
                  if (_selectedDiscountType == 'percentage' && number > 100) {
                    return 'Maximum 100%';
                  }
                  return null;
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : PÉRIODE
          // ============================================
          _buildSectionCard(
            title: 'Période de validité',
            icon: Icons.calendar_today,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: _startDateController,
                      label: 'Date de début *',
                      icon: Icons.calendar_today,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      controller: _endDateController,
                      label: 'Date de fin *',
                      icon: Icons.event,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : RÈGLES
          // ============================================
          _buildSectionCard(
            title: 'Règles de la promotion',
            icon: Icons.rule,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _minimumOrderController,
                      label: 'Montant minimum (FCFA)',
                      hint: 'Ex: 10000',
                      icon: Icons.shopping_cart_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _usageLimitController,
                      label: 'Limite d\'utilisation',
                      hint: 'Vide = illimitée',
                      icon: Icons.repeat,
                      keyboardType: TextInputType.number,
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
                label: 'Promotion active',
                subtitle: 'Disponible pour les clients',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchRow(
                label: 'Promotion en vedette',
                subtitle: 'Mise en avant sur la page d\'accueil',
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchRow(
                label: 'Afficher le compte à rebours',
                subtitle: 'Minuteur visible pour les clients',
                value: _showCountdown,
                onChanged: (value) => setState(() => _showCountdown = value),
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
  // SÉLECTEUR DE TYPE
  // ============================================

  Widget _buildTypeSelector() {
    final types = [
      {'label': 'Réduction', 'code': 'discount', 'icon': Icons.percent},
      {'label': 'Vente Flash', 'code': 'flash_sale', 'icon': Icons.bolt},
      {'label': 'BOGO', 'code': 'bogo', 'icon': Icons.card_giftcard},
      {'label': 'Pack', 'code': 'bundle', 'icon': Icons.inventory_2_outlined},
      {'label': 'Liquidation', 'code': 'clearance', 'icon': Icons.sell_outlined},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        final isSelected = _selectedType == type['code'];
        return InkWell(
          onTap: () {
            setState(() {
              _selectedType = type['code'] as String;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Sélecteur de type de réduction.
  Widget _buildDiscountTypeSelector() {
    return Row(
      children: [
        _buildDiscountTypeCard(
          label: 'Pourcentage (%)',
          icon: Icons.percent,
          isSelected: _selectedDiscountType == 'percentage',
          onTap: () => setState(() => _selectedDiscountType = 'percentage'),
        ),
        const SizedBox(width: 12),
        _buildDiscountTypeCard(
          label: 'Montant fixe (FCFA)',
          icon: Icons.attach_money,
          isSelected: _selectedDiscountType == 'fixed',
          onTap: () => setState(() => _selectedDiscountType = 'fixed'),
        ),
      ],
    );
  }

  /// Carte de type de réduction.
  Widget _buildDiscountTypeCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.infoLight : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.info : AppColors.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.info : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.infoDark : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
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
  // CHAMP DATE
  // ============================================

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textTertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Sélectionner une date' : controller.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: controller.text.isEmpty
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // CHAMPS STANDARD
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

  Future<void> _pickDate(bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (_startDate ?? now)
        : (_endDate ?? now.add(const Duration(days: 7)));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          _startDateController.text = _formatDate(date);
        } else {
          _endDate = date;
          _endDateController.text = _formatDate(date);
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================
// IMPORTS À AJOUTER EN HAUT DU FICHIER
// ============================================



// ============================================
// MÉTHODE _save() CORRIGÉE
// ============================================

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  if (_startDate == null || _endDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez sélectionner les dates de début et de fin'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (_endDate!.isBefore(_startDate!)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La date de fin doit être après la date de début'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() => _isSaving = true);

  try {
    final provider = context.read<AdminPromotionProvider>();

    // Créer un objet AdminPromotion
    final promotion = AdminPromotion(
      id: widget.promotionId ?? 0,
      name: _nameController.text.trim(),
      slug: _nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      type: AdminPromotionType.fromCode(_selectedType),
      discountType: AdminDiscountType.fromCode(_selectedDiscountType),
      discountValue: double.tryParse(_discountValueController.text.trim()) ?? 0,
      startDate: _startDate!,
      endDate: _endDate!,
      minimumOrder: double.tryParse(_minimumOrderController.text.trim()) ?? 0,
      usageLimit: _usageLimitController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_usageLimitController.text.trim()),
      isActive: _isActive,
      isFeatured: _isFeatured,
      showCountdown: _showCountdown,
    );

    bool success;
    if (_isEditMode) {
      success = await provider.updatePromotion(promotion);
    } else {
      success = await provider.createPromotion(promotion);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Promotion modifiée avec succès' : 'Promotion créée avec succès',
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