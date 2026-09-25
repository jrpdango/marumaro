import 'package:flutter/material.dart';
import 'package:tamarun/core/core.dart';
import 'package:tamarun/features/browse/browse_list_page.dart';
import 'package:tamarun/features/browse/widgets/browse_list_tile.dart';
import 'package:tamarun/features/browse/widgets/browse_section.dart';
import 'package:tamarun/features/browse/widgets/media_poster_card.dart';
import 'package:tamarun/features/media_details/media_details.dart';

/// Discovery page: this season's anime, suggestions, and top rankings, each as
/// a horizontal carousel that links to a full paged list.
class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  static const int _previewLimit = 12;
  static const int _oldestSeasonYear = 1990;

  GlobalController? _controller;

  final SeasonRef _currentSeason = SeasonRef.current();
  late final List<SeasonRef> _seasonOptions = _buildSeasonOptions(
    _currentSeason,
  );

  Future<List<Anime>>? _season;
  Future<List<Anime>>? _forYou;
  Future<List<Anime>>? _airing;
  Future<List<Anime>>? _upcoming;
  Future<List<Manga>>? _topManga;
  Future<List<Manga>>? _topNovels;

  Map<int, Anime> _animeById = const <int, Anime>{};
  Map<int, Manga> _mangaById = const <int, Manga>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    if (_season == null) {
      _assignFutures();
      _loadMembership();
    }
  }

  MalRepository get _repository => _controller!.repository;

  void _assignFutures() {
    _season = _repository
        .fetchSeasonalAnime(
          season: _currentSeason,
          sort: AnimeSeasonSort.score,
          offset: 0,
          limit: _previewLimit,
        )
        .then((PageResult<Anime> page) => page.items);
    _forYou = _repository
        .fetchSuggestedAnime(offset: 0, limit: _previewLimit)
        .then((PageResult<Anime> page) => page.items);
    _airing = _repository
        .fetchAnimeRanking(
          type: AnimeRankingType.airing,
          offset: 0,
          limit: _previewLimit,
        )
        .then((PageResult<Anime> page) => page.items);
    _upcoming = _repository
        .fetchAnimeRanking(
          type: AnimeRankingType.upcoming,
          offset: 0,
          limit: _previewLimit,
        )
        .then((PageResult<Anime> page) => page.items);
    _topManga = _repository
        .fetchMangaRanking(
          type: MangaRankingType.manga,
          offset: 0,
          limit: _previewLimit,
        )
        .then((PageResult<Manga> page) => page.items);
    _topNovels = _repository
        .fetchMangaRanking(
          type: MangaRankingType.novels,
          offset: 0,
          limit: _previewLimit,
        )
        .then((PageResult<Manga> page) => page.items);
  }

  Future<void> _refresh() async {
    setState(_assignFutures);
    await Future.wait(
      <Future<void>>[
        _season!,
        _forYou!,
        _airing!,
        _upcoming!,
        _topManga!,
        _topNovels!,
      ].map((Future<Object?> future) => future.then((_) {}).catchError((_) {})),
    );
    await _loadMembership();
  }

  /// Loads the user's cached list entries so browse cards can show their list
  /// status and details can open with the known stats.
  Future<void> _loadMembership() async {
    final GlobalController controller = _controller!;
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

  /// Merges the cached list entry (status, score, progress) into a browse node
  /// so the details page opens with the correct state.
  Anime _seedAnime(Anime anime) {
    final Anime? cached = _animeById[anime.id];
    if (cached == null) return anime;
    return anime.copyWith(
      inList: true,
      userStatus: cached.userStatus,
      userScore: cached.userScore,
      userEpisodesWatched: cached.userEpisodesWatched,
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
    );
  }

  Future<void> _openAnime(Anime anime) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeDetailsPage(anime: _seedAnime(anime)),
      ),
    );
    if (mounted) _loadMembership();
  }

  Future<void> _openManga(Manga manga) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MangaDetailsPage(manga: _seedManga(manga)),
      ),
    );
    if (mounted) _loadMembership();
  }

  Future<void> _openSeasonal() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseListPage<Anime>(
          title: "Seasonal Anime",
          selectors: <BrowseSelector>[
            BrowseSelector(
              label: "Season",
              options: _seasonOptions,
              value: _currentSeason,
              optionLabel: (Object option) => (option as SeasonRef).label,
            ),
            BrowseSelector(
              label: "Sort",
              options: AnimeSeasonSort.values,
              value: AnimeSeasonSort.score,
              optionLabel: (Object option) => (option as AnimeSeasonSort).label,
            ),
          ],
          loader:
              (
                List<Object> selected, {
                required int offset,
                required int limit,
              }) => _repository
                  .fetchSeasonalAnime(
                    season: selected[0] as SeasonRef,
                    sort: selected[1] as AnimeSeasonSort,
                    offset: offset,
                    limit: limit,
                  )
                  .then((PageResult<Anime> page) => page.items),
          itemBuilder: _buildAnimeTile,
        ),
      ),
    );
    if (mounted) _loadMembership();
  }

  Future<void> _openSuggestions() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseListPage<Anime>(
          title: "For You",
          selectors: const <BrowseSelector>[],
          loader:
              (
                List<Object> selected, {
                required int offset,
                required int limit,
              }) => _repository
                  .fetchSuggestedAnime(offset: offset, limit: limit)
                  .then((PageResult<Anime> page) => page.items),
          itemBuilder: _buildAnimeTile,
          emptyMessage: "No suggestions yet.",
        ),
      ),
    );
    if (mounted) _loadMembership();
  }

  Future<void> _openAnimeRanking(AnimeRankingType initial) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseListPage<Anime>(
          title: initial.label,
          selectors: <BrowseSelector>[
            BrowseSelector(
              label: "Ranking",
              options: AnimeRankingType.values,
              value: initial,
              optionLabel: (Object option) =>
                  (option as AnimeRankingType).label,
            ),
          ],
          loader:
              (
                List<Object> selected, {
                required int offset,
                required int limit,
              }) => _repository
                  .fetchAnimeRanking(
                    type: selected[0] as AnimeRankingType,
                    offset: offset,
                    limit: limit,
                  )
                  .then((PageResult<Anime> page) => page.items),
          itemBuilder: _buildAnimeTile,
        ),
      ),
    );
    if (mounted) _loadMembership();
  }

  Future<void> _openMangaRanking(MangaRankingType initial) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseListPage<Manga>(
          title: initial.label,
          selectors: <BrowseSelector>[
            BrowseSelector(
              label: "Ranking",
              options: MangaRankingType.values,
              value: initial,
              optionLabel: (Object option) =>
                  (option as MangaRankingType).label,
            ),
          ],
          loader:
              (
                List<Object> selected, {
                required int offset,
                required int limit,
              }) => _repository
                  .fetchMangaRanking(
                    type: selected[0] as MangaRankingType,
                    offset: offset,
                    limit: limit,
                  )
                  .then((PageResult<Manga> page) => page.items),
          itemBuilder: _buildMangaTile,
        ),
      ),
    );
    if (mounted) _loadMembership();
  }

  Widget _buildAnimeTile(BuildContext context, Anime anime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: BrowseListTile(
        picture: anime.picture,
        title: anime.title,
        score: anime.meanScore,
        rank: anime.rank,
        mediaType: anime.mediaType,
        statusLabel: _animeById[anime.id]?.userStatus.label,
        onTap: () => _openAnime(anime),
      ),
    );
  }

  Widget _buildMangaTile(BuildContext context, Manga manga) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: BrowseListTile(
        picture: manga.picture,
        title: manga.title,
        score: manga.meanScore,
        rank: manga.rank,
        mediaType: manga.mediaType,
        statusLabel: _mangaById[manga.id]?.userStatus.label,
        onTap: () => _openManga(manga),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppTokens.spaceMd,
          bottom: AppTokens.spaceXl,
        ),
        children: <Widget>[
          _BrowseSection<Anime>(
            title: "This Season's Anime · ${_currentSeason.label}",
            future: _season,
            onViewMore: _openSeasonal,
            onRetry: _refresh,
            itemBuilder: (BuildContext context, Anime anime) =>
                _animePosterCard(anime),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _BrowseSection<Anime>(
            title: "For You",
            future: _forYou,
            onViewMore: _openSuggestions,
            onRetry: _refresh,
            hideWhenEmpty: true,
            itemBuilder: (BuildContext context, Anime anime) =>
                _animePosterCard(anime),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _BrowseSection<Anime>(
            title: "Top Airing Anime",
            future: _airing,
            onViewMore: () => _openAnimeRanking(AnimeRankingType.airing),
            onRetry: _refresh,
            itemBuilder: (BuildContext context, Anime anime) =>
                _animePosterCard(anime),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _BrowseSection<Anime>(
            title: "Top Upcoming Anime",
            future: _upcoming,
            onViewMore: () => _openAnimeRanking(AnimeRankingType.upcoming),
            onRetry: _refresh,
            itemBuilder: (BuildContext context, Anime anime) =>
                _animePosterCard(anime),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _BrowseSection<Manga>(
            title: "Top Manga",
            future: _topManga,
            onViewMore: () => _openMangaRanking(MangaRankingType.manga),
            onRetry: _refresh,
            itemBuilder: (BuildContext context, Manga manga) =>
                _mangaPosterCard(manga),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          _BrowseSection<Manga>(
            title: "Top Novels",
            future: _topNovels,
            onViewMore: () => _openMangaRanking(MangaRankingType.novels),
            onRetry: _refresh,
            itemBuilder: (BuildContext context, Manga manga) =>
                _mangaPosterCard(manga),
          ),
        ],
      ),
    );
  }

  Widget _animePosterCard(Anime anime) {
    return MediaPosterCard(
      picture: anime.picture,
      title: anime.title,
      score: anime.meanScore,
      rank: anime.rank,
      statusLabel: _animeById[anime.id]?.userStatus.shortLabel,
      onTap: () => _openAnime(anime),
    );
  }

  Widget _mangaPosterCard(Manga manga) {
    return MediaPosterCard(
      picture: manga.picture,
      title: manga.title,
      score: manga.meanScore,
      rank: manga.rank,
      statusLabel: _mangaById[manga.id]?.userStatus.shortLabel,
      onTap: () => _openManga(manga),
    );
  }

  static List<SeasonRef> _buildSeasonOptions(SeasonRef current) {
    final List<SeasonRef> options = <SeasonRef>[];
    for (int year = current.year; year >= _oldestSeasonYear; year--) {
      for (final MediaSeason season in MediaSeason.values.reversed) {
        if (year == current.year && season.index > current.season.index) {
          continue;
        }
        options.add(SeasonRef(year: year, season: season));
      }
    }
    return options;
  }
}

/// A single browse section that resolves [future] into a carousel, showing
/// inline loading, error, and empty states.
class _BrowseSection<T> extends StatelessWidget {
  const _BrowseSection({
    required this.title,
    required this.future,
    required this.itemBuilder,
    required this.onViewMore,
    required this.onRetry,
    this.hideWhenEmpty = false,
  });

  final String title;
  final Future<List<T>>? future;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onViewMore;
  final VoidCallback onRetry;
  final bool hideWhenEmpty;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
        if (snapshot.hasError) {
          return BrowseSection(
            title: title,
            child: _MessageRow(
              message: "Couldn't load this section.",
              actionLabel: "Retry",
              onAction: onRetry,
            ),
          );
        }
        if (!snapshot.hasData) {
          return BrowseSection(
            title: title,
            child: const _MessageRow(loading: true),
          );
        }
        final List<T> items = snapshot.data!;
        if (items.isEmpty) {
          if (hideWhenEmpty) return const SizedBox.shrink();
          return BrowseSection(
            title: title,
            child: const _MessageRow(message: "Nothing here yet."),
          );
        }
        return BrowseSection(
          title: title,
          onViewMore: onViewMore,
          child: BrowseCarousel(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) =>
                itemBuilder(context, items[index]),
          ),
        );
      },
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    this.message,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaPosterCard.posterHeight,
      child: Center(
        child: loading
            ? const SizedBox(
                height: 22.0,
                width: 22.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (message != null)
                    Text(
                      message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (actionLabel != null && onAction != null) ...<Widget>[
                    if (message != null)
                      const SizedBox(width: AppTokens.spaceSm),
                    TextButton(onPressed: onAction, child: Text(actionLabel!)),
                  ],
                ],
              ),
      ),
    );
  }
}
