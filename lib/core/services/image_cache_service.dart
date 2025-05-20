import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

@lazySingleton
class ImageCacheService {
  // Instance personnalisée de CacheManager
  static const String _cacheKey = 'customImageCache';

  // Taille maximale du cache en octets (100MB par défaut)
  static const int _defaultMaxCacheSize = 100 * 1024 * 1024;

  // Durée de vie du cache (7 jours par défaut)
  static const Duration _defaultCacheDuration = Duration(days: 7);

  // Gestionnaire de cache
  late final CacheManager _cacheManager;

  // Constructeur
  ImageCacheService() {
    _initCacheManager();
  }

  // Initialiser le gestionnaire de cache
  void _initCacheManager() {
    _cacheManager = CacheManager(
      Config(
        _cacheKey,
        stalePeriod: _defaultCacheDuration,
        maxNrOfCacheObjects: 200,
        repo: JsonCacheInfoRepository(databaseName: _cacheKey),
        fileService: HttpFileService(),
      ),
    );

    AppLogger.debug('ImageCacheService initialized');
  }

  // Obtenir le gestionnaire de cache
  CacheManager get cacheManager => _cacheManager;

  // Précharger une image depuis une URL
  Future<void> preloadImage(String url) async {
    try {
      await _cacheManager.getSingleFile(url);
      AppLogger.debug('Image préchargée: $url');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors du préchargement de l\'image', e, stackTrace);
    }
  }

  // Précharger plusieurs images depuis des URLs
  Future<void> preloadImages(List<String> urls) async {
    try {
      final futures = urls.map(preloadImage);
      await Future.wait(futures);
      AppLogger.debug('${urls.length} images préchargées');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors du préchargement des images', e, stackTrace);
    }
  }

  // Obtenir une image depuis le cache (ou la télécharger si elle n'est pas en cache)
  Future<File?> getImage(String url) async {
    try {
      final file = await _cacheManager.getSingleFile(url);
      return file;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la récupération de l\'image', e, stackTrace);
      return null;
    }
  }

  // Obtenir les données binaires d'une image
  Future<Uint8List?> getImageData(String url) async {
    try {
      final file = await getImage(url);
      if (file != null) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la récupération des données de l\'image', e, stackTrace);
      return null;
    }
  }

  // Vérifier si une image est en cache
  Future<bool> isImageCached(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      return fileInfo != null;
    } catch (e) {
      AppLogger.error('Erreur lors de la vérification du cache', e);
      return false;
    }
  }

  // Supprimer une image spécifique du cache
  Future<void> removeImage(String url) async {
    try {
      await _cacheManager.removeFile(url);
      AppLogger.debug('Image supprimée du cache: $url');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors de la suppression de l\'image du cache', e, stackTrace);
    }
  }

  // Vider tout le cache d'images
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      // Vider également le cache interne de CachedNetworkImage
      await DefaultCacheManager().emptyCache();
      imageCache.clear();
      imageCache.clearLiveImages();
      AppLogger.debug('Cache d\'images vidé. Taille actuelle du cache: ${imageCache.currentSize}');
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors du vidage du cache d\'images', e, stackTrace);
    }
  }

  // Obtenir la taille actuelle du cache
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final cacheFiles = await _listFilesRecursively(cacheDir);

      var totalSize = 0;
      for (final file in cacheFiles) {
        final stat = await file.stat();
        totalSize += stat.size;
      }

      return totalSize;
    } catch (e, stackTrace) {
      AppLogger.error('Erreur lors du calcul de la taille du cache', e, stackTrace);
      return 0;
    }
  }

  // Lister tous les fichiers récursivement dans un répertoire
  Future<List<File>> _listFilesRecursively(Directory dir) async {
    final files = <File>[];
    final entities = await dir.list().toList();

    for (final entity in entities) {
      if (entity is File) {
        files.add(entity);
      } else if (entity is Directory) {
        files.addAll(await _listFilesRecursively(entity));
      }
    }

    return files;
  }

  // Formater la taille du cache en unité lisible (KB, MB, GB)
  String formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
