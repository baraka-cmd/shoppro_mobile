// ============================================
// PAGE : AdminCategoryFormScreen
// ============================================
// Écran de création/modification de catégorie.
// Design moderne avec formulaire organisé.
//
// Structure :
// - Sidebar de navigation
// - Header avec titre
// - Formulaire en carte
// - Sections : Infos, Image, Options
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
import '../providers/admin_category_provider.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/admin_confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../../../products/domain/entities/category.dart';
import '../providers/admin_category_provider.dart';


// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de formulaire catégorie.
///
/// Permet de :
/// - Créer une nouvelle catégorie
/// - Modifier une catégorie existante
class AdminCategoryFormScreen extends StatefulWidget {
  /// ID de la catégorie à modifier (null = création)
  final int? categoryId;

  const AdminCategoryFormScreen({super.key, this.categoryId});

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ============================================
  // ÉTAT
  // ============================================

  bool _isSaving = false;
  bool _isEditMode = false;
  bool _isActive = true;
  bool _isFeatured = false;
  String? _imagePath;
  String? _parentCategory;
  int _position = 0;
  String _selectedIcon = 'category';

  // Icônes disponibles
  static const List<Map<String, String>> _availableIcons = [
    {'label': 'Catégorie', 'icon': 'category'},
    {'label': 'Électronique', 'icon': 'devices'},
    {'label': 'Mode', 'icon': 'checkroom'},
    {'label': 'Maison', 'icon': 'home'},
    {'label': 'Sports', 'icon': 'sports'},
    {'label': 'Alimentation', 'icon': 'restaurant'},
    {'label': 'Beauté', 'icon': 'spa'},
    {'label': 'Jouets', 'icon': 'toys'},
    {'label': 'Livres', 'icon': 'menu_book'},
    {'label': 'Auto', 'icon': 'directions_car'},
  ];

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.categoryId != null;
    if (_isEditMode) {
      _loadCategory();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadCategory() async {
  try {
    final provider = context.read<AdminCategoryProvider>();
    final categoryId = widget.categoryId;

    if (categoryId == null) return;

    final category = provider.getCategoryById(categoryId);

    if (category != null) {
      setState(() {
        _nameController.text = category.name;
        _descriptionController.text = category.description ?? '';
        _isActive = category.isActive;
        _isFeatured = category.isFeatured;
        _parentCategory = category.parentId != null
            ? provider.getCategoryById(category.parentId!)?.name
            : null;
        _position = category.position ?? 0;
        _selectedIcon = category.icon ?? 'category';
      });
    }
  } catch (e) {
    debugPrint('Erreur _loadCategory: $e');
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
                label: 'Nom de la catégorie *',
                hint: 'Ex: Électronique',
                icon: Icons.category_outlined,
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
                hint: 'Description de la catégorie...',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Catégorie parente',
                      hint: 'Aucune (catégorie racine)',
                      value: _parentCategory,
                      items: const [
                        'Aucune (catégorie racine)',
                        'Électronique',
                        'Mode',
                        'Maison',
                        'Sports',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _parentCategory = value == 'Aucune (catégorie racine)'
                              ? null
                              : value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPositionField(),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : ICÔNE
          // ============================================
          _buildSectionCard(
            title: 'Icône de la catégorie',
            icon: Icons.emoji_emotions_outlined,
            children: [
              _buildIconSelector(),
            ],
          ),

          const SizedBox(height: 16),

          // ============================================
          // SECTION : IMAGE
          // ============================================
          _buildSectionCard(
            title: 'Image de la catégorie',
            icon: Icons.image_outlined,
            children: [
              _buildImageUploader(),
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
                label: 'Catégorie active',
                subtitle: 'Visible dans le catalogue',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 12),
              _buildSwitchRow(
                label: 'Catégorie en vedette',
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
  // SÉLECTEUR D'ICÔNE
  // ============================================

  Widget _buildIconSelector() {
    return Wrap(
  spacing: 6,  // ✅ Moins d'espace
  runSpacing: 6,
  children: _availableIcons.map((item) {
    final isSelected = _selectedIcon == item['icon'];
    return InkWell(
      onTap: () {
        setState(() => _selectedIcon = item['icon']!);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 56,  // ✅ Plus petit
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getIconData(item['icon']!),
              size: 18,  // ✅ Plus petit
              color: isSelected ? Colors.white : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              item['label']!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 8,  // ✅ Plus petit
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }).toList(),
);
  }

  /// Convertit le code en icône Material.
  IconData _getIconData(String code) {
    switch (code) {
      case 'category':
        return Icons.category_outlined;
      case 'devices':
        return Icons.devices_outlined;
      case 'checkroom':
        return Icons.checkroom_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'sports':
        return Icons.sports_soccer_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'spa':
        return Icons.spa_outlined;
      case 'toys':
        return Icons.toys_outlined;
      case 'menu_book':
        return Icons.menu_book_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  // ============================================
  // UPLOADER D'IMAGE
  // ============================================

  Widget _buildImageUploader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          // Zone d'image
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(height: 12),
          // Bouton upload
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _pickImage(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Choisir une image',
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
        ],
      ),
    );
  }

  /// Placeholder d'image.
  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: AppColors.textLight,
          ),
          SizedBox(height: 8),
          Text(
            'Aucune image',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // CHAMP POSITION
  // ============================================

  Widget _buildPositionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Position',
          style: TextStyle(
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
          child: Row(
            children: [
              const Icon(Icons.swap_vert, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _position.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '$_position',
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.borderColor,
                  onChanged: (value) {
                    setState(() => _position = value.round());
                  },
                ),
              ),
              Text(
                '$_position',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Future<void> _pickImage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sélection d\'image à implémenter'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

// ============================================
// MÉTHODE _save() CORRIGÉE
// ============================================

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final provider = context.read<AdminCategoryProvider>();

    // Créer un objet Category
    final category = Category(
      id: widget.categoryId ?? 0,
      name: _nameController.text.trim(),
      slug: _nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      icon: _selectedIcon,
      position: _position,
      parentId: _parentCategory != null 
          ? provider.getCategoryByName(_parentCategory!)?.id 
          : null,
      isActive: _isActive,
      isFeatured: _isFeatured,
    );

    bool success;
    if (_isEditMode) {
      success = await provider.updateCategory(category);
    } else {
      success = await provider.createCategory(category);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Catégorie modifiée avec succès' : 'Catégorie créée avec succès',
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