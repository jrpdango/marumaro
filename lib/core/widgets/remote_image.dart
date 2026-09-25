import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A network image with a fallback URI and a themed placeholder while loading.
///
/// When [width] is provided the image is sized to a 2:3 poster; otherwise it
/// expands to fill its parent (used for full-bleed backdrops). When [blurSigma]
/// is greater than zero the image is blurred, which is useful for backdrops
/// that sit behind overlaid content.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.uri,
    required this.fallback,
    this.width,
    this.blurSigma = 0.0,
    this.fit = BoxFit.cover,
  });

  final Uri uri;
  final Uri fallback;
  final double? width;
  final double blurSigma;

  /// How the image should be inscribed into its box. Defaults to [BoxFit.cover];
  /// the full-screen viewer uses [BoxFit.contain] to show the whole image.
  final BoxFit fit;

  /// The 2:3 poster height derived from [width], or null for full-bleed images.
  double? get _height => width == null ? null : width! * 1.5;

  /// A themed placeholder that keeps the image's box so the layout does not
  /// collapse while loading or when both URIs fail.
  Widget _placeholder(ColorScheme scheme) => SizedBox(
        width: width,
        height: _height,
        child: ColoredBox(color: scheme.surfaceContainerHighest),
      );

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double? height = _height;
    final Widget image = Image.network(
      uri.toString(),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        if (fallback != uri && fallback.toString().isNotEmpty) {
          return Image.network(
            fallback.toString(),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _placeholder(scheme),
          );
        }
        return _placeholder(scheme);
      },
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? progress) {
        if (progress == null) return child;
        return _placeholder(scheme);
      },
    );
    if (blurSigma <= 0.0) return image;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: ui.TileMode.clamp,
      ),
      child: image,
    );
  }
}
