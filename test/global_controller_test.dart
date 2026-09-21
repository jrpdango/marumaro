import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/models/page.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/services/local_store.dart';
import 'package:miru/services/mal_api_client.dart';
import 'package:miru/services/mal_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const int _fakePageSize = 2;

class _FakeRepository extends MalRepository {
  _FakeRepository({required this.anime, required this.manga})
      : super(
          api: MalApiClient(
            httpClient: http.Client(),
            accessTokenProvider: () => null,
          ),
        );

  final Map<AnimeListStatus, List<Anime>> anime;
  final Map<MangaListStatus, List<Manga>> manga;

  @override
  Future<PageResult<Anime>> fetchAnimeListPage({
    required int offset,
    int limit = MalRepository.pageSize,
    AnimeListStatus? status,
  }) async {
    final List<Anime> all = anime[status] ?? const <Anime>[];
    if (offset >= all.length) {
      return const PageResult<Anime>(items: <Anime>[], hasMore: false);
    }
    final int end = (offset + _fakePageSize).clamp(0, all.length);
    return PageResult<Anime>(
      items: all.sublist(offset, end),
      hasMore: end < all.length,
    );
  }

  @override
  Future<PageResult<Manga>> fetchMangaListPage({
    required int offset,
    int limit = MalRepository.pageSize,
    MangaListStatus? status,
  }) async {
    final List<Manga> all = manga[status] ?? const <Manga>[];
    if (offset >= all.length) {
      return const PageResult<Manga>(items: <Manga>[], hasMore: false);
    }
    final int end = (offset + _fakePageSize).clamp(0, all.length);
    return PageResult<Manga>(
      items: all.sublist(offset, end),
      hasMore: end < all.length,
    );
  }

  @override
  Future<void> updateListStatus({
    required int animeId,
    required AnimeListStatus status,
    required int score,
    required int episodesWatched,
  }) async {}

  @override
  Future<void> updateMangaListStatus({
    required int mangaId,
    required MangaListStatus status,
    required int score,
    required int chaptersRead,
    required int volumesRead,
  }) async {}
}

Anime _anime(int id, AnimeListStatus status) {
  return Anime(
    id: id,
    title: "Anime $id",
    picture: Uri.parse("https://example.com/$id.jpg"),
    totalEpisodes: 12,
    showStatus: AnimeAiringStatus.finishedAiring,
    userStatus: status,
    userEpisodesWatched: 0,
    userScore: 0,
  );
}

Manga _manga(int id, MangaListStatus status) {
  return Manga(
    id: id,
    title: "Manga $id",
    picture: Uri.parse("https://example.com/m$id.jpg"),
    totalChapters: 30,
    totalVolumes: 4,
    publishingStatus: MangaPublishingStatus.finished,
    userStatus: status,
    userChaptersRead: 0,
    userVolumesRead: 0,
    userScore: 0,
  );
}

void main() {
  sqfliteFfiInit();

  late LocalStore store;
  late _FakeRepository repository;
  late GlobalController controller;

  setUp(() {
    store = LocalStore(factory: databaseFactoryFfi, path: inMemoryDatabasePath);
    repository = _FakeRepository(
      anime: <AnimeListStatus, List<Anime>>{
        AnimeListStatus.watching: <Anime>[
          _anime(1, AnimeListStatus.watching),
          _anime(2, AnimeListStatus.watching),
          _anime(3, AnimeListStatus.watching),
          _anime(4, AnimeListStatus.watching),
          _anime(5, AnimeListStatus.watching),
        ],
        AnimeListStatus.completed: <Anime>[_anime(6, AnimeListStatus.completed)],
      },
      manga: <MangaListStatus, List<Manga>>{
        MangaListStatus.reading: <Manga>[
          _manga(1, MangaListStatus.reading),
          _manga(2, MangaListStatus.reading),
          _manga(3, MangaListStatus.reading),
        ],
      },
    );
    controller = GlobalController(store: store, repository: repository);
  });

  tearDown(() async {
    controller.dispose();
    await store.close();
  });

  test("syncAnime follows pagination and fills every status bucket", () async {
    await controller.syncAnime();

    expect(controller.animeSynced, isTrue);
    expect(controller.animeSyncFailed, isFalse);
    expect(await controller.countAnime(AnimeListStatus.watching), 5);
    expect(await controller.countAnime(AnimeListStatus.completed), 1);

    final List<Anime> watching = await controller.pageAnime(
      AnimeListStatus.watching,
      offset: 0,
      limit: 10,
    );
    expect(watching.map((Anime a) => a.id), <int>[1, 2, 3, 4, 5]);
  });

  test("syncManga follows pagination", () async {
    await controller.syncManga();

    expect(controller.mangaSynced, isTrue);
    expect(await controller.countManga(MangaListStatus.reading), 3);
  });

  test("updateAnime moves the entry between cached buckets", () async {
    await controller.syncAnime();

    await controller.updateAnime(
      anime: _anime(1, AnimeListStatus.watching),
      status: AnimeListStatus.completed,
      score: 9,
      episodesWatched: 12,
    );

    expect(await controller.countAnime(AnimeListStatus.watching), 4);
    final List<Anime> completed = await controller.pageAnime(
      AnimeListStatus.completed,
      offset: 0,
      limit: 10,
    );
    expect(completed.first.id, 1);
    expect(completed.first.userScore, 9);
    expect(completed.first.userEpisodesWatched, 12);
  });

  test("a failed sync leaves previously cached data intact", () async {
    await controller.syncAnime();
    expect(await controller.countAnime(AnimeListStatus.watching), 5);

    controller = GlobalController(
      store: store,
      repository: _FailingRepository(),
    );
    await controller.syncAnime();

    expect(controller.animeSyncFailed, isTrue);
    expect(controller.animeSynced, isFalse);
    expect(await controller.countAnime(AnimeListStatus.watching), 5);
  });
}

class _FailingRepository extends MalRepository {
  _FailingRepository()
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
    throw Exception("network down");
  }
}
