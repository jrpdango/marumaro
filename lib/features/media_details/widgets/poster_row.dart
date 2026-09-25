part of 'media_details_view.dart';

/// The poster thumbnail beside the title, mean score, rank, and media type.
class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.data});

  final MediaDetailsData data;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          child: RemoteImage(
            uri: data.poster,
            fallback: data.poster,
            width: 96.0,
          ),
        ),
        const SizedBox(width: AppTokens.spaceLg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.title,
                style: text.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTokens.spaceSm),
              Row(
                children: <Widget>[
                  Icon(Icons.star_rounded, size: 18.0, color: scheme.secondary),
                  const SizedBox(width: AppTokens.spaceXs),
                  Text(
                    data.meanScore > 0
                        ? data.meanScore.toStringAsFixed(2)
                        : "-",
                    style: text.titleSmall,
                  ),
                ],
              ),
              if (data.rank != null || data.mediaType != null) ...<Widget>[
                const SizedBox(height: AppTokens.spaceXs),
                Text(
                  <String>[
                    if (data.rank != null) "Rank #${data.rank}",
                    if (data.mediaType != null) data.mediaType!.toUpperCase(),
                  ].join("  ·  "),
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
