// Widget de sélection de photo de profil
// Permet de choisir depuis la galerie ou la caméra

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import 'dart:io';

class ProfileImagePicker extends StatefulWidget {
  final String? avatarUrl;
  final String name;
  final Function(String?)? onImageSelected;

  const ProfileImagePicker({
    super.key,
    this.avatarUrl,
    required this.name,
    this.onImageSelected,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    final displayImage = _selectedImagePath ?? widget.avatarUrl;

    return Column(
      children: [
        // Avatar
        GestureDetector(
          onTap: _showImageOptions,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: displayImage != null && displayImage.isNotEmpty
                ? ClipOval(
                    child: _selectedImagePath != null
                        ? Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            displayImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildInitialsAvatar();
                            },
                          ),
                  )
                : _buildInitialsAvatar(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Boutons d'action
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Changer photo
            GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Changer photo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Supprimer (si une photo existe)
            if (displayImage != null && displayImage.isNotEmpty) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 16,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Supprimer',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
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
            fontSize: 32,
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

  // Afficher les options d'image
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
              // Indicateur de glissement
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
              
              // Option Galerie
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
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
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickFromGallery();
                },
              ),
              
              // Option Caméra
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
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
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      debugPrint('Erreur galerie: $e');
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
        setState(() {
          _selectedImagePath = image.path;
        });
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      debugPrint('Erreur caméra: $e');
    }
  }

  // Supprimer l'image
  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
    });
    widget.onImageSelected?.call(null);
  }
}