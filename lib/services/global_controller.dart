import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:miru/models/anime.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/list_sort.dart';
import 'package:miru/models/manga.dart';
import 'package:miru/models/page.dart';
import 'package:miru/models/user.dart';
import 'package:miru/services/auth_repository.dart';
import 'package:miru/services/local_store.dart';
import 'package:miru/services/mal_api_client.dart';
import 'package:miru/services/mal_repository.dart';
import 'package:miru/services/token_store.dart';

/// Application-wide state: authentication, the current user, and a cache of
/// their lists backed by [LocalStore].
class GlobalController extends ChangeNotifier {
  GlobalController({LocalStore? store, MalRepository? repository})
      : store = store ?? LocalStore() {
    final http.Client httpClient = http.Client();
    auth = AuthRepository(httpClient: httpClient, tokenStore: TokenStore());
    this.repository = repository ??
        MalRepository(
          api: MalApiClient(
            httpClient: httpClient,
            accessTokenProvider: () => auth.accessToken,
          ),
        );
  }

  late final AuthRepository auth;
  late final MalRepository repository;
  final LocalStore store;

  static const String _sortKey = "list_sort";

  User? user;

  ListSort listSort = ListSort.defaultSort;

  bool animeSyncing = false;
  bool animeSynced = false;
  bool animeSyncFailed = false;

  bool mangaSyncing = false;
  bool mangaSynced = false;
  bool mangaSyncFailed = false;

  bool _disposed = false;

  /// Notifies listeners on a later microtask.
  ///
  /// Syncs can be kicked off from `didChangeDependencies`, i.e. during the build
  /// phase, where notifying synchronously would make [GlobalControllerScope]'s
  /// element call `markNeedsBuild` mid-build.
  void _notifySafely() {
    scheduleMicrotask(() {
      if (!_disposed) notifyListeners();
    });
  }

  /// Fetches the entire anime list and replaces the cached status buckets.
  Future<void> syncAnime() async {
    if (animeSyncing) return;
    animeSyncing = true;
    animeSyncFailed = false;
    _notifySafely();
    try {
      for (final AnimeListStatus status in AnimeListStatus.values) {
        await store.replaceAnimeStatus(status, await _allAnime(status));
      }
      animeSynced = true;
    } catch (_) {
      animeSyncFailed = true;
    } finally {
      animeSyncing = false;
      _notifySafely();
    }
  }

  /// Fetches the entire manga list and replaces the cached status buckets.
  Future<void> syncManga() async {
    if (mangaSyncing) return;
    mangaSyncing = true;
    mangaSyncFailed = false;
    _notifySafely();
    try {
      for (final MangaListStatus status in MangaListStatus.values) {
        await store.replaceMangaStatus(status, await _allManga(status));
      }
      mangaSynced = true;
    } catch (_) {
      mangaSyncFailed = true;
    } finally {
      mangaSyncing = false;
      _notifySafely();
    }
  }

  Future<void> syncAll() async {
    await loadSortPreferences();
    await syncAnime();
    await syncManga();
  }

  /// Restores the persisted sort choice shared by both lists.
  Future<void> loadSortPreferences() async {
    listSort = ListSort.decode(
      await store.getPreference(_sortKey),
      fallback: ListSort.defaultSort,
    );
    _notifySafely();
  }

  /// Updates and persists the shared list sort.
  Future<void> setListSort(ListSort sort) async {
    if (sort == listSort) return;
    listSort = sort;
    notifyListeners();
    await store.setPreference(_sortKey, sort.encode());
  }

  Future<List<Anime>> _allAnime(AnimeListStatus status) async {
    final List<Anime> items = <Anime>[];
    int offset = 0;
    while (true) {
      final PageResult<Anime> page =
          await repository.fetchAnimeListPage(offset: offset, status: status);
      items.addAll(page.items);
      if (!page.hasMore) break;
      offset += page.items.length;
    }
    return items;
  }

  Future<List<Manga>> _allManga(MangaListStatus status) async {
    final List<Manga> items = <Manga>[];
    int offset = 0;
    while (true) {
      final PageResult<Manga> page =
          await repository.fetchMangaListPage(offset: offset, status: status);
      items.addAll(page.items);
      if (!page.hasMore) break;
      offset += page.items.length;
    }
    return items;
  }

  Future<List<Anime>> pageAnime(
    AnimeListStatus status, {
    required int offset,
    required int limit,
  }) {
    return store.pageAnime(status, offset: offset, limit: limit, sort: listSort);
  }

  Future<int> countAnime(AnimeListStatus status) {
    return store.countAnime(status);
  }

  Future<List<Anime>> searchAnime(
    String query, {
    required int offset,
    required int limit,
  }) {
    return store.searchAnime(query, offset: offset, limit: limit);
  }

  Future<List<Manga>> pageManga(
    MangaListStatus status, {
    required int offset,
    required int limit,
  }) {
    return store.pageManga(status, offset: offset, limit: limit, sort: listSort);
  }

  Future<int> countManga(MangaListStatus status) {
    return store.countManga(status);
  }

  Future<List<Manga>> searchManga(
    String query, {
    required int offset,
    required int limit,
  }) {
    return store.searchManga(query, offset: offset, limit: limit);
  }

  /// Persists list changes for [anime] and updates the cache.
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

    await store.updateAnime(
      anime.copyWith(
        userStatus: status,
        userScore: score,
        userEpisodesWatched: episodesWatched,
      ),
    );
    notifyListeners();
  }

  /// Persists list changes for [manga] and updates the cache.
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

    await store.updateManga(
      manga.copyWith(
        userStatus: status,
        userScore: score,
        userChaptersRead: chaptersRead,
        userVolumesRead: volumesRead,
      ),
    );
    notifyListeners();
  }

  /// Signs out and clears the cached lists.
  Future<void> signOut() async {
    await auth.signOut();
    await store.clearAll();
    user = null;
    animeSynced = false;
    mangaSynced = false;
    animeSyncFailed = false;
    mangaSyncFailed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
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
