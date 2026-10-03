// ============================================
// SERVICE DE TÉLÉCHARGEMENT DE FICHIERS - SHOPPRO
// ============================================
// Télécharge, ouvre et partage des fichiers PDF
// depuis l'API Laravel.
// Gère : permissions, cache, ouverture, partage.
// ============================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../network/api_client.dart';

class FileDownloadService {
  // ─────────────────────────────────────────────
  // SINGLETON
  // ─────────────────────────────────────────────
  static final FileDownloadService _instance =
      FileDownloadService._internal();
  factory FileDownloadService() => _instance;
  FileDownloadService._internal();

  final Dio _dio = ApiClient().dio;

  // ─────────────────────────────────────────────
  // TÉLÉCHARGER UN PDF
  // ─────────────────────────────────────────────
  /// Télécharge un PDF depuis l'API et le sauvegarde localement.
  /// Retourne le chemin du fichier ou null en cas d'échec.
  ///
  /// [endpoint] : ex '/orders/1/invoice'
  /// [filename] : ex 'facture-CMD-20261001-ABC123.pdf'
  Future<File?> downloadPdf({
    required String endpoint,
    required String filename,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // 1. Préparer le dossier de destination
      final dir = await _getDownloadDirectory();
      if (dir == null) {
        debugPrint('❌ Impossible d\'accéder au dossier de téléchargement');
        return null;
      }

      final filePath = '${dir.path}/$filename';
      final file = File(filePath);

      // 2. Vérifier si le fichier existe déjà (cache)
      if (await file.exists()) {
        final size = await file.length();
        if (size > 0) {
          debugPrint('✅ Fichier déjà en cache : $filePath');
          return file;
        } else {
          // Fichier corrompu → supprimer
          await file.delete();
        }
      }

      // 3. Télécharger depuis l'API
      final fullUrl = '${ApiClient().dio.options.baseUrl}$endpoint';
      // 3. Télécharger depuis l'API
      debugPrint('⬇️ Téléchargement : $endpoint → $filename');

      final response = await _dio.download(
        endpoint,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        debugPrint('❌ Statut HTTP ${response.statusCode}');
        if (await file.exists()) await file.delete();
        return null;
      }

      // 4. Vérifier que le fichier est valide
      if (!await file.exists()) {
        debugPrint('❌ Fichier non créé');
        return null;
      }

      final size = await file.length();
      if (size == 0) {
        debugPrint('❌ Fichier vide');
        await file.delete();
        return null;
      }

      debugPrint('✅ PDF téléchargé ($size bytes) : $filePath');
      return file;
    } on DioException catch (e) {
      debugPrint('❌ Erreur Dio : ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Erreur downloadPdf : $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // OUVRIR UN PDF
  // ─────────────────────────────────────────────
  /// Ouvre un fichier PDF avec l'application par défaut.
  /// Retourne true si l'ouverture a réussi.
  Future<bool> openFile(File file) async {
    try {
      if (!await file.exists()) {
        debugPrint('❌ Fichier introuvable : ${file.path}');
        return false;
      }

      final result = await OpenFilex.open(file.path);

      if (result.type == ResultType.done) {
        debugPrint('✅ Fichier ouvert');
        return true;
      } else {
        debugPrint('⚠️ Ouverture : ${result.type} - ${result.message}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erreur openFile : $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // PARTAGER UN PDF
  // ─────────────────────────────────────────────
  /// Partage un fichier PDF via l'application de partage native.
  Future<bool> shareFile({
    required File file,
    String? subject,
    String? text,
  }) async {
    try {
      if (!await file.exists()) {
        debugPrint('❌ Fichier introuvable : ${file.path}');
        return false;
      }

      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
        text: text,
      );

      if (result.status == ShareResultStatus.success) {
        debugPrint('✅ Fichier partagé');
        return true;
      } else if (result.status == ShareResultStatus.dismissed) {
        debugPrint('⚠️ Partage annulé');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Erreur shareFile : $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // SUPPRIMER UN FICHIER
  // ─────────────────────────────────────────────
  /// Supprime un fichier téléchargé (utile pour vider le cache).
  Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Fichier supprimé : ${file.path}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erreur deleteFile : $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // VIDER LE CACHE
  // ─────────────────────────────────────────────
  /// Supprime tous les fichiers téléchargés (factures, etc.)
  Future<void> clearCache() async {
    try {
      final dir = await _getDownloadDirectory();
      if (dir == null) return;

      if (await dir.exists()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
        debugPrint('🗑️ Cache vidé (${files.length} fichiers)');
      }
    } catch (e) {
      debugPrint('❌ Erreur clearCache : $e');
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS PRIVÉS
  // ─────────────────────────────────────────────

  /// Récupère le dossier de téléchargement approprié.
  /// - Android : /storage/emulated/0/Download/ShopPro (si permission)
  /// - iOS : Documents/ShopPro
  /// - Sinon : dossier temporaire
  Future<Directory?> _getDownloadDirectory() async {
    try {
      // Sur iOS → dossier Documents
      if (Platform.isIOS) {
        final docs = await getApplicationDocumentsDirectory();
        return _ensureSubdirectory(docs, 'ShopPro');
      }

      // Sur Android → essayer Download public
      if (Platform.isAndroid) {
        // Vérifier la permission (Android 13+ n'a pas besoin)
        final hasPermission = await _ensureStoragePermission();
        if (hasPermission) {
          final publicDir = Directory('/storage/emulated/0/Download/ShopPro');
          if (!await publicDir.exists()) {
            await publicDir.create(recursive: true);
          }
          return publicDir;
        }
      }

      // Fallback : dossier temporaire
      final temp = await getTemporaryDirectory();
      return _ensureSubdirectory(temp, 'ShopPro');
    } catch (e) {
      debugPrint('❌ Erreur _getDownloadDirectory : $e');
      return null;
    }
  }

  /// Crée un sous-dossier dans le dossier parent s'il n'existe pas.
  Future<Directory> _ensureSubdirectory(Directory parent, String name) async {
    final sub = Directory('${parent.path}/$name');
    if (!await sub.exists()) {
      await sub.create(recursive: true);
    }
    return sub;
  }

  /// Demande la permission de stockage si nécessaire.
  /// Sur Android 13+ (API 33+), plus besoin.
  Future<bool> _ensureStoragePermission() async {
    try {
      // Android 13+ → pas besoin de permission pour Download
      if (Platform.isAndroid) {
        // Permission accordée d'office sur Android 13+
        final status = await Permission.storage.status;
        if (status.isGranted) return true;

        // Demander seulement si refusée
        final requested = await Permission.storage.request();
        return requested.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('⚠️ Erreur permission : $e');
      return false;
    }
  }
}