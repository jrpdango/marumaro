import 'package:flutter/material.dart';
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
  GlobalController? _controller;
  String _query = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
  }

  List<Anime> _results() {
    final List<Anime> all = _controller!.globalAnimeList;
    if (_query.isEmpty) return all;
    final String query = _query.toLowerCase();
    return all
        .where((Anime anime) => anime.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(240, 0, 0, 0),
      appBar: BackAppBar(),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
            child: TextField(
              onChanged: (query) {
                setState(() => _query = query);
              },
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: "Search your anime list...",
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.blueGrey,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListContainer(
              listType: "",
              animeList: _results(),
            ),
          ),
        ],
      ),
    );
  }
}
