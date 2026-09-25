import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:miru/core/theme/app_colors.dart';

/// A translucent scrim drawn over a header backdrop so overlaid content stays
/// legible no matter how bright the underlying image is.
///
/// The default constructor paints a uniform scrim for full-bleed headers.
/// [HeaderScrim.fade] instead keeps a strong band behind the status bar and
/// toolbar, clears through the middle so the artwork shows, then eases into
/// [ColorScheme.surface] at the bottom.
///
/// Both variants derive their color from [ColorScheme.surface], so they adapt
/// to the light, dark, and AMOLED themes.
class HeaderScrim extends StatelessWidget {
  const HeaderScrim({super.key}) : _fade = false;

  const HeaderScrim.fade({super.key}) : _fade = true;

  final bool _fade;

  /// Number of color stops used to approximate the eased alpha profile.
  static const int _samples = 24;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (!_fade) {
      return ColoredBox(
        color: scheme.surface.withValues(alpha: AppTokens.scrimSolid),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedHeight || constraints.maxHeight <= 0.0) {
          return ColoredBox(
            color: scheme.surface.withValues(alpha: AppTokens.scrimSolid),
          );
        }

        final double extent = constraints.maxHeight;
        final double toolbarEnd =
            (MediaQuery.paddingOf(context).top + kToolbarHeight) / extent;
        final double topFadeStart = (toolbarEnd - 0.04).clamp(0.0, 1.0);
        final double topFadeEnd = (toolbarEnd + 0.14).clamp(0.0, 1.0);
        final double bottomFadeStart = (topFadeEnd + 0.06).clamp(0.0, 1.0);

        double alphaAt(double fraction) {
          final double top =
              1.0 - _smoothstep(topFadeStart, topFadeEnd, fraction);
          final double bottom = _smoothstep(bottomFadeStart, 1.0, fraction);
          return math.max(AppTokens.scrimTop * top, bottom);
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: List<Color>.generate(
                _samples + 1,
                (int i) =>
                    scheme.surface.withValues(alpha: alphaAt(i / _samples)),
              ),
              stops: List<double>.generate(
                _samples + 1,
                (int i) => i / _samples,
              ),
            ),
          ),
        );
      },
    );
  }
}

double _smoothstep(double edge0, double edge1, double x) {
  if (edge1 <= edge0) {
    return x < edge0 ? 0.0 : 1.0;
  }
  final double t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}
