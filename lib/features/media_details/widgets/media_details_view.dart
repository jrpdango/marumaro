import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';

part 'content_sections.dart';
part 'details_action_bar.dart';
part 'details_header.dart';
part 'poster_row.dart';
part 'stat_tiles.dart';
part 'status_card.dart';
part 'synopsis_section.dart';

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
    this.inList = true,
    this.saving = false,
  });

  final MediaDetailsData data;

  /// Whether the media is on the user's list. When false, the status card
  /// prompts to add it and the remove action is hidden.
  final bool inList;
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

  bool get _hasAltTitles =>
      data.englishTitle != null ||
      data.japaneseTitle != null ||
      data.synonyms.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _DetailsHeader(
            data: data,
            inList: inList,
            onEditTap: onEditTap,
            onRemove: onRemove,
          ),
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
                  _PosterRow(data: data),
                  const SizedBox(height: AppTokens.spaceLg),
                  _StatusCard(
                    inList: inList,
                    statusLabel: statusLabel,
                    score: score,
                    progress: progress,
                    progressTotal: progressTotal,
                    progressLabel: progressLabel,
                    onStatusTap: onStatusTap,
                    onScoreTap: onScoreTap,
                    onProgressTap: onProgressTap,
                    onProgressDelta: onProgressDelta,
                  ),
                  if (data.synopsis != null) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _SynopsisSection(synopsis: data.synopsis!),
                  ],
                  if (data.genres.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _GenresSection(genres: data.genres),
                  ],
                  if (_hasAltTitles) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _AltTitlesSection(data: data),
                  ],
                  if (data.infoRows.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppTokens.spaceLg),
                    _InformationSection(rows: data.infoRows),
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
}
