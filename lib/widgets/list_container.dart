import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/media_list_card.dart';
import 'package:miru/widgets/paged_list.dart';

class ListContainer extends StatelessWidget {
  /// An explicit paged source to display (e.g. search results). When null, the
  /// controller's cached list for [listType] is shown instead.
  final PagedSource<Anime>? source;
  final AnimeListStatus? listType;
  final Object? resetKey;
  final String pageStorageKey;
  final String? emptyMessage;

  const ListContainer({
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
          itemExtent: 106.0,
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
                progress: "${anime.userEpisodesWatched}/${anime.totalEpisodes}",
                score: "${anime.userScore}",
                statusLabel: anime.showStatus?.label ?? "",
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AnimeDetailsPage(anime: anime),
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
