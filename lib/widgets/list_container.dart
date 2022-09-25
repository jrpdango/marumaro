import 'package:flutter/material.dart';
import 'package:miru/enums/anime_list_status.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/widgets/content_card.dart';

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
        _animeList = Globals.client.animeMap['planToWatch'];
        break;
      case AnimeListType.completed:
        _animeList = Globals.client.animeMap['completed'];
        break;
      case AnimeListType.onHold:
        _animeList = Globals.client.animeMap['onHold'];
        break;
      case AnimeListType.dropped:
        _animeList = Globals.client.animeMap['dropped'];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView.builder(
          itemCount: _animeList?.length,
          itemBuilder: ((context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              child: ContentCard(
                imageUrl: _animeList?[index].picture.toString() ?? '',
              ),
            );
          }),
        ),
        onRefresh: () async {
          return await null;
        });
  }
}
