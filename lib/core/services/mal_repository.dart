import 'package:marumaro/core/models/anime.dart';
import 'package:marumaro/core/models/anime_details.dart';
import 'package:marumaro/core/models/enums.dart';
import 'package:marumaro/core/models/manga.dart';
import 'package:marumaro/core/models/manga_details.dart';
import 'package:marumaro/core/models/page.dart';
import 'package:marumaro/core/models/user.dart';
import 'package:marumaro/core/services/mal_api_client.dart';

/// Typed access to the MAL API endpoints used by the app.
class MalRepository {
  MalRepository({required this._api});

  static const int pageSize = 1000;
  static const int browsePageSize = 100;

  /// The maximum page size accepted by the seasonal endpoint.
  static const int _seasonMaxPageSize = 500;
  static const String _listFields = "list_status,num_episodes,status";
  static const String _animeListStatusFields =
      "status,score,num_episodes_watched,start_date,finish_date,is_rewatching,"
      "priority,num_times_rewatched,rewatch_value,tags,comments";
  static const String _mangaListStatusFields =
      "status,score,num_chapters_read,num_volumes_read,start_date,finish_date,"
      "is_rereading,priority,num_times_reread,reread_value,tags,comments";
  static const String _detailsFields =
      "title,main_picture,alternative_titles,start_date,end_date,synopsis,"
      "background,mean,rank,popularity,num_list_users,num_scoring_users,"
      "media_type,status,genres,my_list_status{$_animeListStatusFields},"
      "num_episodes,start_season,source,average_episode_duration,rating,"
      "studios,broadcast";
  static const String _mangaListFields =
      "list_status,num_chapters,num_volumes,status";
  static const String _mangaDetailsFields =
      "title,main_picture,alternative_titles,start_date,end_date,synopsis,"
      "background,mean,rank,popularity,num_list_users,num_scoring_users,"
      "media_type,status,genres,my_list_status{$_mangaListStatusFields},"
      "num_chapters,num_volumes,source,authors";
  static const String _animeBrowseFields =
      "id,title,main_picture,num_episodes,status,mean,media_type,num_list_users";
  static const String _mangaBrowseFields =
      "id,title,main_picture,num_chapters,num_volumes,status,mean,media_type";

  final MalApiClient _api;

  /// Fetches one page of the user's anime list, optionally for a single status.
  Future<PageResult<Anime>> fetchAnimeListPage({
    required int offset,
    int limit = pageSize,
    AnimeListStatus? status,
  }) async {
    final Map<String, dynamic> page = await _api.get(
      "v2/users/@me/animelist",
      query: <String, String>{
        "fields": _listFields,
        "limit": "$limit",
        "offset": "$offset",
        "sort": "list_updated_at",
        if (status != null) "status": status.apiValue,
      },
    );
    return _parsePage(page, Anime.fromListStatusJson);
  }

  Future<AnimeDetails> fetchAnimeDetails(int animeId) async {
    final Map<String, dynamic> json = await _api.get(
      "v2/anime/$animeId",
      query: <String, String>{"fields": _detailsFields},
    );
    return AnimeDetails.fromJson(json);
  }

  /// Fields on the user endpoint that carry lifetime list aggregates.
  static const String _userStatisticsFields =
      "anime_statistics,manga_statistics";

  Future<User> fetchCurrentUser() async {
    return User.fromJson(
      await _api.get(
        "v2/users/@me",
        query: <String, String>{"fields": _userStatisticsFields},
      ),
    );
  }

  Future<void> updateListStatus({
    required int animeId,
    required AnimeListStatus status,
    required int score,
    required int episodesWatched,
  }) async {
    await _api.patch(
      "v2/anime/$animeId/my_list_status",
      body: <String, String>{
        "status": status.apiValue,
        "score": "$score",
        "num_watched_episodes": "$episodesWatched",
      },
    );
  }

  /// PATCHes an arbitrary set of anime list status fields.
  Future<void> updateAnimeUserListStatus({
    required int animeId,
    required Map<String, String> body,
  }) async {
    await _api.patch("v2/anime/$animeId/my_list_status", body: body);
  }

  /// Removes an anime from the user's list entirely.
  Future<void> deleteAnimeListStatus(int animeId) async {
    await _api.delete("v2/anime/$animeId/my_list_status");
  }

  /// Fetches one page of the user's manga list, optionally for a single status.
  Future<PageResult<Manga>> fetchMangaListPage({
    required int offset,
    int limit = pageSize,
    MangaListStatus? status,
  }) async {
    final Map<String, dynamic> page = await _api.get(
      "v2/users/@me/mangalist",
      query: <String, String>{
        "fields": _mangaListFields,
        "limit": "$limit",
        "offset": "$offset",
        "sort": "list_updated_at",
        if (status != null) "status": status.apiValue,
      },
    );
    return _parsePage(page, Manga.fromListStatusJson);
  }

  Future<MangaDetails> fetchMangaDetails(int mangaId) async {
    final Map<String, dynamic> json = await _api.get(
      "v2/manga/$mangaId",
      query: <String, String>{"fields": _mangaDetailsFields},
    );
    return MangaDetails.fromJson(json);
  }

  Future<void> updateMangaListStatus({
    required int mangaId,
    required MangaListStatus status,
    required int score,
    required int chaptersRead,
    required int volumesRead,
  }) async {
    await _api.patch(
      "v2/manga/$mangaId/my_list_status",
      body: <String, String>{
        "status": status.apiValue,
        "score": "$score",
        "num_chapters_read": "$chaptersRead",
        "num_volumes_read": "$volumesRead",
      },
    );
  }

  /// PATCHes an arbitrary set of manga list status fields.
  Future<void> updateMangaUserListStatus({
    required int mangaId,
    required Map<String, String> body,
  }) async {
    await _api.patch("v2/manga/$mangaId/my_list_status", body: body);
  }

  /// Removes a manga from the user's list entirely.
  Future<void> deleteMangaListStatus(int mangaId) async {
    await _api.delete("v2/manga/$mangaId/my_list_status");
  }

  /// Fetches one page of a season's anime, ordered by [sort].
  Future<PageResult<Anime>> fetchSeasonalAnime({
    required SeasonRef season,
    AnimeSeasonSort sort = AnimeSeasonSort.score,
    required int offset,
    int limit = browsePageSize,
  }) async {
    final Map<String, dynamic> page = await _api.get(
      "v2/anime/season/${season.year}/${season.season.apiValue}",
      query: <String, String>{
        "fields": _animeBrowseFields,
        "limit": "$limit",
        "offset": "$offset",
        "sort": sort.apiValue,
      },
    );
    return _parsePage(page, Anime.fromNodeJson);
  }

  /// Fetches an entire season's anime, sorted by community score descending.
  ///
  /// The MAL seasonal endpoint ignores `sort=anime_score`, so the season is
  /// fetched in full (paged with the working popularity sort for stable
  /// offsets) and re-sorted in-app. Entries without a score sort last.
  Future<List<Anime>> fetchSeasonalAnimeByScore(SeasonRef season) async {
    final List<Anime> all = <Anime>[];
    int offset = 0;
    while (true) {
      final PageResult<Anime> page = await fetchSeasonalAnime(
        season: season,
        sort: AnimeSeasonSort.popularity,
        offset: offset,
        limit: _seasonMaxPageSize,
      );
      all.addAll(page.items);
      if (!page.hasMore || page.items.isEmpty) break;
      offset += page.items.length;
    }
    all.sort((Anime a, Anime b) {
      final double scoreA = a.meanScore ?? double.negativeInfinity;
      final double scoreB = b.meanScore ?? double.negativeInfinity;
      final int byScore = scoreB.compareTo(scoreA);
      return byScore != 0 ? byScore : a.id.compareTo(b.id);
    });
    return all;
  }

  /// Fetches one page of an anime ranking.
  Future<PageResult<Anime>> fetchAnimeRanking({
    required AnimeRankingType type,
    required int offset,
    int limit = browsePageSize,
  }) async {
    final Map<String, dynamic> page = await _api.get(
      "v2/anime/ranking",
      query: <String, String>{
        "fields": _animeBrowseFields,
        "ranking_type": type.apiValue,
        "limit": "$limit",
        "offset": "$offset",
      },
    );
    return _parsePage(page, Anime.fromNodeJson);
  }

  /// Fetches one page of a manga ranking.
  Future<PageResult<Manga>> fetchMangaRanking({
    required MangaRankingType type,
    required int offset,
    int limit = browsePageSize,
  }) async {
    final Map<String, dynamic> page = await _api.get(
      "v2/manga/ranking",
      query: <String, String>{
        "fields": _mangaBrowseFields,
        "ranking_type": type.apiValue,
        "limit": "$limit",
        "offset": "$offset",
      },
    );
    return _parsePage(page, Manga.fromNodeJson);
  }

  /// Fetches one page of anime suggested for the authorized user.
  Future<PageResult<Anime>> fetchSuggestedAnime({
    required int offset,
    int limit = browsePageSize,
  }) async {
    final Map<String, dynamic> page = await _api.get(
      "v2/anime/suggestions",
      query: <String, String>{
        "fields": _animeBrowseFields,
        "limit": "$limit",
        "offset": "$offset",
      },
    );
    return _parsePage(page, Anime.fromNodeJson);
  }

  /// Parses a paged list response into [PageResult], using [fromJson] to map
  /// each entry.
  PageResult<T> _parsePage<T>(
    Map<String, dynamic> page,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final List<dynamic> data = (page["data"] as List<dynamic>?) ?? const [];
    final List<T> items = data
        .map((dynamic entry) => fromJson((entry as Map).cast<String, dynamic>()))
        .toList(growable: false);
    final Map<String, dynamic>? paging =
        (page["paging"] as Map?)?.cast<String, dynamic>();
    return PageResult<T>(
      items: items,
      hasMore: items.isNotEmpty && paging != null && paging["next"] != null,
    );
  }
}
