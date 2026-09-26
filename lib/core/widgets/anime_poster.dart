import 'package:flutter/material.dart';

/// Displays an anime poster, falling back to a placeholder on load errors.
class AnimePoster extends StatelessWidget {
  const AnimePoster({
    super.key,
    required this.picture,
    this.height = 90.0,
    this.width = 65.0,
  });

  final Uri picture;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      picture.toString(),
      fit: BoxFit.cover,
      height: height,
      width: width,
      cacheHeight: height.round(),
      cacheWidth: width.round(),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : _PlaceholderPoster(height: height, width: width),
      errorBuilder: (context, error, stackTrace) =>
          _PlaceholderPoster(height: height, width: width),
    );
  }
}

/// A code-drawn stand-in shown while a poster loads or when it fails.
class _PlaceholderPoster extends StatelessWidget {
  const _PlaceholderPoster({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: height * 0.4,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
