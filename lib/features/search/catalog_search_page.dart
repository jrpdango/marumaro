import 'dart:async';

import 'package:flutter/material.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/browse/widgets/browse_list_tile.dart';
import 'package:marumaro/features/media_details/media_details.dart';

/// Searches the full MyAnimeList catalog so titles that are not in the user's
/// cached list can be opened and added from the details page.
class CatalogSearchPage extends StatefulWidget {
  const CatalogSearchPage({super.key, this.initialKind = MediaKind.anime});

  final MediaKind initialKind;

  @override
  State<CatalogSearchPage> createState() => _CatalogSearchPageState();
}

class _CatalogSearchPageState extends State<CatalogSearchPage> {
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  GlobalController? _controller;
  final TextEditingController _searchController = TextEditingController();

  late MediaKind _kind = widget.initialKind;
  String _query = "";
  Timer? _debounce;

  Map<int, Anime> _animeById = const <int, Anime>{};
  Map<int, Manga> _mangaById = const <int, Manga>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = GlobalControllerScope.of(context);
      _loadMembership();
    }
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
    _debounce = Timer(_debounceDelay, () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clear() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = "");
  }

  /// Loads the user's cached list entries so results can show their status and
  /// details can open with the known list state.
  Future<void> _loadMembership() async {
    final GlobalController? controller = _controller;
    if (controller == null) return;
    try {
      final List<Map<int, Object>> entries = await Future.wait(
        <Future<Map<int, Object>>>[
          controller.animeById(),
          controller.mangaById(),
        ],
      );
      if (!mounted) return;
      setState(() {
        _animeById = entries[0].cast<int, Anime>();
        _mangaById = entries[1].cast<int, Manga>();
      });
    } catch (_) {}
  }

  Anime _seedAnime(Anime anime) {
    final Anime? cached = _animeById[anime.id];
    if (cached == null) return anime;
    return anime.copyWith(
      inList: true,
      userStatus: cached.userStatus,
      userScore: cached.userScore,
      userEpisodesWatched: cached.userEpisodesWatched,
      isNsfw: cached.isNsfw,
    );
  }

  Manga _seedManga(Manga manga) {
    final Manga? cached = _mangaById[manga.id];
    if (cached == null) return manga;
    return manga.copyWith(
      inList: true,
      userStatus: cached.userStatus,
      userScore: cached.userScore,
      userChaptersRead: cached.userChaptersRead,
      userVolumesRead: cached.userVolumesRead,
      isNsfw: cached.isNsfw,
    );
  }

  Future<void> _openAnime(Anime anime) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeDetailsPage(anime: _seedAnime(anime)),
      ),
    );
    if (mounted) await _loadMembership();
  }

  Future<void> _openManga(Manga manga) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MangaDetailsPage(manga: _seedManga(manga)),
      ),
    );
    if (mounted) await _loadMembership();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalController controller = _controller!;
    final bool isAnime = _kind == MediaKind.anime;
    return Scaffold(
      appBar: BackAppBar(title: "Search"),
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
                    ? "Search anime on MyAnimeList..."
                    : "Search manga on MyAnimeList...",
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
            child: _query.isEmpty
                ? const _SearchHint()
                : isAnime
                    ? _buildAnimeResults(controller)
                    : _buildMangaResults(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimeResults(GlobalController controller) {
    return PagedListView<Anime>(
      source: DelegatePagedSource<Anime>(
        ({required int offset, required int limit}) => controller
            .searchAnimeCatalog(query: _query, offset: offset, limit: limit)
            .then((PageResult<Anime> page) => page.items),
      ),
      pageStorageKey: "catalog_anime_${_query}_${controller.showNsfw}",
      pageSize: 30,
      resetKey: "$_query|${controller.showNsfw}",
      emptyMessage: "No matches.",
      itemBuilder: (BuildContext context, Anime anime) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: BrowseListTile(
            picture: anime.picture,
            title: anime.title,
            score: anime.meanScore,
            members: anime.members,
            mediaType: anime.mediaType,
            statusLabel: _animeById[anime.id]?.userStatus.label,
            onTap: () => _openAnime(anime),
          ),
        );
      },
    );
  }

  Widget _buildMangaResults(GlobalController controller) {
    return PagedListView<Manga>(
      source: DelegatePagedSource<Manga>(
        ({required int offset, required int limit}) => controller
            .searchMangaCatalog(query: _query, offset: offset, limit: limit)
            .then((PageResult<Manga> page) => page.items),
      ),
      pageStorageKey: "catalog_manga_${_query}_${controller.showNsfw}",
      pageSize: 30,
      resetKey: "$_query|${controller.showNsfw}",
      emptyMessage: "No matches.",
      itemBuilder: (BuildContext context, Manga manga) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: BrowseListTile(
            picture: manga.picture,
            title: manga.title,
            score: manga.meanScore,
            mediaType: manga.mediaType,
            statusLabel: _mangaById[manga.id]?.userStatus.label,
            onTap: () => _openManga(manga),
          ),
        );
      },
    );
  }
}

/// The placeholder shown before the user enters a query.
class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.travel_explore,
              size: 48.0,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppTokens.spaceMd),
            Text(
              "Search anime and manga on MyAnimeList to add them to your "
              "list.",
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
