import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/show_details.dart';

class ListContainer extends StatefulWidget {
  /// An explicit list to display. When null, the controller's list for
  /// [listType] is shown instead.
  final List<Anime>? animeList;
  final AnimeListStatus? listType;

  const ListContainer({
    Key? key,
    this.listType,
    this.animeList,
  }) : super(key: key);

  @override
  _ListContainerState createState() => _ListContainerState();
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
    final Size size = MediaQuery.of(context).size;
    return ListenableBuilder(
      listenable: _controller!,
      builder: (BuildContext context, Widget? child) {
        final List<Anime> animeList = _animeList;
        return RefreshIndicator(
          onRefresh: _refreshList,
          child: SizedBox(
            width: size.width,
            child: ListView.builder(
              key: PageStorageKey(widget.listType?.apiValue ?? "search"),
              physics: const AlwaysScrollableScrollPhysics(),
              itemExtent: 106.0,
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                final Anime anime = animeList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 10.0),
                  child: SizedBox(
                    width: size.width,
                    child: Card(
                      color: Colors.grey[900],
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AnimeDetailsPage(anime: anime),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                bottomLeft: Radius.circular(5.0),
                              ),
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                height: 90,
                                width: 65,
                                placeholderCacheHeight: 90,
                                placeholderCacheWidth: 65,
                                placeholder: "assets/404img.png",
                                image: anime.picture.toString(),
                                imageErrorBuilder:
                                    (context, error, stackTrace) => SizedBox(
                                  height: 90,
                                  width: 65,
                                  child: Image.asset("assets/404img.png"),
                                ),
                              ),
                            ),
                            Expanded(
                              child: ShowDetails(
                                title: anime.title,
                                progress:
                                    "${anime.userEpisodesWatched}/${anime.totalEpisodes}",
                                score: "${anime.userScore}",
                                airingStatus: anime.showStatus?.label ?? "",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
