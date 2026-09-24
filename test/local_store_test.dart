import 'package:flutter_test/flutter_test.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/list_sort.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/services/local_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Anime _anime(
  int id, {
  String title = "Title",
  AnimeListStatus status = AnimeListStatus.watching,
  int episodesWatched = 0,
  int score = 0,
  DateTime? updatedAt,
}) {
  return Anime(
    id: id,
    title: title,
    picture: Uri.parse("https://example.com/$id.jpg"),
    totalEpisodes: 12,
    showStatus: AnimeAiringStatus.finishedAiring,
    userStatus: status,
    userEpisodesWatched: episodesWatched,
    userScore: score,
    updatedAt: updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

Manga _manga(
  int id, {
  String title = "Manga Title",
  MangaListStatus status = MangaListStatus.reading,
  int chaptersRead = 0,
  int volumesRead = 0,
  int score = 0,
  DateTime? updatedAt,
}) {
  return Manga(
    id: id,
    title: title,
    picture: Uri.parse("https://example.com/m$id.jpg"),
    totalChapters: 30,
    totalVolumes: 4,
    publishingStatus: MangaPublishingStatus.finished,
    userStatus: status,
    userChaptersRead: chaptersRead,
    userVolumesRead: volumesRead,
    userScore: score,
    updatedAt: updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

void main() {
  sqfliteFfiInit();

  late LocalStore store;

  setUp(() {
    store = LocalStore(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
  });

  tearDown(() async {
    await store.close();
  });

  group("anime", () {
    test("pages entries in insertion order and counts them", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[
          _anime(1, title: "A"),
          _anime(2, title: "B"),
          _anime(3, title: "C"),
        ],
      );

      expect(await store.countAnime(AnimeListStatus.watching), 3);

      final List<Anime> firstPage = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 2,
      );
      expect(firstPage.map((Anime a) => a.id), <int>[1, 2]);

      final List<Anime> secondPage = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 2,
        limit: 2,
      );
      expect(secondPage.map((Anime a) => a.id), <int>[3]);
    });

    test("keeps statuses separate", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[_anime(1)],
      );
      await store.replaceAnimeStatus(
        AnimeListStatus.completed,
        <Anime>[_anime(2), _anime(3)],
      );

      expect(await store.countAnime(AnimeListStatus.watching), 1);
      expect(await store.countAnime(AnimeListStatus.completed), 2);
      expect(await store.countAnime(AnimeListStatus.dropped), 0);
    });

    test("replaces the previous contents of a status", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[_anime(1), _anime(2), _anime(3)],
      );
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[_anime(9)],
      );

      expect(await store.countAnime(AnimeListStatus.watching), 1);
      final List<Anime> page = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 10,
      );
      expect(page.single.id, 9);
    });

    test("round-trips every field", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.onHold,
        <Anime>[_anime(7, title: "Round Trip", episodesWatched: 5, score: 9)],
      );

      final Anime anime = (await store.pageAnime(
        AnimeListStatus.onHold,
        offset: 0,
        limit: 1,
      ))
          .single;
      expect(anime.title, "Round Trip");
      expect(anime.picture, Uri.parse("https://example.com/7.jpg"));
      expect(anime.totalEpisodes, 12);
      expect(anime.showStatus, AnimeAiringStatus.finishedAiring);
      expect(anime.userStatus, AnimeListStatus.onHold);
      expect(anime.userEpisodesWatched, 5);
      expect(anime.userScore, 9);
    });

    test("searches titles case-insensitively", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[
          _anime(1, title: "Fullmetal Alchemist"),
          _anime(2, title: "Steins;Gate"),
          _anime(3, title: "Full Metal Panic"),
        ],
      );

      final List<Anime> results = await store.searchAnime(
        "fullmetal",
        offset: 0,
        limit: 10,
      );
      expect(results.map((Anime a) => a.id), <int>[1]);

      final List<Anime> all = await store.searchAnime(
        "full",
        offset: 0,
        limit: 10,
      );
      expect(all.map((Anime a) => a.id), <int>[3, 1]);
    });

    test("moves an entry to the top when its status changes", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[_anime(1), _anime(2)],
      );
      await store.replaceAnimeStatus(
        AnimeListStatus.completed,
        <Anime>[_anime(3)],
      );

      await store.updateAnime(
        _anime(2, status: AnimeListStatus.completed, episodesWatched: 12),
      );

      expect(await store.countAnime(AnimeListStatus.watching), 1);
      final List<Anime> completed = await store.pageAnime(
        AnimeListStatus.completed,
        offset: 0,
        limit: 10,
      );
      expect(completed.map((Anime a) => a.id), <int>[2, 3]);
      expect(completed.first.userEpisodesWatched, 12);
    });

    test("moves an entry to the top when its progress changes", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[_anime(1), _anime(2), _anime(3)],
      );

      await store.updateAnime(_anime(2, episodesWatched: 6, score: 8));

      final List<Anime> page = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 10,
      );
      expect(page.map((Anime a) => a.id), <int>[2, 1, 3]);
      expect(page.first.userEpisodesWatched, 6);
      expect(page.first.userScore, 8);
    });

    test("sorts by score with the requested direction", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[
          _anime(1, score: 5),
          _anime(2, score: 9),
          _anime(3, score: 7),
        ],
      );

      final List<Anime> descending = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 10,
        sort: const ListSort(field: ListSortField.score, descending: true),
      );
      expect(descending.map((Anime a) => a.id), <int>[2, 3, 1]);

      final List<Anime> ascending = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 10,
        sort: const ListSort(field: ListSortField.score, descending: false),
      );
      expect(ascending.map((Anime a) => a.id), <int>[1, 3, 2]);
    });

    test("sorts by title case-insensitively", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[
          _anime(1, title: "banana"),
          _anime(2, title: "Apple"),
          _anime(3, title: "cherry"),
        ],
      );

      final List<Anime> title = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 10,
        sort: const ListSort(field: ListSortField.title, descending: false),
      );
      expect(title.map((Anime a) => a.id), <int>[2, 1, 3]);
    });

    test("sorts by the stored updated timestamp", () async {
      await store.replaceAnimeStatus(
        AnimeListStatus.watching,
        <Anime>[
          _anime(1, updatedAt: DateTime.fromMillisecondsSinceEpoch(100)),
          _anime(2, updatedAt: DateTime.fromMillisecondsSinceEpoch(300)),
          _anime(3, updatedAt: DateTime.fromMillisecondsSinceEpoch(200)),
        ],
      );

      final List<Anime> page = await store.pageAnime(
        AnimeListStatus.watching,
        offset: 0,
        limit: 10,
      );
      expect(page.map((Anime a) => a.id), <int>[2, 3, 1]);
    });
  });

  group("manga", () {
    test("pages, counts, searches and updates", () async {
      await store.replaceMangaStatus(
        MangaListStatus.reading,
        <Manga>[
          _manga(1, title: "Berserk"),
          _manga(2, title: "Vagabond"),
        ],
      );
      await store.replaceMangaStatus(
        MangaListStatus.planToRead,
        <Manga>[_manga(3, title: "Berserk of Gluttony")],
      );

      expect(await store.countManga(MangaListStatus.reading), 2);

      final List<Manga> found = await store.searchManga(
        "berserk",
        offset: 0,
        limit: 10,
      );
      expect(found.map((Manga m) => m.id), <int>[1, 3]);

      await store.updateManga(
        _manga(
          2,
          status: MangaListStatus.completed,
          chaptersRead: 30,
          volumesRead: 4,
        ),
      );
      expect(await store.countManga(MangaListStatus.reading), 1);
      expect(await store.countManga(MangaListStatus.completed), 1);

      final Manga moved = (await store.pageManga(
        MangaListStatus.completed,
        offset: 0,
        limit: 1,
      ))
          .single;
      expect(moved.id, 2);
      expect(moved.userChaptersRead, 30);
      expect(moved.userVolumesRead, 4);
    });
  });

  test("stores and retrieves preferences", () async {
    expect(await store.getPreference("anime_sort"), isNull);
    await store.setPreference("anime_sort", "score:asc");
    expect(await store.getPreference("anime_sort"), "score:asc");
    await store.setPreference("anime_sort", "title:desc");
    expect(await store.getPreference("anime_sort"), "title:desc");
  });

  test("clearAll empties both lists", () async {
    await store.replaceAnimeStatus(
      AnimeListStatus.watching,
      <Anime>[_anime(1)],
    );
    await store.replaceMangaStatus(
      MangaListStatus.reading,
      <Manga>[_manga(1)],
    );

    await store.clearAll();

    expect(await store.countAnime(AnimeListStatus.watching), 0);
    expect(await store.countManga(MangaListStatus.reading), 0);
  });

  test("deleteAnime removes a single entry", () async {
    await store.replaceAnimeStatus(
      AnimeListStatus.watching,
      <Anime>[_anime(1), _anime(2)],
    );

    await store.deleteAnime(1);

    expect(await store.countAnime(AnimeListStatus.watching), 1);
    final List<Anime> remaining = await store.pageAnime(
      AnimeListStatus.watching,
      offset: 0,
      limit: 10,
    );
    expect(remaining.single.id, 2);
  });

  test("deleteManga removes a single entry", () async {
    await store.replaceMangaStatus(
      MangaListStatus.reading,
      <Manga>[_manga(1), _manga(2)],
    );

    await store.deleteManga(1);

    expect(await store.countManga(MangaListStatus.reading), 1);
    final List<Manga> remaining = await store.pageManga(
      MangaListStatus.reading,
      offset: 0,
      limit: 10,
    );
    expect(remaining.single.id, 2);
  });
}
