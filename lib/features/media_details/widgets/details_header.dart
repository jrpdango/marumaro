part of 'media_details_view.dart';

/// The collapsing app-bar header: backdrop, gradient scrim, title actions, and
/// the status chip pinned to the bottom-right.
class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.data,
    required this.inList,
    required this.onEditTap,
    required this.onRemove,
  });

  final MediaDetailsData data;
  final bool inList;
  final VoidCallback onEditTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 280.0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      title: Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      titleTextStyle: text.titleMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      actions: <Widget>[
        IconButton(
          onPressed: onEditTap,
          icon: const Icon(Icons.edit_outlined),
          tooltip: "Edit",
        ),
        if (inList)
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == "remove") onRemove();
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: "remove",
                child: Text("Remove from list"),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            RemoteImage(uri: data.backdrop, fallback: data.poster),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    scheme.surface.withValues(alpha: 0.55),
                    scheme.surface.withValues(alpha: 0.0),
                    scheme.surface.withValues(alpha: 0.85),
                    scheme.surface,
                  ],
                  stops: const <double>[0.0, 0.35, 0.78, 1.0],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppTokens.spaceLg,
                  bottom: AppTokens.spaceXl + AppTokens.spaceSm,
                ),
                child: StatusChip(label: data.statusLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
