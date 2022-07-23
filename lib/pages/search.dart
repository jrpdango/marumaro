import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/back_appbar.dart';
import 'package:miru/widgets/list_container.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  GlobalController _controller = Get.find<GlobalController>();
  RxList<Anime> results = <Anime>[].obs;

  void search(String query) {
    results.clear();
    if (query == "") {
      results.addAll(_controller.globalAnimeList);
      return;
    }

    _controller.globalAnimeList.forEach(
      (element) {
        if (element.title.toLowerCase().contains(query)) {
          results.add(element);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    results.addAll(_controller.globalAnimeList);

    return Scaffold(
      backgroundColor: Color.fromARGB(240, 0, 0, 0),
      appBar: BackAppBar(),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
            child: TextField(
              textInputAction: TextInputAction.search,
              onChanged: (q) {
                search(q);
              },
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
