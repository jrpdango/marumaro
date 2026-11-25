import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/search/search.dart';

class _FakeController extends GlobalController {
  _FakeController({this.cachedAnime = const <int, Anime>{}});

  final Map<int, Anime> cachedAnime;

  String? lastAnimeQuery;
  String? lastMangaQuery;
  int animeSearches = 0;
  int mangaSearches = 0;

  @override
  Future<PageResult<Anime>> searchAnimeCatalog({
    required String query,
    required int offset,
    int limit = MalRepository.browsePageSize,
  }) async {
    animeSearches++;
    lastAnimeQuery = query;
    return PageResult<Anime>(items: <Anime>[_resultAnime()], hasMore: false);
  }

  @override
  Future<PageResult<Manga>> searchMangaCatalog({
    required String query,
    required int offset,
    int limit = MalRepository.browsePageSize,
  }) async {
    mangaSearches++;
    lastMangaQuery = query;
    return PageResult<Manga>(items: <Manga>[_resultManga()], hasMore: false);
  }

  @override
  Future<Map<int, Anime>> animeById() async => cachedAnime;

  @override
  Future<Map<int, Manga>> mangaById() async => const <int, Manga>{};
}

Anime _resultAnime() {
  return Anime.fromNodeJson(<String, dynamic>{
    "node": <String, dynamic>{
      "id": 1,
      "title": "Result Anime",
      "num_episodes": 12,
      "status": "finished_airing",
      "mean": 8.4,
      "media_type": "tv",
      "num_list_users": 123456,
      "main_picture": <String, dynamic>{"medium": ""},
    },
  });
}

Manga _resultManga() {
  return Manga.fromNodeJson(<String, dynamic>{
    "node": <String, dynamic>{
      "id": 2,
      "title": "Result Manga",
      "num_chapters": 30,
      "num_volumes": 4,
      "status": "currently_publishing",
      "mean": 9.0,
      "media_type": "manga",
      "main_picture": <String, dynamic>{"medium": ""},
    },
  });
}

Anime _cachedAnime(Anime anime, AnimeListStatus status) {
  return anime.copyWith(inList: true, userStatus: status);
}

Widget _host(GlobalController controller) {
  return GlobalControllerScope(
    controller: controller,
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const CatalogSearchPage(),
    ),
  );
}

void main() {
  late _FakeController controller;

  setUp(() {
    controller = _FakeController();
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets("shows a hint before a query is entered", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(controller));
    await tester.pump();

    expect(
      find.textContaining("Search anime and manga on MyAnimeList"),
      findsOneWidget,
    );
    expect(controller.animeSearches, 0);
    expect(controller.mangaSearches, 0);
  });

  testWidgets("searches the anime catalog after the debounce", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(controller));
    await tester.pump();

    await tester.enterText(find.byType(TextField), "frieren");
    await tester.pump();
    expect(controller.animeSearches, 0);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(controller.lastAnimeQuery, "frieren");
    expect(controller.animeSearches, 1);
    expect(find.text("Result Anime"), findsOneWidget);
  });

  testWidgets("switches to the manga catalog", (WidgetTester tester) async {
    await tester.pumpWidget(_host(controller));
    await tester.pump();

    await tester.tap(find.text("Manga"));
    await tester.pump();
    expect(find.text("Search manga on MyAnimeList..."), findsOneWidget);

    await tester.enterText(find.byType(TextField), "berserk");
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(controller.lastMangaQuery, "berserk");
    expect(controller.mangaSearches, 1);
    expect(find.text("Result Manga"), findsOneWidget);
  });

  testWidgets("shows the cached list status for search results", (
    WidgetTester tester,
  ) async {
    controller.dispose();
    controller = _FakeController(
      cachedAnime: <int, Anime>{
        1: _cachedAnime(_resultAnime(), AnimeListStatus.watching),
      },
    );

    await tester.pumpWidget(_host(controller));
    await tester.pump();
    await tester.pump();
    await tester.enterText(find.byType(TextField), "result");
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text("Result Anime"), findsOneWidget);
    expect(find.text("Currently Watching"), findsOneWidget);
  });
}
