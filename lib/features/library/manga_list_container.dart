import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/media_details/media_details.dart';
import 'package:miru/features/library/media_list_card.dart';

class MangaListContainer extends StatelessWidget {
  /// An explicit paged source to display (e.g. search results). When null, the
  /// controller's cached list for [mangaType] is shown instead.
  final PagedSource<Manga>? source;
  final MangaListStatus? mangaType;
  final Object? resetKey;
  final String pageStorageKey;
  final String? emptyMessage;

  const MangaListContainer({
    super.key,
    this.source,
    this.mangaType,
    this.resetKey,
    this.pageStorageKey = "manga",
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalController controller = GlobalControllerScope.of(context);
    final bool fromStatus = source == null;
    final PagedSource<Manga> resolved = source ??
        DelegatePagedSource<Manga>(
          ({required int offset, required int limit}) => controller.pageManga(
            mangaType!,
            offset: offset,
            limit: limit,
          ),
        );

    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        return PagedListView<Manga>(
          source: resolved,
          pageStorageKey: mangaType?.apiValue ?? pageStorageKey,
          pageSize: 30,
          itemExtent: 120.0,
          resetKey: resetKey ?? (fromStatus ? controller.listSort : null),
          reloadListenable: fromStatus ? controller : null,
          onRefresh: fromStatus ? controller.syncManga : null,
          emptyMessage: emptyMessage ??
              (fromStatus && controller.mangaSyncing
                  ? "Syncing your manga list..."
                  : fromStatus && controller.mangaSyncFailed
                      ? "Couldn't load your manga list. Pull down to retry."
                      : "Nothing here yet."),
          itemBuilder: (BuildContext context, Manga manga) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              child: MediaListCard(
                picture: manga.picture,
                title: manga.title,
                progressText: manga.totalChapters > 0
                    ? "${manga.userChaptersRead}/${manga.totalChapters}"
                    : "${manga.userChaptersRead}/-",
                progressValue: manga.totalChapters > 0
                    ? (manga.userChaptersRead / manga.totalChapters)
                        .clamp(0.0, 1.0)
                    : null,
                volumeText: manga.totalVolumes > 0
                    ? "Vol ${manga.userVolumesRead}/${manga.totalVolumes}"
                    : "Vol ${manga.userVolumesRead}/-",
                score: "${manga.userScore}",
                statusLabel: manga.userStatus.label,
                heroTag: "media-manga-${manga.id}",
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MangaDetailsPage(manga: manga),
                  ),
                ),
                onLongPress: () => _quickEdit(context, controller, manga),
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
    Manga manga,
  ) async {
    final String? action = await showQuickEditMenu(
      context,
      <QuickEditAction>[
        QuickEditAction(
          icon: Icons.bar_chart,
          label: "Change status",
          value: manga.userStatus.label,
          id: "status",
        ),
        QuickEditAction(
          icon: Icons.menu_book_outlined,
          label: "Update chapters",
          value: manga.totalChapters > 0
              ? "${manga.userChaptersRead}/${manga.totalChapters}"
              : "${manga.userChaptersRead}",
          id: "chapters",
        ),
        QuickEditAction(
          icon: Icons.library_books_outlined,
          label: "Update volumes",
          value: manga.totalVolumes > 0
              ? "${manga.userVolumesRead}/${manga.totalVolumes}"
              : "${manga.userVolumesRead}",
          id: "volumes",
        ),
        QuickEditAction(
          icon: Icons.star_outline,
          label: "Set score",
          value: "${manga.userScore}",
          id: "score",
        ),
      ],
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case "status":
        await showStatusSheet(
          context,
          kind: MediaKind.manga,
          current: manga.userStatus.apiValue,
          onSelected: (String value) => applyUpdate(
            context,
            controller.updateManga(
              manga: manga,
              status: MangaListStatus.fromApiValue(value),
              score: manga.userScore,
              chaptersRead: manga.userChaptersRead,
              volumesRead: manga.userVolumesRead,
            ),
          ),
        );
      case "chapters":
        await showProgressSheet(
          context,
          label: "Chapters Read",
          total: manga.totalChapters,
          initial: manga.userChaptersRead,
          onChanged: (int value) => applyUpdate(
            context,
            controller.updateManga(
              manga: manga,
              status: manga.userStatus,
              score: manga.userScore,
              chaptersRead: value,
              volumesRead: manga.userVolumesRead,
            ),
          ),
        );
      case "volumes":
        await showProgressSheet(
          context,
          label: "Volumes Read",
          total: manga.totalVolumes,
          initial: manga.userVolumesRead,
          onChanged: (int value) => applyUpdate(
            context,
            controller.updateManga(
              manga: manga,
              status: manga.userStatus,
              score: manga.userScore,
              chaptersRead: manga.userChaptersRead,
              volumesRead: value,
            ),
          ),
        );
      case "score":
        await showScoreSheet(
          context,
          initial: manga.userScore,
          onChanged: (int value) => applyUpdate(
            context,
            controller.updateManga(
              manga: manga,
              status: manga.userStatus,
              score: value,
              chaptersRead: manga.userChaptersRead,
              volumesRead: manga.userVolumesRead,
            ),
          ),
        );
    }
  }
}
