import 'package:flutter/material.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/pages/manga_details_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/media_list_card.dart';
import 'package:miru/widgets/paged_list.dart';

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
          itemExtent: 106.0,
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
                progress: "${manga.userChaptersRead}/${manga.totalChapters}"
                    "  Vol ${manga.userVolumesRead}/${manga.totalVolumes}",
                score: "${manga.userScore}",
                statusLabel: manga.publishingStatus?.label ?? "",
                statusPrefix: "Publishing Status",
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MangaDetailsPage(manga: manga),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
