part of 'media_details_view.dart';

/// The collapsing app-bar header: backdrop, gradient scrim, title actions, and
/// the status chip pinned to the bottom-right.
class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.data,
    required this.inList,
    required this.showStats,
    required this.onEditTap,
    required this.onRemove,
  });

  final MediaDetailsData data;
  final bool inList;
  final bool showStats;
  final VoidCallback onEditTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200.0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      title: Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      titleTextStyle: text.titleMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      actions: <Widget>[
        if (showStats)
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
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double currentExtent = constraints.maxHeight;
          final double minExtent =
              MediaQuery.paddingOf(context).top + kToolbarHeight;
          final double chipOpacity =
              ((currentExtent - minExtent) / (2.0 * kToolbarHeight))
                  .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: RemoteImage(
                  uri: data.backdrop,
                  fallback: data.poster,
                  blurSigma: AppTokens.backdropBlur,
                ),
              ),
              const HeaderScrim.fade(),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: AppTokens.spaceLg,
                    bottom: AppTokens.spaceXl + AppTokens.spaceSm,
                  ),
                  child: Opacity(
                    opacity: chipOpacity,
                    child: StatusChip(label: data.statusLabel),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
