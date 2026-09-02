// ============================================
// PAGE : AdminBannerFormScreen
// ============================================
// Écran de création/modification de bannière mobile.
// Design avec formulaire organisé en sections.
//
// Structure :
// - AdminScaffold (AppBar + Drawer + BottomNavBar)
// - Formulaire en cartes
// - Sections : Infos, Image, Position, Période, Options
// - Aperçu en temps réel
// - Boutons Annuler / Enregistrer
// ============================================

// ============================================
// IMPORTS
// ============================================

// Flutter
import 'package:flutter/material.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

// Widgets (même feature admin)
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_confirm_dialog.dart';
// Pour provider
import 'package:provider/provider.dart';

// Pour BannerProvider (dans admin_banner_form_screen.dart)
import '../../../home/presentation/providers/banner_provider.dart';
import 'package:provider/provider.dart';
import '../../../home/presentation/providers/banner_provider.dart';

// ============================================
// PAGE PRINCIPALE
// ============================================

/// Écran de formulaire bannière mobile.
///
/// Permet de :
/// - Créer une nouvelle bannière
/// - Modifier une bannière existante
class AdminBannerFormScreen extends StatefulWidget {
  /// ID de la bannière à modifier (null = création)
  final int? bannerId;

  const AdminBannerFormScreen({super.key, this.bannerId});

  @override
  State<AdminBannerFormScreen> createState() => _AdminBannerFormScreenState();
}

// ============================================
// STATE
// ============================================

class _AdminBannerFormScreenState extends State<AdminBannerFormScreen> {
  // ============================================
  // CONTRÔLEURS
  // ============================================

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _externalUrlController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // ============================================
  // ÉTAT
  // ============================================

  bool _isSaving = false;
  bool _isEditMode = false;
  bool _isActive = true;
  bool _isAnimated = false;
  String? _imagePath;
  String _selectedPosition = 'home_top';
  String _selectedTargetType = 'none';
  DateTime? _startDate;
  DateTime? _endDate;

  // ============================================
  // INIT
  // ============================================

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.bannerId != null;
    if (_isEditMode) {
      _loadBanner();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _externalUrlController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  // ============================================
  // CHARGEMENT
  // ============================================

  Future<void> _loadBanner() async {
  try {
    final provider = context.read<BannerProvider>();
    final bannerId = widget.bannerId;

    if (bannerId == null) return;

    final banner = provider.banners.firstWhere(
      (b) => b.id == bannerId,
      orElse: () => throw Exception('Bannière introuvable'),
    );

    setState(() {
      _titleController.text = banner.title ?? '';
      _subtitleController.text = banner.subtitle ?? '';
      _descriptionController.text = banner.description ?? '';
      _externalUrlController.text = banner.externalUrl ?? '';
      _selectedPosition = banner.position ?? 'home_top';
      _selectedTargetType = banner.targetType ?? 'none';
      _isActive = banner.isActive ?? true;
      _isAnimated = banner.isAnimated ?? false;
      _imagePath = banner.imageUrl;
      if (banner.startDate != null) {
        _startDate = DateTime.tryParse(banner.startDate.toString());
        _startDateController.text = _formatDate(_startDate);
      }
      if (banner.endDate != null) {
        _endDate = DateTime.tryParse(banner.endDate.toString());
        _endDateController.text = _formatDate(_endDate);
      }
    });
  } catch (e) {
    debugPrint('Erreur _loadBanner: $e');
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
          ? 'Modifiez les informations'
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
      onLogout: () {},
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
          // SECTION : INFORMATIONS
          // ============================================
          _buildSectionCard(
            title: 'Informations',
            icon: Icons.info_outline,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Titre *',
                hint: 'Ex: Soldes d\'été -50%',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _subtitleController,
                label: 'Sous-titre',
                hint: 'Offre limitée',
                icon: Icons.subtitles_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextArea(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Description de la bannière...',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // SECTION : IMAGE
          // ============================================
          _buildSectionCard(
            title: 'Image',
            icon: Icons.image_outlined,
            children: [
              _buildImageUploader(),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // SECTION : POSITION
          // ============================================
          _buildSectionCard(
            title: 'Position',
            icon: Icons.place_outlined,
            children: [
              _buildPositionSelector(),
              const SizedBox(height: 12),
              _buildTargetTypeSelector(),
              if (_selectedTargetType == 'external_url') ...[
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _externalUrlController,
                  label: 'URL externe *',
                  hint: 'https://exemple.com',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // SECTION : PÉRIODE
          // ============================================
          _buildSectionCard(
            title: 'Période d\'affichage',
            icon: Icons.calendar_today,
            children: [
              _buildDateField(
                controller: _startDateController,
                label: 'Date de début',
                icon: Icons.calendar_today,
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 12),
              _buildDateField(
                controller: _endDateController,
                label: 'Date de fin',
                icon: Icons.event,
                onTap: () => _pickDate(false),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // SECTION : OPTIONS
          // ============================================
          _buildSectionCard(
            title: 'Options',
            icon: Icons.tune,
            children: [
              _buildSwitchRow(
                label: 'Bannière active',
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 8),
              _buildSwitchRow(
                label: 'Bannière animée',
                value: _isAnimated,
                onChanged: (value) => setState(() => _isAnimated = value),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // APERÇU
          // ============================================
          _buildPreviewSection(),

          const SizedBox(height: 20),

          // ============================================
          // BOUTONS D'ACTION
          // ============================================
          Row(
            children: [
              Expanded(
                child: _buildCancelButton(),
              ),
              const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(14),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: AppColors.info),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ============================================
  // SÉLECTEUR DE POSITION
  // ============================================

  Widget _buildPositionSelector() {
    final positions = [
      {'label': 'Haut', 'code': 'home_top', 'icon': Icons.vertical_align_top},
      {'label': 'Milieu', 'code': 'home_middle', 'icon': Icons.vertical_align_center},
      {'label': 'Bas', 'code': 'home_bottom', 'icon': Icons.vertical_align_bottom},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Position',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: positions.map((position) {
            final isSelected = _selectedPosition == position['code'];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: position != positions.last ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPosition = position['code'] as String;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                          position['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          position['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textTertiary,
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
  // SÉLECTEUR DE TYPE DE CIBLE
  // ============================================

  Widget _buildTargetTypeSelector() {
    final targetTypes = [
      {'label': 'Aucun', 'code': 'none', 'icon': Icons.block},
      {'label': 'Produit', 'code': 'product', 'icon': Icons.inventory_2_outlined},
      {'label': 'Catégorie', 'code': 'category', 'icon': Icons.category_outlined},
      {'label': 'Promotion', 'code': 'promotion', 'icon': Icons.local_offer_outlined},
      {'label': 'URL', 'code': 'external_url', 'icon': Icons.link},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de cible',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: targetTypes.map((type) {
            final isSelected = _selectedTargetType == type['code'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTargetType = type['code'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      size: 13,
                      color: isSelected ? Colors.white : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================
  // UPLOADER D'IMAGE
  // ============================================

  Widget _buildImageUploader() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
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
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: AppColors.textLight),
          SizedBox(height: 6),
          Text(
            'Aucune image',
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
  // APERÇU
  // ============================================

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'Aperçu',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? 'Titre de la bannière'
                            : _titleController.text,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_subtitleController.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _subtitleController.text,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Sélectionner' : controller.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: controller.text.isEmpty
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textLight,
            ),
            prefixIcon: icon != null
                ? Icon(icon, size: 16, color: AppColors.textTertiary)
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
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
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColorDark),
          ),
          child: const Text(
            'Annuler',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.save_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _isSaving ? 'Enregistrement...' : 'Enregistrer',
                style: const TextStyle(
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

  Future<void> _pickDate(bool isStartDate) async {
    final now = DateTime.now();
    final initialDate = isStartDate
        ? (_startDate ?? now)
        : (_endDate ?? now.add(const Duration(days: 30)));

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
// MÉTHODE _save() CORRIGÉE
// ============================================

Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final provider = context.read<BannerProvider>();

    // Créer les données de la bannière
    final bannerData = {
      'title': _titleController.text.trim(),
      'subtitle': _subtitleController.text.trim().isEmpty 
          ? null 
          : _subtitleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      'image': _imagePath,
      'position': _selectedPosition,
      'target_type': _selectedTargetType,
      'external_url': _selectedTargetType == 'external_url' 
          ? _externalUrlController.text.trim() 
          : null,
      'start_date': _startDate?.toIso8601String(),
      'end_date': _endDate?.toIso8601String(),
      'is_active': _isActive,
      'is_animated': _isAnimated,
    };

    bool success;
    if (_isEditMode) {
      success = await provider.updateBanner(widget.bannerId ?? 0, bannerData);
    } else {
      success = await provider.createBanner(bannerData);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Bannière modifiée avec succès' : 'Bannière créée avec succès',
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