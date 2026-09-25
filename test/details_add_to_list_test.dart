import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/media_details/media_details.dart';

class _FakeRepository extends MalRepository {
  _FakeRepository({this.myListStatus})
      : super(
          api: MalApiClient(
            httpClient: http.Client(),
            accessTokenProvider: () => null,
          ),
        );

  final Map<String, dynamic>? myListStatus;
  int updateCalls = 0;

  @override
  Future<AnimeDetails> fetchAnimeDetails(int animeId) async {
    return AnimeDetails.fromJson(<String, dynamic>{
      "mean": 8.0,
      "num_episodes": 12,
      "status": "finished_airing",
      "main_picture": <String, dynamic>{"large": ""},
      if (myListStatus != null) "my_list_status": myListStatus,
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

/// Pumps the details page for [anime] with a fake repository and returns it.
Future<_FakeRepository> _pumpDetails(
  WidgetTester tester,
  Anime anime, {
  Map<String, dynamic>? myListStatus,
}) async {
  final _FakeRepository repository = _FakeRepository(
    myListStatus: myListStatus,
  );
  final GlobalController controller = GlobalController(
    store: _FakeStore(),
    repository: repository,
  );
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    GlobalControllerScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: AnimeDetailsPage(anime: anime),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return repository;
}

void main() {
  testWidgets("a non-list anime is added after tapping Add to List", (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = await _pumpDetails(tester, _browseAnime());

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

    expect(repository.updateCalls, 1);
    expect(find.text("Save changes"), findsNothing);
  });

  testWidgets("a stale cached status is cleared when the server has none", (
    WidgetTester tester,
  ) async {
    await _pumpDetails(tester, _listedAnime());

    expect(find.text("Add to List"), findsOneWidget);
    expect(find.text("Currently Watching"), findsNothing);

    await tester.tap(find.text("Add to List"));
    await tester.pump();

    expect(find.text("Plan To Watch"), findsOneWidget);
  });

  testWidgets("the server status is shown for browse entries on the list", (
    WidgetTester tester,
  ) async {
    await _pumpDetails(
      tester,
      _browseAnime(),
      myListStatus: <String, dynamic>{
        "status": "watching",
        "score": 8,
        "num_episodes_watched": 3,
      },
    );

    expect(find.text("Add to List"), findsNothing);
    expect(find.text("Currently Watching"), findsOneWidget);
    expect(find.byTooltip("Increase Episodes"), findsOneWidget);
    expect(find.text("Save changes"), findsNothing);
  });
}
