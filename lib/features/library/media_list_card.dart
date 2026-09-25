import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';

/// A tappable list card showing a poster, title, status, progress, and score.
///
/// Long-pressing opens a quick-edit menu supplied by [onLongPress].
class MediaListCard extends StatelessWidget {
  const MediaListCard({
    super.key,
    required this.picture,
    required this.title,
    required this.progressText,
    required this.score,
    required this.statusLabel,
    required this.onTap,
    this.progressValue,
    this.volumeText,
    this.onLongPress,
  });

  final Uri picture;
  final String title;
  final String progressText;
  final double? progressValue;
  final String? volumeText;
  final String score;
  final String statusLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  static const double posterHeight = 96.0;
  static const double posterWidth = 68.0;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spaceSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                child: AnimePoster(
                  picture: picture,
                  height: posterHeight,
                  width: posterWidth,
                ),
              ),
              const SizedBox(width: AppTokens.spaceMd),
              Expanded(
                child: SizedBox(
                  height: posterHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              style: text.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppTokens.spaceSm),
                          _ScoreBadge(score: score),
                        ],
                      ),
                      const SizedBox(height: AppTokens.spaceXs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(label: statusLabel, dense: true),
                      ),
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          Text(
                            progressText,
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (volumeText != null) ...<Widget>[
                            Text(
                              "  ·  $volumeText",
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppTokens.spaceXs),
                      MediaProgressBar(value: progressValue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final String score;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceSm,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.star_rounded,
            size: 14.0,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: 2.0),
          Text(
            score,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
