import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/library/library.dart';

/// Unified search over the user's cached anime and manga lists.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialKind = MediaKind.anime});

  final MediaKind initialKind;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  GlobalController? _controller;
  final TextEditingController _searchController = TextEditingController();

  late MediaKind _kind = widget.initialKind;
  String _query = "";
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = "");
  }

  @override
  Widget build(BuildContext context) {
    final GlobalController controller = _controller!;
    final bool isAnime = _kind == MediaKind.anime;
    return Scaffold(
      appBar: BackAppBar(),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.spaceLg,
              AppTokens.spaceLg,
              AppTokens.spaceLg,
              AppTokens.spaceSm,
            ),
            child: SegmentedButton<MediaKind>(
              segments: const <ButtonSegment<MediaKind>>[
                ButtonSegment<MediaKind>(
                  value: MediaKind.anime,
                  label: Text("Anime"),
                  icon: Icon(Icons.movie_outlined),
                ),
                ButtonSegment<MediaKind>(
                  value: MediaKind.manga,
                  label: Text("Manga"),
                  icon: Icon(Icons.menu_book_outlined),
                ),
              ],
              selected: <MediaKind>{_kind},
              showSelectedIcon: false,
              onSelectionChanged: (Set<MediaKind> selection) =>
                  setState(() => _kind = selection.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.spaceLg,
              0,
              AppTokens.spaceLg,
              AppTokens.spaceSm,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: isAnime
                    ? "Search your anime list..."
                    : "Search your manga list...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: "Clear",
                        onPressed: _clear,
                      ),
              ),
            ),
          ),
          Expanded(
            child: isAnime
                ? _buildAnimeResults(controller)
                : _buildMangaResults(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeResults(GlobalController controller) {
    return AnimeListContainer(
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
