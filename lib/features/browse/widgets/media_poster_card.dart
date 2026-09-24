import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';

/// A compact poster card used in the browse carousels: a 2:3 poster with an
/// optional rank and score badge and the title underneath.
class MediaPosterCard extends StatelessWidget {
  const MediaPosterCard({
    super.key,
    required this.picture,
    required this.title,
    required this.onTap,
    this.score,
    this.rank,
  });

  static const double width = 108.0;
  static const double posterHeight = 162.0;

  final Uri picture;
  final String title;
  final double? score;
  final int? rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: AnimePoster(
                    picture: picture,
                    height: posterHeight,
                    width: width,
                  ),
                ),
                if (rank != null)
                  Positioned(
                    top: AppTokens.spaceXs,
                    left: AppTokens.spaceXs,
                    child: _PosterBadge(
                      text: "#$rank",
                      background: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      foreground: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                    ),
                  ),
                if (score != null && score! > 0)
                  Positioned(
                    bottom: AppTokens.spaceXs,
                    right: AppTokens.spaceXs,
                    child: _PosterBadge(
                      text: score!.toStringAsFixed(1),
                      icon: Icons.star_rounded,
                      background: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      foreground: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceXs),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterBadge extends StatelessWidget {
  const _PosterBadge({
    required this.text,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String text;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceXs,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12.0, color: foreground),
            const SizedBox(width: 2.0),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
