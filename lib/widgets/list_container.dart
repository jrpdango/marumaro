import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miru/constants.dart' as constants show limitOfListItems;
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/season.dart';
import 'package:miru/objectbox.g.dart';
import 'package:miru/pages/anime_details.dart';
import 'package:miru/widgets/content_card.dart';
import 'package:miru/widgets/content_card_details.dart';
import 'package:get/get.dart';

class ListContainer extends StatefulWidget {
  final AnimeListType animeListType;

  const ListContainer({
    Key? key,
    required this.animeListType,
  }) : super(key: key);

  @override
  State<ListContainer> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ListContainer> {
  List<Anime>? _animeList = [];
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _animeList = Globals.client.userAnimeList[widget.animeListType] ?? [];
    print(Globals.client.userAnimeList[widget.animeListType]);
    if (_animeList!.isEmpty) {
      Query<Anime>? query = Globals.store
          ?.box<Anime>()
          .query(Anime_.dbUserCurrentStatus.equals(widget.animeListType.index))
          .build();
      query
        ?..limit = 100
        ..offset = _currentOffset;
      _currentOffset += 100;
      _animeList?.addAll(query?.find() ?? []);
    } else {
      _currentOffset += _animeList?.length ?? 0;
    }
  }

  /// Retrieve latest user's list to refresh and assign it to the client.
  ///
  void _refresh() async {
    _animeList = (await Globals.client.requestAnimeList(
          limit: constants.limitOfListItems,
        ))[widget.animeListType] ??
        [];
    // Only call setState() if the widget is mounted
    if (mounted) setState(() {});
  }

  void _loadMoreItems() {
    Query<Anime>? query = Globals.store
        ?.box<Anime>()
        .query(Anime_.dbUserCurrentStatus.equals(widget.animeListType.index))
        .build();
    query
      ?..limit = 100
      ..offset = _currentOffset;
    _currentOffset += 100;
    _animeList?.addAll(query?.find() ?? []);
    setState(() {});
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter == 0) {
      _loadMoreItems();
      debugPrint('Scroll ended');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: ListView.builder(
          key: PageStorageKey(widget.animeListType),
          itemExtent: 130.0,
          itemCount: _animeList?.length ?? 0,
          itemBuilder: (context, index) {
            if (_animeList?.isEmpty ?? true) return Container();
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              child: ContentCard(
                onTap: () => Get.to(
                  () {
                    if (_animeList == null) return Container();
                    Anime anime = _animeList![index];
                    return AnimeDetails(
                      anime: anime,
                      // TODO: Remove passing index
                      index: index,
                      onUpdate: () {
                        // Query the DB for every other Anime with this ListContainer's type
                        Box<Anime>? animeBox = Globals.store?.box<Anime>();
                        Query<Anime>? contentQuery = animeBox
                            ?.query(Anime_.dbUserCurrentStatus
                                .equals(widget.animeListType.index)
                                .and(Anime_.animeId.notEquals(anime.animeId)))
                            .build();
                        List<Anime>? dbAnime = contentQuery?.find();
                        contentQuery?.close();
                        setState(
                          () {
                            // If the Anime is in the current ListContainer, add it on top
                            if (anime.userCurrentStatus ==
                                widget.animeListType) {
                              _animeList = [anime, ...dbAnime ?? []];
                              // If the Anime transferred elsewhere, just show the others
                            } else {
                              _animeList = dbAnime ?? [];
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                imageUrl: _animeList?[index].pictureMedium.toString() ?? '',
                contentCardDetails: ContentCardDetails(
                  title: _animeList?[index].title ?? '',
                  episodesWatched:
                      _animeList?[index].userListStatus.currentProgress ?? 0,
                  totalEpisodes: _animeList?[index].totalEpisodes ?? 0,
                  score: _animeList?[index].userListStatus.score ?? 0,
                  season: _animeList?[index].season ?? Season(),
                ),
              ),
            );
          },
        ),
      ),
      onRefresh: () async => _refresh(),
    );
  }
}
