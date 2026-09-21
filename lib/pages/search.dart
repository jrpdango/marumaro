import 'package:flutter/material.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/back_appbar.dart';
import 'package:miru/widgets/list_container.dart';
import 'package:miru/widgets/manga_list_container.dart';
import 'package:miru/widgets/paged_list.dart';

class Search extends StatefulWidget {
  final bool manga;

  const Search({super.key, this.manga = false});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  GlobalController? _controller;
  String _query = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalController controller = _controller!;
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
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                hintText: widget.manga
                    ? "Search your manga list..."
                    : "Search your anime list...",
                hintStyle: const TextStyle(color: Colors.white),
                fillColor: Colors.blueGrey,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: widget.manga
                ? _buildMangaResults(controller)
                : _buildAnimeResults(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeResults(GlobalController controller) {
    return ListContainer(
      pageStorageKey: "search_anime",
      resetKey: _query,
      source: DelegatePagedSource<Anime>(
        ({required int offset, required int limit}) =>
            controller.searchAnime(_query, offset: offset, limit: limit),
      ),
      emptyMessage: controller.animeSyncing
          ? "Syncing your anime list..."
          : "No matches.",
    );
  }

  Widget _buildMangaResults(GlobalController controller) {
    return MangaListContainer(
      pageStorageKey: "search_manga",
      resetKey: _query,
      source: DelegatePagedSource<Manga>(
        ({required int offset, required int limit}) =>
            controller.searchManga(_query, offset: offset, limit: limit),
      ),
      emptyMessage: controller.mangaSyncing
          ? "Syncing your manga list..."
          : "No matches.",
    );
  }
}
