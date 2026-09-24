import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/media_details/media_details.dart';
import 'package:miru/features/library/media_list_card.dart';

class AnimeListContainer extends StatelessWidget {
  /// An explicit paged source to display (e.g. search results). When null, the
  /// controller's cached list for [listType] is shown instead.
  final PagedSource<Anime>? source;
  final AnimeListStatus? listType;
  final Object? resetKey;
  final String pageStorageKey;
  final String? emptyMessage;

  const AnimeListContainer({
    super.key,
    this.source,
    this.listType,
    this.resetKey,
    this.pageStorageKey = "anime",
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalController controller = GlobalControllerScope.of(context);
    final bool fromStatus = source == null;
    final PagedSource<Anime> resolved = source ??
        DelegatePagedSource<Anime>(
          ({required int offset, required int limit}) => controller.pageAnime(
            listType!,
            offset: offset,
            limit: limit,
          ),
        );

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        return PagedListView<Anime>(
          source: resolved,
          pageStorageKey: listType?.apiValue ?? pageStorageKey,
          pageSize: 30,
          itemExtent: 120.0,
          resetKey: resetKey ?? (fromStatus ? controller.listSort : null),
          reloadListenable: fromStatus ? controller : null,
          onRefresh: fromStatus ? controller.syncAnime : null,
          emptyMessage: emptyMessage ??
              (fromStatus && controller.animeSyncing
                  ? "Syncing your anime list..."
                  : fromStatus && controller.animeSyncFailed
                      ? "Couldn't load your anime list. Pull down to retry."
                      : "Nothing here yet."),
          itemBuilder: (BuildContext context, Anime anime) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              child: MediaListCard(
                picture: anime.picture,
                title: anime.title,
                progressText: anime.totalEpisodes > 0
                    ? "${anime.userEpisodesWatched}/${anime.totalEpisodes}"
                    : "${anime.userEpisodesWatched}/-",
                progressValue: anime.totalEpisodes > 0
                    ? (anime.userEpisodesWatched / anime.totalEpisodes)
                        .clamp(0.0, 1.0)
                    : null,
                score: "${anime.userScore}",
                statusLabel: anime.userStatus.label,
                heroTag: "media-anime-${anime.id}",
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AnimeDetailsPage(anime: anime),
                  ),
                ),
                onLongPress: () => _quickEdit(context, controller, anime),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _quickEdit(
    BuildContext context,
    GlobalController controller,
    Anime anime,
  ) async {
    final String? action = await showQuickEditMenu(
      context,
      <QuickEditAction>[
        QuickEditAction(
          icon: Icons.bar_chart,
          label: "Change status",
          value: anime.userStatus.label,
          id: "status",
        ),
        QuickEditAction(
          icon: Icons.remove_red_eye_outlined,
          label: "Update progress",
          value: anime.totalEpisodes > 0
              ? "${anime.userEpisodesWatched}/${anime.totalEpisodes}"
              : "${anime.userEpisodesWatched}",
          id: "progress",
        ),
        QuickEditAction(
          icon: Icons.star_outline,
          label: "Set score",
          value: "${anime.userScore}",
          id: "score",
        ),
      ],
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case "status":
        await showStatusSheet(
          context,
          kind: MediaKind.anime,
          current: anime.userStatus.apiValue,
          onSelected: (String value) => applyUpdate(
            context,
            controller.updateAnime(
              anime: anime,
              status: AnimeListStatus.fromApiValue(value),
              score: anime.userScore,
              episodesWatched: anime.userEpisodesWatched,
            ),
          ),
        );
      case "progress":
        await showProgressSheet(
          context,
          label: "Episodes Watched",
          total: anime.totalEpisodes,
          initial: anime.userEpisodesWatched,
          onChanged: (int value) => applyUpdate(
            context,
            controller.updateAnime(
              anime: anime,
              status: anime.userStatus,
              score: anime.userScore,
              episodesWatched: value,
            ),
          ),
        );
      case "score":
        await showScoreSheet(
          context,
          initial: anime.userScore,
          onChanged: (int value) => applyUpdate(
            context,
            controller.updateAnime(
              anime: anime,
              status: anime.userStatus,
              score: value,
              episodesWatched: anime.userEpisodesWatched,
            ),
          ),
        );
    }
  }
}
