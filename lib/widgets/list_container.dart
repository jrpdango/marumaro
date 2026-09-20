import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/media_list_card.dart';

class ListContainer extends StatefulWidget {
  /// An explicit list to display. When null, the controller's list for
  /// [listType] is shown instead.
  final List<Anime>? animeList;
  final AnimeListStatus? listType;

  const ListContainer({
    super.key,
    this.listType,
    this.animeList,
  });

  @override
  State<ListContainer> createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  GlobalController? _controller;

  List<Anime> get _animeList {
    if (widget.animeList != null) return widget.animeList!;
    final AnimeListStatus? status = widget.listType;
    if (status == null) return const <Anime>[];
    return _controller!.lists[status] ?? const <Anime>[];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
  }

  Future<void> _refreshList() async {
    // Explicit lists (e.g. search results) are not backed by the controller.
    if (widget.animeList != null) return;
    await _controller!.loadAnimeList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller!,
      builder: (BuildContext context, Widget? child) {
        final List<Anime> animeList = _animeList;
        return RefreshIndicator(
          onRefresh: _refreshList,
          child: ListView.builder(
            key: PageStorageKey(widget.listType?.apiValue ?? "search"),
            physics: const AlwaysScrollableScrollPhysics(),
            itemExtent: 106.0,
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              final Anime anime = animeList[index];
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
          ),
        );
      },
    );
  }
}
