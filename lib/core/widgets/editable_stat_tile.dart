import 'package:flutter/material.dart';
import 'package:tamarun/core/theme/app_colors.dart';

/// Wraps a stat in an outlined, tappable tile with a trailing chevron so it
/// reads as editable. When [onTap] is null the tile stays plain and borderless.
class EditableStatTile extends StatelessWidget {
  const EditableStatTile({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget content = Padding(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Row(
        children: <Widget>[
          Expanded(child: child),
          if (onTap != null) ...<Widget>[
            const SizedBox(width: AppTokens.spaceSm),
            Icon(
              Icons.chevron_right,
              size: 20.0,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
