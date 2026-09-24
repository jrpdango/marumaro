import 'package:flutter/material.dart';
import 'package:miru/core/core.dart';
import 'package:miru/features/browse/browse_list_page.dart';
import 'package:miru/features/browse/widgets/browse_list_tile.dart';
import 'package:miru/features/browse/widgets/browse_section.dart';
import 'package:miru/features/browse/widgets/media_poster_card.dart';
import 'package:miru/features/media_details/media_details.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= GlobalControllerScope.of(context);
    if (_season == null) _assignFutures();
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
  }

  void _openAnime(Anime anime) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AnimeDetailsPage(anime: anime)),
    );
  }

  void _openManga(Manga manga) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MangaDetailsPage(manga: manga)),
    );
  }

  void _openSeasonal() {
    Navigator.of(context).push(
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
  }

  void _openAnimeRanking(AnimeRankingType initial) {
    Navigator.of(context).push(
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
  }

  void _openMangaRanking(MangaRankingType initial) {
    Navigator.of(context).push(
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
            onViewMore: () => _openAnimeRanking(AnimeRankingType.all),
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
      onTap: () => _openAnime(anime),
    );
  }

  Widget _mangaPosterCard(Manga manga) {
    return MediaPosterCard(
      picture: manga.picture,
      title: manga.title,
      score: manga.meanScore,
      rank: manga.rank,
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
