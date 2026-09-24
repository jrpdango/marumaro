import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:miru/core/core.dart';
import 'package:miru/features/media_details/media_details.dart';

class _FakeRepository extends MalRepository {
  _FakeRepository()
      : super(
          api: MalApiClient(
            httpClient: http.Client(),
            accessTokenProvider: () => null,
          ),
        );

  int updateCalls = 0;

  @override
  Future<AnimeDetails> fetchAnimeDetails(int animeId) async {
    return AnimeDetails.fromJson(<String, dynamic>{
      "mean": 8.0,
      "num_episodes": 12,
      "status": "finished_airing",
      "main_picture": <String, dynamic>{"large": ""},
    });
  }

  @override
  Future<void> updateListStatus({
    required int animeId,
    required AnimeListStatus status,
    required int score,
    required int episodesWatched,
  }) async {
    updateCalls++;
  }
}

class _FakeStore extends LocalStore {
  @override
  Future<void> updateAnime(Anime anime) async {}
}

Anime _browseAnime() {
  return Anime.fromNodeJson(<String, dynamic>{
    "node": <String, dynamic>{
      "id": 1,
      "title": "Browse Anime",
      "num_episodes": 12,
      "status": "finished_airing",
      "main_picture": <String, dynamic>{"medium": ""},
    },
  });
}

Anime _listedAnime() {
  return _browseAnime().copyWith(
    inList: true,
    userStatus: AnimeListStatus.watching,
    userScore: 8,
    userEpisodesWatched: 3,
  );
}

Future<void> _pumpDetails(WidgetTester tester, Anime anime) async {
  await tester.pumpWidget(
    GlobalControllerScope(
      controller: _controller,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: AnimeDetailsPage(anime: anime),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

late _FakeRepository _repository;
late GlobalController _controller;

void main() {
  setUp(() {
    _repository = _FakeRepository();
    _controller = GlobalController(
      store: _FakeStore(),
      repository: _repository,
    );
  });

  tearDown(() {
    _controller.dispose();
  });

  testWidgets("a non-list anime is added after tapping Add to List", (
    WidgetTester tester,
  ) async {
    await _pumpDetails(tester, _browseAnime());

    expect(find.text("Add to List"), findsOneWidget);
    expect(find.text("Save changes"), findsNothing);
    expect(find.byTooltip("Increase Episodes"), findsNothing);

    await tester.tap(find.text("Add to List"));
    await tester.pump();

    expect(find.text("Add to List"), findsNothing);
    expect(find.byTooltip("Increase Episodes"), findsOneWidget);
    expect(find.text("Plan To Watch"), findsOneWidget);
    expect(find.text("Save changes"), findsOneWidget);

    await tester.tap(find.text("Save changes"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(_repository.updateCalls, 1);
    expect(find.text("Save changes"), findsNothing);
  });

  testWidgets("a listed anime opens with its stats and no Add button", (
    WidgetTester tester,
  ) async {
    await _pumpDetails(tester, _listedAnime());

    expect(find.text("Add to List"), findsNothing);
    expect(find.text("Currently Watching"), findsOneWidget);
    expect(find.text("Save changes"), findsNothing);
  });
}
