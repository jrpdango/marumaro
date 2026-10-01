import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';

/// A compact stat card: an optional icon and label, a prominent value, an
/// optional caption, and an optional progress bar.
class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.caption,
    this.progress,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? caption;

  /// Progress in the range 0..1, rendered under the value when supplied.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 16.0, color: scheme.secondary),
                  const SizedBox(width: AppTokens.spaceXs),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXs),
            Text(
              value,
              style: text.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (caption != null)
              Text(
                caption!,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            if (progress != null) ...<Widget>[
              const SizedBox(height: AppTokens.spaceSm),
              MediaProgressBar(value: progress, minHeight: 6.0),
            ],
          ],
        ),
      ),
    );
  }
}
