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
  List<Anime> _animeList = [];

  @override
  void initState() {
    super.initState();
    // _animeList = Globals.client.animeMap[widget.animeListType];
    _animeList = Globals.store
            ?.box<Anime>()
            .query(
                Anime_.dbUserCurrentStatus.equals(widget.animeListType.index))
            .build()
            .find() ??
        [];
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        key: PageStorageKey(widget.animeListType),
        itemExtent: 130.0,
        itemCount: _animeList.length,
        itemBuilder: (context, index) {
          if (_animeList.isEmpty) return Container();
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            child: ContentCard(
              onTap: () => Get.to(
                () {
                  int animeId = _animeList[index].animeId;
                  int currentIndex = index;
                  return AnimeDetails(
                    anime: _animeList[index],
                    index: index,
                    onUpdate: (AnimeListType userLastStatus) {
                      setState(
                        () {
                          Anime? queriedAnime = Globals.store
                              ?.box<Anime>()
                              .query(Anime_.animeId.equals(animeId))
                              .build()
                              .findFirst();
                          if (queriedAnime == null ||
                              queriedAnime.userCurrentStatus == null) return;
                          // If going to this ListContainer from another, insert at index 0.
                          // - First check if where the Anime last came from isn't where it's going
                          // - Then check if where it's going is this ListContainer
                          // - Insert it at the top of the ListContainer, then set currentIndex to 0 in case user modifies it again
                          if ((userLastStatus !=
                                  queriedAnime.userCurrentStatus) &&
                              (queriedAnime.userCurrentStatus ==
                                  widget.animeListType)) {
                            _animeList.insert(0, queriedAnime);
                            currentIndex = 0;
                          }
                          // If leaving this ListContainer, remove it.
                          // - First we check if the Anime is coming from this ListContainer
                          // - Then if it's going somewhere that isn't here, remove it
                          // - Otherwise, just update the Anime where it is
                          else if (userLastStatus == widget.animeListType) {
                            if (queriedAnime.userCurrentStatus !=
                                widget.animeListType) {
                              _animeList.removeAt(currentIndex);
                            } else {
                              _animeList[currentIndex] = queriedAnime;
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
              imageUrl: _animeList[index].pictureMedium.toString(),
              contentCardDetails: ContentCardDetails(
                title: _animeList[index].title,
                episodesWatched:
                    _animeList[index].userListStatus.currentProgress ?? 0,
                totalEpisodes: _animeList[index].totalEpisodes,
                score: _animeList[index].userListStatus.score ?? 0,
                season: _animeList[index].season ?? Season(),
              ),
            ),
          );
        },
      ),
      onRefresh: () async => _refresh(),
    );
  }
}
