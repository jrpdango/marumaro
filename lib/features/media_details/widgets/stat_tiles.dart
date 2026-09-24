part of 'media_details_view.dart';

/// A label/value stat wrapped in an [EditableStatTile], with an optional icon
/// beside the value.
class _TappableStat extends StatelessWidget {
  const _TappableStat({
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return EditableStatTile(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppTokens.spaceXs),
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16.0, color: scheme.secondary),
                const SizedBox(width: AppTokens.spaceXs),
              ],
              Flexible(
                child: Text(
                  value,
                  style: text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The progress stat: current/total, plus a thin progress bar.
class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.total,
    this.onTap,
  });

  final String label;
  final int value;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppTokens.spaceXs),
        Text(
          "$value / ${total > 0 ? total : "-"}",
          style: text.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTokens.spaceSm),
        SizedBox(
          width: double.infinity,
          child: MediaProgressBar(
            value: total > 0 ? (value / total).clamp(0.0, 1.0) : 0.5,
            minHeight: 6.0,
          ),
        ),
      ],
    );
    return EditableStatTile(onTap: onTap, child: content);
  }
}
