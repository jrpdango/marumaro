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

void main() {
  late _FakeRepository repository;
  late GlobalController controller;

  setUp(() {
    repository = _FakeRepository();
    controller = GlobalController(store: _FakeStore(), repository: repository);
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets("a non-list anime can be added by saving", (WidgetTester tester) async {
    await tester.pumpWidget(
      GlobalControllerScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: AnimeDetailsPage(anime: _browseAnime()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Add to list"), findsOneWidget);
    expect(find.text("Save changes"), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsNothing);

    await tester.tap(find.text("Save changes"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(repository.updateCalls, 1);
    expect(find.text("Add to list"), findsNothing);
    expect(find.text("Save changes"), findsNothing);
  });
}
