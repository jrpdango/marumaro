import 'package:flutter/material.dart';

/// A network image with a fallback URI and a themed placeholder while loading.
///
/// When [width] is provided the image is sized to a 2:3 poster; otherwise it
/// expands to fill its parent (used for full-bleed backdrops).
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.uri,
    required this.fallback,
    this.width,
  });

  final Uri uri;
  final Uri fallback;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double? height = width == null ? null : width! * 1.5;
    return Image.network(
      uri.toString(),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        if (fallback != uri && fallback.toString().isNotEmpty) {
          return Image.network(
            fallback.toString(),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                ColoredBox(color: scheme.surfaceContainerHighest),
          );
        }
        return ColoredBox(color: scheme.surfaceContainerHighest);
      },
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? progress) {
        if (progress == null) return child;
        return ColoredBox(color: scheme.surfaceContainerHighest);
      },
    );
  }
}
