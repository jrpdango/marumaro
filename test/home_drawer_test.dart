import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:marumaro/core/core.dart';
import 'package:marumaro/features/home/widgets/home_drawer.dart';

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

  @override
  Future<void> replaceAnimeStatus(
    AnimeListStatus status,
    List<Anime> items,
  ) async {}

  @override
  Future<void> replaceMangaStatus(
    MangaListStatus status,
    List<Manga> items,
  ) async {}

  @override
  Future<String?> getPreference(String key) async => null;

  @override
  Future<void> setPreference(String key, String value) async {}
}

class _EmptyRepository extends MalRepository {
  _EmptyRepository()
      : super(
          api: MalApiClient(
            httpClient: http.Client(),
            accessTokenProvider: () => null,
          ),
        );

  @override
  Future<PageResult<Anime>> fetchAnimeListPage({
    required int offset,
    int limit = MalRepository.pageSize,
    AnimeListStatus? status,
  }) async {
    return const PageResult<Anime>(items: <Anime>[], hasMore: false);
  }

  @override
  Future<PageResult<Manga>> fetchMangaListPage({
    required int offset,
    int limit = MalRepository.pageSize,
    MangaListStatus? status,
  }) async {
    return const PageResult<Manga>(items: <Manga>[], hasMore: false);
  }
}

Anime _anime(
  int id,
  AnimeListStatus status, {
  String? title,
  int updatedAt = 0,
}) {
  return Anime(
    id: id,
    title: title ?? "Anime $id",
    picture: Uri.parse("https://example.com/$id.jpg"),
    totalEpisodes: 12,
    showStatus: AnimeAiringStatus.finishedAiring,
    userStatus: status,
    userEpisodesWatched: 0,
    userScore: 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}

Manga _manga(
  int id,
  MangaListStatus status, {
  String? title,
  int updatedAt = 0,
}) {
  return Manga(
    id: id,
    title: title ?? "Manga $id",
    picture: Uri.parse("https://example.com/m$id.jpg"),
    totalChapters: 30,
    totalVolumes: 4,
    publishingStatus: MangaPublishingStatus.finished,
    userStatus: status,
    userChaptersRead: 0,
    userVolumesRead: 0,
    userScore: 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
  );
}

GlobalController _controller({
  List<Anime> anime = const <Anime>[],
  List<Manga> manga = const <Manga>[],
}) {
  return GlobalController(
    store: _FakeStore(anime: anime, manga: manga),
    repository: _EmptyRepository(),
  );
}

Widget _host(
  GlobalController controller, {
  User? user,
  VoidCallback? onOpenProfile,
  VoidCallback? onLogout,
}) {
  return GlobalControllerScope(
    controller: controller,
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: HomeDrawer(
          controller: controller,
          user: user ?? const User(name: "tester"),
          onOpenProfile: onOpenProfile ?? () {},
          onLogout: onLogout ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets("shows the most recent in-progress anime", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller(
      anime: <Anime>[
        _anime(1, AnimeListStatus.watching, title: "Older", updatedAt: 100),
        _anime(2, AnimeListStatus.watching, title: "Newest", updatedAt: 500),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(find.text("Jump back in"), findsOneWidget);
    expect(find.text("Continue watching"), findsOneWidget);
    expect(find.text("Newest"), findsOneWidget);
    expect(find.text("Older"), findsNothing);
  });

  testWidgets("shows the most recent in-progress manga", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller(
      manga: <Manga>[
        _manga(1, MangaListStatus.reading, title: "OlderM", updatedAt: 100),
        _manga(2, MangaListStatus.reading, title: "NewestM", updatedAt: 600),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(find.text("Continue reading"), findsOneWidget);
    expect(find.text("NewestM"), findsOneWidget);
    expect(find.text("OlderM"), findsNothing);
  });

  testWidgets("hides jump back in when nothing is in progress", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(find.text("Jump back in"), findsNothing);
    expect(find.text("Continue watching"), findsNothing);
  });

  testWidgets("sync tile triggers a sync", (WidgetTester tester) async {
    final GlobalController controller = _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.pumpAndSettle();

    expect(controller.animeSynced, isFalse);
    await tester.tap(find.text("Sync now"));
    await tester.pumpAndSettle();

    expect(controller.animeSynced, isTrue);
    expect(controller.mangaSynced, isTrue);
    expect(controller.lastSyncedAt, isNotNull);
  });

  testWidgets("disables the MAL link when there is no user", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller, user: const User(name: "")));
    await tester.pumpAndSettle();

    final ListTile tile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, "Open MyAnimeList profile"),
    );
    expect(tile.enabled, isFalse);
  });

  testWidgets("logout button invokes the callback", (
    WidgetTester tester,
  ) async {
    final GlobalController controller = _controller();
    addTearDown(controller.dispose);
    bool loggedOut = false;

    await tester.pumpWidget(
      _host(controller, onLogout: () => loggedOut = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text("Logout"));
    await tester.pump();

    expect(loggedOut, isTrue);
  });
}
