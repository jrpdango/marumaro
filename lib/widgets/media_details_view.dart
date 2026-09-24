import 'package:flutter/material.dart';
import 'package:miru/models/media_details_data.dart';
import 'package:miru/theme/app_colors.dart';
import 'package:miru/widgets/media_progress_bar.dart';

/// The shared Anime/Manga details page body: a collapsing header followed by
/// the status card, synopsis, genres, alternative titles, and information grid.
/// The status card holds the quick edit controls, with a sticky action bar that
/// appears only while there are unsaved changes.
class MediaDetailsView extends StatelessWidget {
  const MediaDetailsView({
    super.key,
    required this.data,
    required this.statusLabel,
    required this.score,
    required this.progress,
    required this.progressTotal,
    required this.progressLabel,
    required this.dirty,
    required this.onStatusTap,
    required this.onScoreTap,
    required this.onEditTap,
    required this.onProgressDelta,
    required this.onSave,
    required this.onDiscard,
    required this.onRemove,
    this.onProgressTap,
    this.saving = false,
  });

  final MediaDetailsData data;
  final String statusLabel;
  final int score;
  final int progress;
  final int progressTotal;
  final String progressLabel;
  final bool dirty;
  final bool saving;
  final VoidCallback onStatusTap;
  final VoidCallback onScoreTap;
  final VoidCallback onEditTap;
  final ValueChanged<int> onProgressDelta;
  final VoidCallback? onProgressTap;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.spaceLg,
                AppTokens.spaceLg,
                AppTokens.spaceLg,
                AppTokens.spaceXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildPosterRow(context),
                  const SizedBox(height: AppTokens.spaceLg),
                  _buildStatusCard(context),
                  if (data.synopsis != null) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _SynopsisSection(synopsis: data.synopsis!),
                  ],
                  if (data.genres.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _buildGenres(context),
                  ],
                  if (_hasAltTitles) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _buildAltTitles(context),
                  ],
                  if (data.infoRows.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _buildInformation(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: dirty
          ? _DetailsActionBar(
              saving: saving,
              onSave: onSave,
              onDiscard: onDiscard,
            )
          : null,
    );
  }

  bool get _hasAltTitles =>
      data.englishTitle != null ||
      data.japaneseTitle != null ||
      data.synonyms.isNotEmpty;

  Widget _buildHeader(BuildContext context) {
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
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == "remove") onRemove();
          },
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
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
            _Backdrop(uri: data.backdrop, fallback: data.poster),
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
                child: _StatusChip(label: data.statusLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterRow(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Hero(
          tag: data.heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            child: _Backdrop(uri: data.poster, fallback: data.poster, width: 96.0),
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
                    data.meanScore > 0 ? data.meanScore.toStringAsFixed(2) : "-",
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

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _TappableStat(
                      label: "Status",
                      value: statusLabel,
                      onTap: onStatusTap,
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceSm),
                  Expanded(
                    child: _TappableStat(
                      label: "Score",
                      value: "$score",
                      icon: Icons.star_rounded,
                      onTap: onScoreTap,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spaceSm),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => onProgressDelta(-1),
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: "Decrease $progressLabel",
                ),
                Expanded(
                  child: _ProgressStat(
                    label: progressLabel,
                    value: progress,
                    total: progressTotal,
                    onTap: onProgressTap,
                  ),
                ),
                IconButton(
                  onPressed: () => onProgressDelta(1),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: "Increase $progressLabel",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenres(BuildContext context) {
    return _Section(
      title: "Genres",
      child: Wrap(
        spacing: AppTokens.spaceSm,
        runSpacing: AppTokens.spaceSm,
        children: data.genres
            .map((String genre) => Chip(label: Text(genre)))
            .toList(),
      ),
    );
  }

  Widget _buildAltTitles(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<MapEntry<String, String>> rows = <MapEntry<String, String>>[
      if (data.englishTitle != null)
        MapEntry("English", data.englishTitle!),
      if (data.japaneseTitle != null)
        MapEntry("Japanese", data.japaneseTitle!),
      if (data.synonyms.isNotEmpty)
        MapEntry("Synonyms", data.synonyms.join(", ")),
    ];
    return _Section(
      title: "Alternative Titles",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (MapEntry<String, String> row) => Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.spaceSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 80.0,
                      child: Text(
                        row.key,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(row.value, style: text.bodyMedium),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInformation(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return _Section(
      title: "Information",
      child: Card(
        child: Column(
          children: <Widget>[
            for (int i = 0; i < data.infoRows.length; i++) ...<Widget>[
              if (i > 0)
                Divider(height: 1.0, color: scheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spaceLg,
                  vertical: AppTokens.spaceMd,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        data.infoRows[i].key,
                        style: text.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        data.infoRows[i].value,
                        textAlign: TextAlign.right,
                        style: text.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({
    required this.uri,
    required this.fallback,
    this.width,
  });

  final Uri uri;
  final Uri fallback;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Image.network(
      uri.toString(),
      width: width,
      height: width == null ? null : width! * 1.5,
      fit: BoxFit.cover,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        if (fallback != uri && fallback.toString().isNotEmpty) {
          return Image.network(
            fallback.toString(),
            width: width,
            height: width == null ? null : width! * 1.5,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                ColoredBox(color: scheme.surfaceContainerHighest),
          );
        }
        return ColoredBox(color: scheme.surfaceContainerHighest);
      },
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? progress) {
        if (progress == null) return child;
        return ColoredBox(color: scheme.surfaceContainerHighest);
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceXs + 2.0,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTokens.spaceMd),
        child,
      ],
    );
  }
}

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
    return _EditableStatTile(
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

/// Wraps a stat in an outlined, tappable tile with a trailing chevron so it
/// reads as editable. When [onTap] is null the tile stays plain and borderless.
class _EditableStatTile extends StatelessWidget {
  const _EditableStatTile({required this.child, this.onTap});

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
    return _EditableStatTile(onTap: onTap, child: content);
  }
}

class _SynopsisSection extends StatefulWidget {
  const _SynopsisSection({required this.synopsis});

  final String synopsis;

  @override
  State<_SynopsisSection> createState() => _SynopsisSectionState();
}

class _SynopsisSectionState extends State<_SynopsisSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool collapsible = widget.synopsis.length > 220;
    return _Section(
      title: "Synopsis",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.synopsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            maxLines: !collapsible || _expanded ? null : 4,
            overflow:
                !collapsible || _expanded ? null : TextOverflow.ellipsis,
          ),
          if (collapsible)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? "Show less" : "Read more"),
              ),
            ),
        ],
      ),
    );
  }
}

/// The sticky bar shown while the details page has unsaved changes. It holds
/// only the discard/save controls; the quick edit actions live in the status
/// card so this bar can stay slim.
class _DetailsActionBar extends StatelessWidget {
  const _DetailsActionBar({
    required this.saving,
    required this.onSave,
    required this.onDiscard,
  });

  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.spaceSm,
            AppTokens.spaceSm,
            AppTokens.spaceSm,
            AppTokens.spaceSm,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: saving ? null : onDiscard,
                icon: const Icon(Icons.undo),
                tooltip: "Discard changes",
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          height: 16.0,
                          width: 16.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text("Save changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A themed loading scaffold shown while details are being fetched.
class MediaDetailsLoading extends StatelessWidget {
  const MediaDetailsLoading({
    super.key,
    required this.title,
    required this.poster,
  });

  final String title;
  final Uri poster;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// A themed error scaffold with a retry action.
class MediaDetailsError extends StatelessWidget {
  const MediaDetailsError({
    super.key,
    required this.title,
    required this.onRetry,
  });

  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text("Couldn't load details."),
            const SizedBox(height: AppTokens.spaceSm),
            FilledButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
