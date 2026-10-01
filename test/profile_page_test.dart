import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/profile/profile.dart';

/// An in-memory [LocalStore] so the widget tests do not touch sqflite.
class _FakeStore extends LocalStore {
  _FakeStore({this.anime = const <Anime>[], this.manga = const <Manga>[]});

  final List<Anime> anime;
  final List<Manga> manga;

  @override
  Future<Map<int, Anime>> allAnime() async => <int, Anime>{
        for (final Anime a in anime) a.id: a,
      };

  @override
  Future<Map<int, Manga>> allManga() async => <int, Manga>{
        for (final Manga m in manga) m.id: m,
      };
}

Anime _anime(
  int id,
  String title, {
  required AnimeListStatus status,
  int score = 0,
  int episodes = 0,
}) {
  return Anime(
    id: id,
    title: title,
    picture: Uri.parse("https://example.com/$id.jpg"),
    totalEpisodes: 12,
    showStatus: AnimeAiringStatus.finishedAiring,
    userStatus: status,
    userEpisodesWatched: episodes,
    userScore: score,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

Manga _manga(
  int id,
  String title, {
  required MangaListStatus status,
  int score = 0,
  int chapters = 0,
  int volumes = 0,
}) {
  return Manga(
    id: id,
    title: title,
    picture: Uri.parse("https://example.com/m$id.jpg"),
    totalChapters: 30,
    totalVolumes: 4,
    publishingStatus: MangaPublishingStatus.finished,
    userStatus: status,
    userChaptersRead: chapters,
    userVolumesRead: volumes,
    userScore: score,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

GlobalController _controller({
  List<Anime> anime = const <Anime>[],
  List<Manga> manga = const <Manga>[],
  User? user,
}) {
  final GlobalController controller = GlobalController(
    store: _FakeStore(anime: anime, manga: manga),
  );
  controller.user = user ?? const User(name: "tester");
  return controller;
}

Widget _host(GlobalController controller) {
  return GlobalControllerScope(
    controller: controller,
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const ProfilePage(),
    ),
  );
}

void main() {
  testWidgets("renders computed stats and sections", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller(
      anime: <Anime>[
        _anime(
          1,
          "Best Show",
          status: AnimeListStatus.completed,
          score: 10,
          episodes: 12,
        ),
        _anime(2, "Meh Show", status: AnimeListStatus.watching, score: 6),
      ],
      manga: <Manga>[
        _manga(
          1,
          "Best Manga",
          status: MangaListStatus.completed,
          score: 9,
          chapters: 30,
          volumes: 4,
        ),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(find.text("tester"), findsOneWidget);
    expect(find.text("Overview"), findsOneWidget);
    expect(find.text("Completion"), findsOneWidget);

    final Finder scrollable = find.byType(Scrollable).first;
    for (final String section in <String>[
      "Anime status",
      "Manga status",
      "Scores",
      "Top rated",
    ]) {
      await tester.scrollUntilVisible(
        find.text(section),
        400.0,
        scrollable: scrollable,
      );
      expect(find.text(section), findsOneWidget);
    }
    expect(find.text("Best Show"), findsOneWidget);
  });

  testWidgets("prefers server statistics for headline numbers", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller(
      anime: <Anime>[
        _anime(1, "Only Show", status: AnimeListStatus.completed, score: 8),
      ],
      user: const User(
        name: "tester",
        animeStatistics: MediaStatistics(
          items: 999,
          episodes: 5000,
          meanScore: 9.5,
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(find.text("999"), findsOneWidget);
    expect(find.text("9.50"), findsOneWidget);
    expect(find.text("5K"), findsOneWidget);
  });

  testWidgets("omits charts when the lists are empty", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(find.text("Overview"), findsOneWidget);
    expect(find.text("Anime status"), findsNothing);
    expect(find.text("Manga status"), findsNothing);
    expect(find.text("Scores"), findsNothing);
    expect(find.text("Top rated"), findsNothing);
  });
}
