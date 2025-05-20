import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/image_cache_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/cached_image.dart';

class ImageCacheTestScreen extends ConsumerStatefulWidget {
  const ImageCacheTestScreen({super.key});

  @override
  ConsumerState<ImageCacheTestScreen> createState() => _ImageCacheTestScreenState();
}

class _ImageCacheTestScreenState extends ConsumerState<ImageCacheTestScreen> {
  final _imageCacheService = getIt<ImageCacheService>();
  final _navigationService = getIt<NavigationService>();

  bool _isLoading = false;
  String? _statusMessage;
  int _cacheSize = 0;
  String _formattedCacheSize = '0 B';

  // List of test images
  final List<String> _testImages = [
    'https://images.unsplash.com/photo-1682687220063-4742bd7fd538',
    'https://images.unsplash.com/photo-1682695796954-bad0d0f59ff1',
    'https://images.unsplash.com/photo-1682687220566-5599dbbebf11',
    'https://images.unsplash.com/photo-1682687220208-22d7a2543e88',
  ];

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cacheSize = await _imageCacheService.getCacheSize();
      setState(() {
        _cacheSize = cacheSize;
        _formattedCacheSize = _imageCacheService.formatCacheSize(cacheSize);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _preloadImages() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Preloading images...';
    });

    try {
      await _imageCacheService.preloadImages(_testImages);
      await _loadCacheInfo();
      setState(() {
        _statusMessage = 'Images preloaded successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error while preloading: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing cache...';
    });

    try {
      await _imageCacheService.clearCache();
      await _loadCacheInfo();
      setState(() {
        _statusMessage = 'Cache cleared successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error while clearing cache: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Image Cache Test',
        showBackButton: canPop,
        leading:
            !canPop
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _navigationService.navigateTo(context, '/settings'),
                )
                : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestion du Cache d\'Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Current cache size: $_formattedCacheSize'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Preload Images',
                    onPressed: _isLoading ? null : _preloadImages,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Clear Cache',
                    onPressed: _isLoading ? null : _clearCache,
                    isLoading: _isLoading,
                    type: AppButtonType.outline,
                  ),
                ),
              ],
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _statusMessage!.contains('Error')
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_statusMessage!),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Test Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _testImages.length,
              itemBuilder: (context, index) {
                return CachedImage(
                  imageUrl: _testImages[index],
                  shape: CachedImageShape.roundedRectangle,
                  borderRadius: 12,
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Formes d\'Images',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CachedImage(
                      imageUrl: _testImages.isNotEmpty ? _testImages[0] : '',
                      width: 100,
                      height: 100,
                      shape: CachedImageShape.rectangle,
                    ),
                    const SizedBox(height: 8),
                    const Text('Rectangle'),
                  ],
                ),
                Column(
                  children: [
                    CachedImage(
                      imageUrl: _testImages.isNotEmpty ? _testImages[0] : '',
                      width: 100,
                      height: 100,
                      shape: CachedImageShape.roundedRectangle,
                      borderRadius: 16,
                    ),
                    const SizedBox(height: 8),
                    const Text('Rounded'),
                  ],
                ),
                Column(
                  children: [
                    CachedImage(
                      imageUrl: _testImages.isNotEmpty ? _testImages[0] : '',
                      width: 100,
                      height: 100,
                      shape: CachedImageShape.circle,
                    ),
                    const SizedBox(height: 8),
                    const Text('Circle'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              '1. Use "Preload Images" to download images to cache\n'
              '2. Check the cache size after preloading\n'
              '3. Use "Clear Cache" to clear all cached images\n'
              '4. Observe how images load before and after clearing the cache',
            ),
          ],
        ),
      ),
    );
  }
}
