import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/models/user.dart';
import 'package:miru/services/auth_repository.dart';
import 'package:miru/services/mal_api_client.dart';
import 'package:miru/services/mal_repository.dart';
import 'package:miru/services/token_store.dart';

/// Application-wide state: authentication, the current user, and their lists.
class GlobalController extends ChangeNotifier {
  GlobalController() {
    final http.Client httpClient = http.Client();
    auth = AuthRepository(httpClient: httpClient, tokenStore: TokenStore());
    repository = MalRepository(
      api: MalApiClient(
        httpClient: httpClient,
        accessTokenProvider: () => auth.accessToken,
      ),
    );
  }

  late final AuthRepository auth;
  late final MalRepository repository;

  User? user;

  final List<Anime> globalAnimeList = <Anime>[];
  final Map<AnimeListStatus, List<Anime>> lists = <AnimeListStatus, List<Anime>>{
    for (final AnimeListStatus status in AnimeListStatus.values)
      status: <Anime>[],
  };

  final List<Manga> globalMangaList = <Manga>[];
  final Map<MangaListStatus, List<Manga>> mangaLists =
      <MangaListStatus, List<Manga>>{
    for (final MangaListStatus status in MangaListStatus.values)
      status: <Manga>[],
  };

  /// Whether [loadMangaList] has completed at least once.
  bool mangaListLoaded = false;

  /// Loads the user's full anime list and rebuilds the status buckets.
  Future<void> loadAnimeList() async {
    final List<Anime> anime = await repository.fetchAnimeList();
    globalAnimeList
      ..clear()
      ..addAll(anime);
    for (final List<Anime> list in lists.values) {
      list.clear();
    }
    for (final Anime entry in anime) {
      lists[entry.userStatus]?.add(entry);
    }
    notifyListeners();
  }

  /// Loads the user's full manga list and rebuilds the status buckets.
  Future<void> loadMangaList() async {
    final List<Manga> manga = await repository.fetchMangaList();
    globalMangaList
      ..clear()
      ..addAll(manga);
    for (final List<Manga> list in mangaLists.values) {
      list.clear();
    }
    for (final Manga entry in manga) {
      mangaLists[entry.userStatus]?.add(entry);
    }
    mangaListLoaded = true;
    notifyListeners();
  }

  /// Persists list changes for [anime] and updates local state.
  Future<void> updateAnime({
    required Anime anime,
    required AnimeListStatus status,
    required int score,
    required int episodesWatched,
  }) async {
    await repository.updateListStatus(
      animeId: anime.id,
      status: status,
      score: score,
      episodesWatched: episodesWatched,
    );

    final Anime updated = anime.copyWith(
      userStatus: status,
      userScore: score,
      userEpisodesWatched: episodesWatched,
    );

    final int globalIndex =
        globalAnimeList.indexWhere((Anime a) => a.id == anime.id);
    if (globalIndex != -1) globalAnimeList[globalIndex] = updated;

    if (anime.userStatus != status) {
      lists[anime.userStatus]?.removeWhere((Anime a) => a.id == anime.id);
      lists.putIfAbsent(status, () => <Anime>[]).insert(0, updated);
    } else {
      final List<Anime>? list = lists[status];
      final int index =
          list?.indexWhere((Anime a) => a.id == anime.id) ?? -1;
      if (index != -1) list![index] = updated;
    }
    notifyListeners();
  }

  /// Persists list changes for [manga] and updates local state.
  Future<void> updateManga({
    required Manga manga,
    required MangaListStatus status,
    required int score,
    required int chaptersRead,
    required int volumesRead,
  }) async {
    await repository.updateMangaListStatus(
      mangaId: manga.id,
      status: status,
      score: score,
      chaptersRead: chaptersRead,
      volumesRead: volumesRead,
    );

    final Manga updated = manga.copyWith(
      userStatus: status,
      userScore: score,
      userChaptersRead: chaptersRead,
      userVolumesRead: volumesRead,
    );

    final int globalIndex =
        globalMangaList.indexWhere((Manga m) => m.id == manga.id);
    if (globalIndex != -1) globalMangaList[globalIndex] = updated;

    if (manga.userStatus != status) {
      mangaLists[manga.userStatus]?.removeWhere((Manga m) => m.id == manga.id);
      mangaLists.putIfAbsent(status, () => <Manga>[]).insert(0, updated);
    } else {
      final List<Manga>? list = mangaLists[status];
      final int index =
          list?.indexWhere((Manga m) => m.id == manga.id) ?? -1;
      if (index != -1) list![index] = updated;
    }
    notifyListeners();
  }
}

/// Exposes a [GlobalController] to the widget tree.
class GlobalControllerScope extends InheritedNotifier<GlobalController> {
  const GlobalControllerScope({
    super.key,
    required GlobalController controller,
    required super.child,
  }) : super(notifier: controller);

  static GlobalController of(BuildContext context) {
    final GlobalControllerScope? scope =
        context.dependOnInheritedWidgetOfExactType<GlobalControllerScope>();
    assert(scope != null, "No GlobalControllerScope found in context");
    return scope!.notifier!;
  }
}
