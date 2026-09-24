import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';

/// A tappable row card for browse lists (rankings and seasons). Unlike
/// [MediaListCard], it carries no list status or progress because browse
/// results are often not on the user's list.
class BrowseListTile extends StatelessWidget {
  const BrowseListTile({
    super.key,
    required this.picture,
    required this.title,
    required this.onTap,
    this.score,
    this.rank,
    this.mediaType,
    this.statusLabel,
  });

  static const double posterHeight = 96.0;
  static const double posterWidth = 68.0;

  final Uri picture;
  final String title;
  final double? score;
  final int? rank;
  final String? mediaType;

  /// The user's list status, shown as a chip when the media is on their list.
  final String? statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        onTap: onTap,
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
                      Text(
                        title,
                        style: text.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (statusLabel != null) ...<Widget>[
                        const SizedBox(height: AppTokens.spaceXs),
                        StatusChip(label: statusLabel!, dense: true),
                      ],
                      const Spacer(),
                      Row(
                        children: <Widget>[
                          if (rank != null) ...<Widget>[
                            _MetaChip(
                              icon: Icons.emoji_events_outlined,
                              label: "#$rank",
                            ),
                            const SizedBox(width: AppTokens.spaceSm),
                          ],
                          if (score != null && score! > 0)
                            _MetaChip(
                              icon: Icons.star_rounded,
                              label: score!.toStringAsFixed(1),
                            ),
                          if (mediaType != null) ...<Widget>[
                            const SizedBox(width: AppTokens.spaceSm),
                            Text(
                              mediaType!.toUpperCase(),
                              style: text.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14.0, color: scheme.primary),
        const SizedBox(width: 2.0),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
