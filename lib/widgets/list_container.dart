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
                () => AnimeDetails(
                    anime: _animeList[index],
                    index: index,
                    onUpdate: () {
                      setState(() {
                        _animeList = Globals.store
                                ?.box<Anime>()
                                .query(Anime_.dbUserCurrentStatus
                                    .equals(widget.animeListType.index))
                                .build()
                                .find() ??
                            [];
                      });
                    }),
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
