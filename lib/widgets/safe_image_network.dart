import 'package:flutter/material.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:aroosi_flutter/theme/colors.dart';

class SafeImageNetwork extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool showRetry;
  final Duration cacheDuration;
  final int? maxWidth;
  final int? maxHeight;

  const SafeImageNetwork({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.showRetry = true,
    this.cacheDuration = const Duration(days: 7),
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        // Performance optimizations
        cacheWidth: maxWidth,
        cacheHeight: maxHeight,
        // Enable caching with custom headers
        headers: {
          'Cache-Control': 'max-age=${cacheDuration.inSeconds}',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          logDebug('Image loading error: $error');
          return _buildErrorWidget();
        },
        // Optimize for memory usage
        filterQuality: FilterQuality.medium,
        isAntiAlias: true,
        // Enable semantic labels for accessibility
        semanticLabel: 'Network image',
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: (width ?? height ?? 48) * 0.5,
              color: Colors.grey[400],
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: (width ?? height ?? 48) * 0.3,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (showRetry) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                // Image reload would need parent callback
                logDebug('Retry image load for: $imageUrl');
              },
              child: Text(
                'Tap to retry',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}