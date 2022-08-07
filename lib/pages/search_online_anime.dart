import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/services/anime_search_request.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/back_appbar.dart';
import 'package:miru/widgets/list_container.dart';

class SearchOnlineAnime extends StatefulWidget {
  const SearchOnlineAnime({Key? key}) : super(key: key);

  @override
  _SearchLocalState createState() => _SearchLocalState();
}

class _SearchLocalState extends State<SearchOnlineAnime> {
  GlobalController _globalController = Get.find<GlobalController>();
  final TextEditingController _textController = TextEditingController();
  RxList<Anime> results = <Anime>[].obs;

  @override
  void dispose() {
    // _globalController already disposes itself, so just dispose the other controller
    _textController.dispose();
    super.dispose();
  }

  void search(String query) async {
    results.clear();
    if (query == "") {
      // results.addAll(_globalController.globalAnimeList);
      return;
    }

    Map response = await _globalController.client.value
        .animeSearch(AnimeSearchRequest(query: query));
    for (Map anime in response['data']) {
      results.add(
        Anime(
            id: anime['node']['id'],
            title: anime['node']['title'],
            picture: Uri.parse(anime['node']['main_picture']?['medium'] ?? ""),
            totalEpisodes: anime['node']['num_episodes'],
            showStatus: anime['node']['status'],
            userStatus: anime['node']['my_list_status']?['status'] ?? null,
            userEpisodesWatched: anime['node']['my_list_status']
                    ?['num_episodes_watched'] ??
                null,
            userScore: anime['node']['my_list_status']?['score'] ?? null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(240, 0, 0, 0),
      appBar: BackAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => search(_textController.text),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: Colors.white70,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                hintText: "Search your anime list...",
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
                fillColor: Colors.blueGrey,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListContainer(
              listType: "",
              animeList: results,
            ),
          ),
        ],
      ),
    );
  }
}
