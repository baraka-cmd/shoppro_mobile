// Widget d'upload d'avatar complet
// Avec sélection, progression, validation et affichage en temps réel

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/upload_service.dart';

class AvatarUploader extends StatefulWidget {
  final String? avatarUrl;
  final String name;
  final Function(String?)? onAvatarUpdated;

  const AvatarUploader({
    super.key,
    this.avatarUrl,
    required this.name,
    this.onAvatarUpdated,
  });

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();

  String? _selectedImagePath;
  double _uploadProgress = 0;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final displayImage = _selectedImagePath ?? widget.avatarUrl;

    return Column(
      children: [
        // Avatar avec overlay de progression
        Stack(
          alignment: Alignment.center,
          children: [
            // Avatar
            GestureDetector(
              onTap: _isUploading ? null : _showImageOptions,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: displayImage != null && displayImage.isNotEmpty
                    ? _selectedImagePath != null
                        ? ClipOval(
                            child: Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: Image.network(
                              displayImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildInitialsAvatar();
                              },
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _buildInitialsAvatar();
                              },
                            ),
                          )
                    : _buildInitialsAvatar(),
              ),
            ),

            // Overlay de progression
            if (_isUploading)
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: _uploadProgress,
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

            // Bouton caméra (badge)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _showImageOptions,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 15),
        
        // Message d'erreur
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        
        // Boutons d'action
        if (!_isUploading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Changer photo
              _buildActionButton(
                icon: Icons.photo_library,
                label: 'Changer',
                color: AppColors.primary,
                onTap: _showImageOptions,
              ),
              
              // Supprimer (si photo existe)
              if (displayImage != null && displayImage.isNotEmpty) ...[
                const SizedBox(width: 10),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Supprimer',
                  color: AppColors.error,
                  onTap: _removeImage,
                ),
              ],
            ],
          ),
      ],
    );
  }

  // Bouton d'action
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Avatar avec initiales
  Widget _buildInitialsAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Center(
        child: Text(
          _getInitials(widget.name),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Récupérer les initiales
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // Afficher les options
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),
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
                'Changer la photo de profil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              
              // Galerie
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Choisir depuis la galerie',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'JPG, PNG, WebP (max 5MB)',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickFromGallery();
                },
              ),
              
              // Caméra
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Prendre une photo',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Utiliser la caméra',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickFromCamera();
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Sélectionner depuis la galerie
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection';
      });
    }
  }

  // Prendre une photo
  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la prise de photo';
      });
    }
  }

  // Traiter l'image sélectionnée
  Future<void> _processImage(File imageFile) async {
    // Valider l'image
    final validationError = await _uploadService.validateImage(imageFile);

    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    // Afficher l'image sélectionnée
    setState(() {
      _selectedImagePath = imageFile.path;
      _errorMessage = null;
    });

    // Uploader
    await _uploadImage(imageFile);
  }

  // Uploader l'image
  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final uploadedUrl = await _uploadService.uploadImage(
        imageFile: imageFile,
        endpoint: '/auth/upload-avatar',
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _isUploading = false;
        _uploadProgress = 1;
      });

      if (uploadedUrl != null) {
        // Mise à jour réussie
        widget.onAvatarUpdated?.call(uploadedUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo de profil mise à jour !',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // Supprimer l'image
  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
      _errorMessage = null;
    });
    widget.onAvatarUpdated?.call(null);
  }
}