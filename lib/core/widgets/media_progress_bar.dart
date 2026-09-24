import 'package:flutter/material.dart';

/// A thin progress bar that stays still when the total is unknown.
///
/// [LinearProgressIndicator] animates on a loop when its value is null, which
/// looks wrong for ongoing titles with no known episode/chapter total. This
/// renders a static track instead in that case.
class MediaProgressBar extends StatelessWidget {
  const MediaProgressBar({
    super.key,
    required this.value,
    this.minHeight = 5.0,
  });

  /// Progress in the range 0..1, or null when the total is unknown.
  final double? value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color track = Theme.of(context).progressIndicatorTheme.linearTrackColor ??
        scheme.surfaceContainerHighest;
    final BorderRadius radius = BorderRadius.circular(minHeight);

    if (value == null) {
      return Container(
        height: minHeight,
        decoration: BoxDecoration(color: track, borderRadius: radius),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
      ),
    );
  }
}
