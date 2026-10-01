import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marumaro/core/models/anime.dart';
import 'package:marumaro/core/models/enums.dart';
import 'package:marumaro/core/models/list_sort.dart';
import 'package:marumaro/core/models/manga.dart';
import 'package:marumaro/core/models/page.dart';
import 'package:marumaro/core/models/user.dart';
import 'package:marumaro/core/models/user_list_status.dart';
import 'package:marumaro/core/services/auth_repository.dart';
import 'package:marumaro/core/services/local_store.dart';
import 'package:marumaro/core/services/mal_api_client.dart';
import 'package:marumaro/core/services/mal_repository.dart';
import 'package:marumaro/core/services/token_store.dart';

/// Application-wide state: authentication, the current user, and a cache of
/// their lists backed by [LocalStore].
class GlobalController extends ChangeNotifier {
  GlobalController({LocalStore? store, MalRepository? repository})
    : store = store ?? LocalStore() {
    final http.Client httpClient = http.Client();
    auth = AuthRepository(httpClient: httpClient, tokenStore: TokenStore());
    this.repository =
        repository ??
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
  static const String _themeKey = "theme_mode";
  static const String _edgeSwipeKey = "drawer_edge_swipe";

  User? user;

  ListSort listSort = ListSort.defaultSort;

  AppThemeMode themeMode = AppThemeMode.system;

  bool edgeSwipeOpensDrawer = false;

  bool animeSyncing = false;
  bool animeSynced = false;
  bool animeSyncFailed = false;

  bool mangaSyncing = false;
  bool mangaSynced = false;
  bool mangaSyncFailed = false;

  /// When the most recent list sync succeeded, or null if none has finished.
  DateTime? lastSyncedAt;

  /// Whether any sync is currently running.
  bool get syncing => animeSyncing || mangaSyncing;

  /// Whether either list's most recent sync attempt failed.
  bool get syncFailed => animeSyncFailed || mangaSyncFailed;

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
      lastSyncedAt = DateTime.now();
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
      lastSyncedAt = DateTime.now();
    } catch (_) {
      mangaSyncFailed = true;
    } finally {
      mangaSyncing = false;
      _notifySafely();
    }
  }

  Future<void> syncAll() async {
    await loadSortPreferences();
    await loadThemePreference();
    await loadEdgeSwipePreference();
    await syncAnime();
    await syncManga();
  }

  /// Restores the persisted theme choice.
  Future<void> loadThemePreference() async {
    themeMode = AppThemeMode.fromStorageValue(
      await store.getPreference(_themeKey),
    );
    _notifySafely();
  }

  /// Updates and persists the selected theme.
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == themeMode) return;
    themeMode = mode;
    notifyListeners();
    await store.setPreference(_themeKey, mode.storageValue);
  }

  /// Restores whether a left-edge swipe opens the navigation drawer.
  Future<void> loadEdgeSwipePreference() async {
    edgeSwipeOpensDrawer =
        (await store.getPreference(_edgeSwipeKey)) == "true";
    _notifySafely();
  }

  /// Updates and persists whether a left-edge swipe opens the drawer.
  Future<void> setEdgeSwipeOpensDrawer(bool value) async {
    if (value == edgeSwipeOpensDrawer) return;
    edgeSwipeOpensDrawer = value;
    notifyListeners();
    await store.setPreference(_edgeSwipeKey, value ? "true" : "false");
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
      final PageResult<Anime> page = await repository.fetchAnimeListPage(
        offset: offset,
        status: status,
      );
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
      final PageResult<Manga> page = await repository.fetchMangaListPage(
        offset: offset,
        status: status,
      );
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
    return store.pageAnime(
      status,
      offset: offset,
      limit: limit,
      sort: listSort,
    );
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
    return store.pageManga(
      status,
      offset: offset,
      limit: limit,
      sort: listSort,
    );
  }

  Future<int> countManga(MangaListStatus status) {
    return store.countManga(status);
  }

  /// Every cached anime, keyed by id, for list-membership and status lookups.
  Future<Map<int, Anime>> animeById() {
    return store.allAnime();
  }

  /// Every cached manga, keyed by id, for list-membership and status lookups.
  Future<Map<int, Manga>> mangaById() {
    return store.allManga();
  }

  /// The most recently updated anime the user is currently watching, if any.
  Future<Anime?> continueWatching() async {
    final Iterable<Anime> watching = (await store.allAnime())
        .values
        .where((Anime a) => a.userStatus == AnimeListStatus.watching);
    return _mostRecentlyUpdated<Anime>(
      watching,
      (Anime a) => a.updatedAt,
    );
  }

  /// The most recently updated manga the user is currently reading, if any.
  Future<Manga?> continueReading() async {
    final Iterable<Manga> reading = (await store.allManga())
        .values
        .where((Manga m) => m.userStatus == MangaListStatus.reading);
    return _mostRecentlyUpdated<Manga>(
      reading,
      (Manga m) => m.updatedAt,
    );
  }

  /// A random anime from the user's plan-to-watch list, or null if it is empty.
  Future<Anime?> randomPlannedAnime({Random? random}) async {
    final List<Anime> planned = (await store.allAnime())
        .values
        .where((Anime a) => a.userStatus == AnimeListStatus.planToWatch)
        .toList(growable: false);
    if (planned.isEmpty) return null;
    return planned[(random ?? Random()).nextInt(planned.length)];
  }

  /// A random manga from the user's plan-to-read list, or null if it is empty.
  Future<Manga?> randomPlannedManga({Random? random}) async {
    final List<Manga> planned = (await store.allManga())
        .values
        .where((Manga m) => m.userStatus == MangaListStatus.planToRead)
        .toList(growable: false);
    if (planned.isEmpty) return null;
    return planned[(random ?? Random()).nextInt(planned.length)];
  }

  /// The item in [items] with the latest timestamp from [updatedAt].
  T? _mostRecentlyUpdated<T>(
    Iterable<T> items,
    DateTime Function(T item) updatedAt,
  ) {
    T? best;
    for (final T item in items) {
      if (best == null || updatedAt(item).isAfter(updatedAt(best))) {
        best = item;
      }
    }
    return best;
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

  /// Persists a full set of anime list changes and updates the cache.
  ///
  /// [patch] contains only the fields that changed; [status] is the resulting
  /// state used to refresh the cached basic fields.
  Future<void> updateAnimeUserListStatus({
    required Anime anime,
    required UserListStatus status,
    required Map<String, String> patch,
  }) async {
    await repository.updateAnimeUserListStatus(animeId: anime.id, body: patch);

    await store.updateAnime(
      anime.copyWith(
        userStatus: AnimeListStatus.fromApiValue(status.status),
        userScore: status.score,
        userEpisodesWatched: status.progress,
        updatedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Persists a full set of manga list changes and updates the cache.
  ///
  /// [patch] contains only the fields that changed; [status] is the resulting
  /// state used to refresh the cached basic fields.
  Future<void> updateMangaUserListStatus({
    required Manga manga,
    required UserListStatus status,
    required Map<String, String> patch,
  }) async {
    await repository.updateMangaUserListStatus(mangaId: manga.id, body: patch);

    await store.updateManga(
      manga.copyWith(
        userStatus: MangaListStatus.fromApiValue(status.status),
        userScore: status.score,
        userChaptersRead: status.progress,
        userVolumesRead: status.volumeProgress ?? manga.userVolumesRead,
        updatedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Removes an anime from the user's list on MAL and from the cache.
  Future<void> removeAnime(Anime anime) async {
    await repository.deleteAnimeListStatus(anime.id);
    await store.deleteAnime(anime.id);
    notifyListeners();
  }

  /// Removes a manga from the user's list on MAL and from the cache.
  Future<void> removeManga(Manga manga) async {
    await repository.deleteMangaListStatus(manga.id);
    await store.deleteManga(manga.id);
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
    final GlobalControllerScope? scope = context
        .dependOnInheritedWidgetOfExactType<GlobalControllerScope>();
    assert(scope != null, "No GlobalControllerScope found in context");
    return scope!.notifier!;
  }
}
