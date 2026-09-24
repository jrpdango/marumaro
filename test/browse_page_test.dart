import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:miru/core/core.dart';
import 'package:miru/features/browse/browse.dart';

class _FakeRepository extends MalRepository {
  _FakeRepository({this.suggestions = const <Anime>[]})
    : super(
        api: MalApiClient(
          httpClient: http.Client(),
          accessTokenProvider: () => null,
        ),
      );

  final List<Anime> suggestions;

  @override
  Future<PageResult<Anime>> fetchSeasonalAnime({
    required SeasonRef season,
    AnimeSeasonSort sort = AnimeSeasonSort.score,
    required int offset,
    int limit = MalRepository.browsePageSize,
  }) async {
    return PageResult<Anime>(
      items: <Anime>[_anime(1, "Seasonal Anime")],
      hasMore: false,
    );
  }

  @override
  Future<PageResult<Anime>> fetchSuggestedAnime({
    required int offset,
    int limit = MalRepository.browsePageSize,
  }) async {
    return PageResult<Anime>(items: suggestions, hasMore: false);
  }

  @override
  Future<PageResult<Anime>> fetchAnimeRanking({
    required AnimeRankingType type,
    required int offset,
    int limit = MalRepository.browsePageSize,
  }) async {
    return PageResult<Anime>(
      items: <Anime>[_anime(2, "Ranked ${type.label}")],
      hasMore: false,
    );
  }

  @override
  Future<PageResult<Manga>> fetchMangaRanking({
    required MangaRankingType type,
    required int offset,
    int limit = MalRepository.browsePageSize,
  }) async {
    return PageResult<Manga>(
      items: <Manga>[_manga(3, "Ranked ${type.label}")],
      hasMore: false,
    );
  }
}

class _FakeStore extends LocalStore {
  _FakeStore({this.cachedAnime = const <int, Anime>{}});

  final Map<int, Anime> cachedAnime;

  @override
  Future<Map<int, Anime>> allAnime() async => cachedAnime;

  @override
  Future<Map<int, Manga>> allManga() async => const <int, Manga>{};
}

Anime _anime(int id, String title) {
  return Anime.fromNodeJson(<String, dynamic>{
    "node": <String, dynamic>{
      "id": id,
      "title": title,
      "num_episodes": 12,
      "status": "finished_airing",
      "mean": 8.0,
      "media_type": "tv",
      "main_picture": <String, dynamic>{"medium": ""},
    },
    "ranking": <String, dynamic>{"rank": 1},
  });
}

Manga _manga(int id, String title) {
  return Manga.fromNodeJson(<String, dynamic>{
    "node": <String, dynamic>{
      "id": id,
      "title": title,
      "num_chapters": 20,
      "num_volumes": 3,
      "status": "currently_publishing",
      "mean": 8.5,
      "media_type": "manga",
      "main_picture": <String, dynamic>{"medium": ""},
    },
    "ranking": <String, dynamic>{"rank": 2},
  });
}

Widget _host(GlobalController controller) {
  return GlobalControllerScope(
    controller: controller,
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: BrowsePage()),
    ),
  );
}

Future<void> _pumpLoaded(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200.0, 4000.0);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets("renders every browse section", (WidgetTester tester) async {
    _useTallSurface(tester);
    final GlobalController controller = GlobalController(
      store: _FakeStore(),
      repository: _FakeRepository(
        suggestions: <Anime>[_anime(9, "Suggested Anime")],
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await _pumpLoaded(tester);

    expect(
      find.text("This Season's Anime · ${SeasonRef.current().label}"),
      findsOneWidget,
    );
    expect(find.text("For You"), findsOneWidget);
    expect(find.text("Top Airing Anime"), findsOneWidget);
    expect(find.text("Top Upcoming Anime"), findsOneWidget);
    expect(find.text("Top Manga"), findsOneWidget);
    expect(find.text("Top Novels"), findsOneWidget);

    expect(find.text("Seasonal Anime"), findsOneWidget);
    expect(find.text("Suggested Anime"), findsOneWidget);
    expect(find.text("Ranked Top Airing"), findsOneWidget);
    expect(find.text("Ranked Top Novels"), findsOneWidget);
    expect(find.text("View More"), findsWidgets);
  });

  testWidgets("hides For You when there are no suggestions", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = GlobalController(
      store: _FakeStore(),
      repository: _FakeRepository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await _pumpLoaded(tester);

    expect(find.text("For You"), findsNothing);
    expect(find.text("Top Airing Anime"), findsOneWidget);
  });

  testWidgets("shows the list status for cached members", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = GlobalController(
      store: _FakeStore(
        cachedAnime: <int, Anime>{
          1: _anime(
            1,
            "Seasonal Anime",
          ).copyWith(inList: true, userStatus: AnimeListStatus.watching),
        },
      ),
      repository: _FakeRepository(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await _pumpLoaded(tester);

    // The seasonal anime (id 1) is cached as watching, so its poster shows the
    // short status chip; the ranked anime (id 2) is not cached.
    expect(find.text("Watching"), findsOneWidget);
  });
}
