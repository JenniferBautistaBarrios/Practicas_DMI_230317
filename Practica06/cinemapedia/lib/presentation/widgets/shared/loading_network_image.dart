import 'package:flutter/material.dart';

/// Network image with a visible progress indicator while bytes are downloading.
class LoadingNetworkImage extends StatelessWidget {
  const LoadingNetworkImage({
    super.key,
    required this.url,
    this.fit,
    this.width,
    this.height,
  });

  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return ColoredBox(
          color: colors.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              color: colors.primary,
              value: total == null ? null : progress.cumulativeBytesLoaded / total,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
