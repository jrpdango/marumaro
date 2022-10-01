import 'package:flutter/material.dart';
import 'package:miru/constants.dart' as constants show limitOfListItems;
import 'package:miru/enums/anime_list_status.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/anime.dart';
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
  List<Anime>? _animeList;

  @override
  void initState() {
    super.initState();
    switch (widget.animeListType) {
      case AnimeListType.watching:
        _animeList = Globals.client.animeMap['watching'];
        break;
      case AnimeListType.planToWatch:
        _animeList = Globals.client.animeMap['plan_to_watch'];
        break;
      case AnimeListType.completed:
        _animeList = Globals.client.animeMap['completed'];
        break;
      case AnimeListType.onHold:
        _animeList = Globals.client.animeMap['on_hold'];
        break;
      case AnimeListType.dropped:
        _animeList = Globals.client.animeMap['dropped'];
        break;
    }
  }

  /// Retrieve latest user's list to refresh and assign it to the client.
  ///
  void _refresh() async {
    Globals.client.animeMap = (await Globals.client.requestAnimeList(
      limit: constants.limitOfListItems,
    ))
        .obs;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
        key: PageStorageKey(widget.animeListType),
        itemExtent: 106.0,
        itemCount: _animeList?.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            child: ContentCard(
              onTap: () => Get.to(() => const AnimeDetails()),
              imageUrl: _animeList?[index].picture.toString() ?? '',
              contentCardDetails: ContentCardDetails(
                title: _animeList?[index].title ?? '',
                episodesWatched: _animeList?[index].userEpisodesWatched ?? 0,
                totalEpisodes: _animeList?[index].totalEpisodes ?? 0,
                score: _animeList?[index].userScore ?? 0,
                airingStatus: _animeList?[index].showStatus.toString() ?? '',
              ),
            ),
          );
        },
      ),
      onRefresh: () async => _refresh(),
    );
  }
}
