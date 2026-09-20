import 'package:miru/models/anime.dart';
import 'package:miru/models/anime_details.dart';
import 'package:miru/models/enums.dart';
import 'package:miru/models/user.dart';
import 'package:miru/services/mal_api_client.dart';

/// Typed access to the MAL API endpoints used by the app.
class MalRepository {
  MalRepository({required MalApiClient api}) : _api = api;

  static const int _pageSize = 100;
  static const String _listFields =
      "list_status,num_episodes,mean,status,rank,popularity,source,studios,"
      "rating,average_episode_duration,alternative_titles,synopsis,"
      "start_date,end_date,genres";
  static const String _detailsFields =
      "title,main_picture,alternative_titles,start_date,end_date,synopsis,"
      "mean,rank,popularity,num_list_users,num_scoring_users,media_type,status,"
      "genres,my_list_status,num_episodes,start_season,source,"
      "average_episode_duration,rating";

  final MalApiClient _api;

  /// Fetches the entire anime list, following pagination.
  Future<List<Anime>> fetchAnimeList() async {
    final List<Anime> anime = <Anime>[];
    int offset = 0;
    while (true) {
      final Map<String, dynamic> page = await _api.get(
        "v2/users/@me/animelist",
        query: <String, String>{
          "fields": _listFields,
          "limit": "$_pageSize",
          "offset": "$offset",
        },
      );
      final List<dynamic> data = (page["data"] as List<dynamic>?) ?? const [];
      anime.addAll(
        data.map(
          (dynamic entry) =>
              Anime.fromListStatusJson((entry as Map).cast<String, dynamic>()),
        ),
      );
      final Map<String, dynamic>? paging =
          (page["paging"] as Map?)?.cast<String, dynamic>();
      if (data.isEmpty || paging == null || paging["next"] == null) break;
      offset += data.length;
    }
    return anime;
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
}
