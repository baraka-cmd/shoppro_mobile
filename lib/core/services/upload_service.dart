// Service d'upload de fichiers
// Gère l'upload avec progression, compression et erreurs

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final Dio _dio = ApiClient().dio;

  /// Upload d'une image avec progression
  Future<String?> uploadImage({
    required File imageFile,
    required String endpoint,
    String fieldName = 'avatar',
    void Function(double)? onProgress,
  }) async {
    try {
      // Préparer le fichier
      final fileName = imageFile.path.split('/').last;
      final fileSize = await imageFile.length();

      // Créer le FormData
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // Upload avec progression
      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            final progress = sent / total;
            onProgress(progress);
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extraire l'URL de l'image
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['data'] != null && data['data']['avatar_url'] != null) {
            return data['data']['avatar_url'] as String;
          }
          if (data['avatar_url'] != null) {
            return data['avatar_url'] as String;
          }
          if (data['url'] != null) {
            return data['url'] as String;
          }
        }
      }

      return null;
    } on DioException catch (e) {
      debugPrint('Erreur upload: ${e.message}');
      throw _handleUploadError(e);
    } catch (e) {
      debugPrint('Erreur inconnue: $e');
      throw Exception('Erreur lors de l\'upload');
    }
  }

  /// Upload multiple d'images
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String endpoint,
    String fieldName = 'images',
    void Function(double)? onProgress,
  }) async {
    try {
      final formData = FormData();

      for (var i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final fileName = imageFile.path.split('/').last;

        formData.files.add(
          MapEntry(
            '$fieldName[$i]',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0 && onProgress != null) {
            onProgress(sent / total);
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final urls = data['data'] as List<dynamic>;
          return urls.map((url) => url.toString()).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleUploadError(e);
    }
  }

  /// Supprimer une image
  Future<bool> deleteImage({
    required String endpoint,
    required String imageUrl,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: {
          'image_url': imageUrl,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleUploadError(e);
    }
  }

  /// Récupérer la taille du fichier en Mo
  Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Vérifier si le fichier est trop volumineux
  bool isFileTooLarge(double fileSizeInMB, {double maxSizeMB = 5}) {
    return fileSizeInMB > maxSizeMB;
  }

  /// Vérifier le type de fichier
  bool isImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }

  /// Gérer les erreurs d'upload
  Exception _handleUploadError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Délai dépassé lors de l\'upload. Réessayez.');

      case DioExceptionType.connectionError:
        return Exception('Impossible de se connecter au serveur.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 413) {
          return Exception('Fichier trop volumineux.');
        }

        if (statusCode == 415) {
          return Exception('Type de fichier non supporté.');
        }

        if (statusCode == 422) {
          return Exception('Fichier invalide.');
        }

        if (data is Map<String, dynamic> && data['message'] != null) {
          return Exception(data['message'].toString());
        }

        return Exception('Erreur ${statusCode ?? 'inconnue'} lors de l\'upload.');

      default:
        return Exception('Erreur lors de l\'upload.');
    }
  }

  /// Compresser une image (simulation - utiliser image_compress en production)
  Future<File> compressImage(File imageFile) async {
    // TODO: Ajouter le package image_compress pour la compression
    // Pour l'instant, retourner le fichier tel quel
    return imageFile;
  }

  /// Valider une image avant upload
  Future<String?> validateImage(File imageFile) async {
    // Vérifier le type
    if (!isImageFile(imageFile.path)) {
      return 'Format d\'image non supporté';
    }

    // Vérifier la taille
    final sizeInMB = await getFileSizeInMB(imageFile);
    if (isFileTooLarge(sizeInMB)) {
      return 'Image trop volumineuse (max 5MB)';
    }

    return null;
  }
}