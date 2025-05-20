import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

@lazySingleton
class ImageCacheService {
  // Custom instance of CacheManager
  static const String _cacheKey = 'customImageCache';

  // Maximum cache size in bytes (100MB by default)
  static const int _defaultMaxCacheSize = 100 * 1024 * 1024;

  // Cache lifetime (7 days by default)
  static const Duration _defaultCacheDuration = Duration(days: 7);

  // Cache manager
  late final CacheManager _cacheManager;

  // Constructor
  ImageCacheService() {
    _initCacheManager();
  }

  // Initialize cache manager
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

  // Get cache manager
  CacheManager get cacheManager => _cacheManager;

  // Preload an image from a URL
  Future<void> preloadImage(String url) async {
    try {
      await _cacheManager.getSingleFile(url);
      AppLogger.debug('Image preloaded: $url');
    } catch (e, stackTrace) {
      AppLogger.error('Error while preloading images', e, stackTrace);
    }
  }

  // Preload multiple images from URLs
  Future<void> preloadImages(List<String> urls) async {
    try {
      final futures = urls.map(preloadImage);
      await Future.wait(futures);
      AppLogger.debug('${urls.length} images preloaded');
    } catch (e, stackTrace) {
      AppLogger.error('Error while preloading images', e, stackTrace);
    }
  }

  // Get an image from cache (or download it if not cached)
  Future<File?> getImage(String url) async {
    try {
      final file = await _cacheManager.getSingleFile(url);
      return file;
    } catch (e, stackTrace) {
      AppLogger.error('Error while retrieving image', e, stackTrace);
      return null;
    }
  }

  // Get binary data of an image
  Future<Uint8List?> getImageData(String url) async {
    try {
      final file = await getImage(url);
      if (file != null) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error while retrieving image data', e, stackTrace);
      return null;
    }
  }

  // Check if an image is cached
  Future<bool> isImageCached(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      return fileInfo != null;
    } catch (e) {
      AppLogger.error('Error while checking cache', e);
      return false;
    }
  }

  // Remove a specific image from cache
  Future<void> removeImage(String url) async {
    try {
      await _cacheManager.removeFile(url);
      AppLogger.debug('Image removed from cache: $url');
    } catch (e, stackTrace) {
      AppLogger.error('Error while deleting image from cache', e, stackTrace);
    }
  }

  // Clear all image cache
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      // Also clear CachedNetworkImage's internal cache
      await DefaultCacheManager().emptyCache();
      imageCache.clear();
      imageCache.clearLiveImages();
      AppLogger.debug('Image cache cleared. Current cache size: ${imageCache.currentSize}');
    } catch (e, stackTrace) {
      AppLogger.error('Error while clearing image cache', e, stackTrace);
    }
  }

  // Get current cache size
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
      AppLogger.error('Error while calculating cache size', e, stackTrace);
      return 0;
    }
  }

  // List all files recursively in a directory
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

  // Format cache size in readable unit (KB, MB, GB)
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
