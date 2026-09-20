import 'package:flutter/material.dart';
import 'package:miru/constants.dart' as Constants show limitOfListItems;
import 'package:miru/models/anime.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/pages/anime_details_page.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/show_details.dart';

class ListContainer extends StatefulWidget {
  /// An explicit list to display. When null, the controller's list for
  /// [listType] is shown instead.
  final List<Anime>? animeList;
  final String listType;

  const ListContainer({
    Key? key,
    required this.listType,
    this.animeList,
  }) : super(key: key);

  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  GlobalController? _controller;
  MALClient? _client;

  List<Anime> get _animeList =>
      widget.animeList ?? _controller!.lists[widget.listType] ?? const <Anime>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    _client ??= _controller!.client;
  }

  Future<void> _refreshList(int limit) async {
    // Explicit lists (e.g. search results) are not backed by the controller.
    if (widget.animeList != null) return;

    Map<String, dynamic> result =
        await _client!.getAnimeList(AnimeListRequest(limit: limit));
    Map<String, dynamic> newMap = Map();
    while (result["paging"]["next"] != null) {
      newMap = await _client!.getAnimeList(
        AnimeListRequest(
          limit: limit,
          url: Uri.parse(result["paging"]["next"]),
        ),
      );
      for (String item in newMap.keys) {
        if (item != "paging" && item != "status_code") {
          result[item].addAll(newMap[item]);
        }
      }
      result["paging"]["next"] = newMap["paging"]["next"];
    }
    _controller!.setAnimeList(result);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ListenableBuilder(
      listenable: _controller!,
      builder: (BuildContext context, Widget? child) {
        final List<Anime> animeList = _animeList;
        return RefreshIndicator(
          onRefresh: () async {
            await _refreshList(Constants.limitOfListItems);
          },
          child: SizedBox(
            width: size.width,
            child: ListView.builder(
              key: PageStorageKey(widget.listType),
              physics: const AlwaysScrollableScrollPhysics(),
              itemExtent: 106.0,
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                final Anime anime = animeList[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
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
                                airingStatus: anime.showStatus,
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
