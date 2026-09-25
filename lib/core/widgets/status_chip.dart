import 'package:flutter/material.dart';
import 'package:tamarun/core/theme/app_colors.dart';

/// A rounded, secondary-container pill displaying a list status.
///
/// [dense] shrinks the padding and typography for use inside list cards.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.dense = false});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppTokens.spaceSm : AppTokens.spaceMd,
        vertical: dense ? 2.0 : AppTokens.spaceXs + 2.0,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Text(
        label,
        style: (dense ? text.labelSmall : text.labelMedium)?.copyWith(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
