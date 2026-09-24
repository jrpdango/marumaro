import 'package:miru/core/models/anime.dart';
import 'package:miru/core/models/anime_details.dart';
import 'package:miru/core/models/enums.dart';
import 'package:miru/core/models/manga.dart';
import 'package:miru/core/models/manga_details.dart';
import 'package:miru/core/models/page.dart';
import 'package:miru/core/models/user.dart';
import 'package:miru/core/services/mal_api_client.dart';

/// Typed access to the MAL API endpoints used by the app.
class MalRepository {
  MalRepository({required this._api});

  static const int pageSize = 1000;
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
    final List<dynamic> data = (page["data"] as List<dynamic>?) ?? const [];
    final List<Anime> items = data
        .map(
          (dynamic entry) =>
              Anime.fromListStatusJson((entry as Map).cast<String, dynamic>()),
        )
        .toList(growable: false);
    final Map<String, dynamic>? paging =
        (page["paging"] as Map?)?.cast<String, dynamic>();
    return PageResult<Anime>(
      items: items,
      hasMore: items.isNotEmpty && paging != null && paging["next"] != null,
    );
  }

  Future<AnimeDetails> fetchAnimeDetails(int animeId) async {
    final Map<String, dynamic> json = await _api.get(
      "v2/anime/$animeId",
      query: <String, String>{"fields": _detailsFields},
    );
    return AnimeDetails.fromJson(json);
  }

  Future<User> fetchCurrentUser() async {
    return User.fromJson(await _api.get("v2/users/@me"));
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
    final List<dynamic> data = (page["data"] as List<dynamic>?) ?? const [];
    final List<Manga> items = data
        .map(
          (dynamic entry) =>
              Manga.fromListStatusJson((entry as Map).cast<String, dynamic>()),
        )
        .toList(growable: false);
    final Map<String, dynamic>? paging =
        (page["paging"] as Map?)?.cast<String, dynamic>();
    return PageResult<Manga>(
      items: items,
      hasMore: items.isNotEmpty && paging != null && paging["next"] != null,
    );
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
}
