import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/services/image_cache_service.dart';

enum CachedImageShape { rectangle, circle, roundedRectangle }

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final CachedImageShape shape;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final Duration fadeInDuration;
  final bool enableMemoryCache;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = CachedImageShape.rectangle,
    this.borderRadius = 8.0,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableMemoryCache = true,
  });

  @override
  Widget build(BuildContext context) {
    final cacheManager = getIt<ImageCacheService>().cacheManager;

    final Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: cacheManager,
      fadeInDuration: fadeInDuration,
      memCacheWidth: enableMemoryCache ? null : 1, // Désactiver le cache mémoire si nécessaire
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultErrorWidget(),
    );

    // Appliquer la forme appropriée
    switch (shape) {
      case CachedImageShape.circle:
        return ClipOval(
          child: Container(color: backgroundColor, width: width, height: height, child: image),
        );
      case CachedImageShape.roundedRectangle:
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(color: backgroundColor, width: width, height: height, child: image),
        );
      case CachedImageShape.rectangle:
      default:
        return Container(color: backgroundColor, width: width, height: height, child: image);
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      width: width,
      height: height,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.error_outline, color: Colors.grey)),
    );
  }
}
