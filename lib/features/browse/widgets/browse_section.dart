import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/browse/widgets/media_poster_card.dart';

/// A titled browse section with an optional "View More" action and its content
/// (typically a horizontal carousel).
class BrowseSection extends StatelessWidget {
  const BrowseSection({
    super.key,
    required this.title,
    required this.child,
    this.onViewMore,
  });

  final String title;
  final Widget child;
  final VoidCallback? onViewMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppTokens.spaceLg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onViewMore != null)
                TextButton(
                  onPressed: onViewMore,
                  child: const Text("View More"),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.spaceSm),
        child,
      ],
    );
  }
}

/// A horizontally scrolling carousel of [MediaPosterCard]s.
class BrowseCarousel extends StatelessWidget {
  const BrowseCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaPosterCard.posterHeight + 52.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLg),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: AppTokens.spaceMd),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
