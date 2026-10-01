import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:marumaro/core/core.dart';

/// A repository backed by a mock client that records requests and returns
/// [body] with the given [statusCode].
({MalRepository repository, List<http.Request> requests}) buildRepository(
  String body, {
  int statusCode = 200,
}) {
  final List<http.Request> requests = <http.Request>[];
  final MockClient client = MockClient((http.Request request) async {
    requests.add(request);
    return http.Response(
      body,
      statusCode,
      headers: <String, String>{"content-type": "application/json"},
    );
  });
  return (
    repository: MalRepository(
      api: MalApiClient(
        httpClient: client,
        accessTokenProvider: () => "token",
      ),
    ),
    requests: requests,
  );
}

/// A repository whose mock client returns each entry of [bodies] for the
/// successive requests it receives, recording every request.
({MalRepository repository, List<http.Request> requests})
buildSequencedRepository(List<String> bodies) {
  final List<http.Request> requests = <http.Request>[];
  int index = 0;
  final MockClient client = MockClient((http.Request request) async {
    requests.add(request);
    final String body = bodies[index < bodies.length ? index : bodies.length - 1];
    index++;
    return http.Response(
      body,
      200,
      headers: <String, String>{"content-type": "application/json"},
    );
  });
  return (
    repository: MalRepository(
      api: MalApiClient(
        httpClient: client,
        accessTokenProvider: () => "token",
      ),
    ),
    requests: requests,
  );
}

Map<String, dynamic> animeNode(
  int id,
  String title,
  double? mean, {
  int? members,
}) {
  return <String, dynamic>{
    "id": id,
    "title": title,
    "num_episodes": 12,
    "status": "finished_airing",
    "media_type": "tv",
    "main_picture": <String, dynamic>{"medium": "https://example.com/$id.jpg"},
    "mean": ?mean,
    "num_list_users": ?members,
  };
}

String seasonPageJson(
  List<Map<String, dynamic>> nodes, {
  bool withNext = false,
}) {
  return jsonEncode(<String, dynamic>{
    "data": nodes
        .map(
          (Map<String, dynamic> node) => <String, dynamic>{"node": node},
        )
        .toList(),
    if (withNext)
      "paging": <String, dynamic>{"next": "https://example.com/next"},
  });
}

String animePageJson({bool withNext = false}) {
  return jsonEncode(<String, dynamic>{
    "data": <dynamic>[
      <String, dynamic>{
        "node": <String, dynamic>{
          "id": 1,
          "title": "Anime One",
          "main_picture": <String, dynamic>{
            "medium": "https://example.com/1.jpg",
          },
          "num_episodes": 12,
          "status": "currently_airing",
          "mean": 8.25,
          "media_type": "tv",
          "num_list_users": 183703,
        },
      },
    ],
    if (withNext)
      "paging": <String, dynamic>{"next": "https://example.com/next"},
  });
}

String mangaPageJson() {
  return jsonEncode(<String, dynamic>{
    "data": <dynamic>[
      <String, dynamic>{
        "node": <String, dynamic>{
          "id": 5,
          "title": "Manga One",
          "main_picture": <String, dynamic>{
            "medium": "https://example.com/5.jpg",
          },
          "num_chapters": 40,
          "num_volumes": 8,
          "status": "currently_publishing",
          "mean": 9.1,
          "media_type": "manga",
        },
        "ranking": <String, dynamic>{"rank": 2},
      },
    ],
  });
}

void main() {
  test("fetchSeasonalAnime builds the season path and parses entries", () async {
    final result = buildRepository(animePageJson(withNext: true));

    final PageResult<Anime> page = await result.repository.fetchSeasonalAnime(
      season: const SeasonRef(year: 2023, season: MediaSeason.summer),
      sort: AnimeSeasonSort.popularity,
      offset: 0,
      limit: 25,
    );

    final http.Request request = result.requests.single;
    expect(request.url.path, "/v2/anime/season/2023/summer");
    expect(request.url.queryParameters["sort"], "anime_num_list_users");
    expect(request.url.queryParameters["limit"], "25");
    expect(request.url.queryParameters["offset"], "0");
    expect(request.headers["Authorization"], "Bearer token");

    expect(page.items, hasLength(1));
    expect(page.items.single.title, "Anime One");
    expect(page.items.single.inList, isFalse);
    expect(page.items.single.members, 183703);
    expect(page.hasMore, isTrue);
  });

  test("fetchSeasonalAnime requests and parses member counts", () async {
    final result = buildRepository(
      seasonPageJson(<Map<String, dynamic>>[
        animeNode(10, "First", 8.0, members: 183703),
        animeNode(11, "Second", 7.0, members: 42),
      ]),
    );

    final PageResult<Anime> page = await result.repository.fetchSeasonalAnime(
      season: const SeasonRef(year: 2023, season: MediaSeason.summer),
      sort: AnimeSeasonSort.popularity,
      offset: 0,
    );

    expect(
      result.requests.single.url.queryParameters["fields"],
      contains("num_list_users"),
    );
    expect(
      page.items.map((Anime anime) => anime.members).toList(),
      <int>[183703, 42],
    );
  });

  test("fetchSeasonalAnimeByScore pages the season and sorts by mean", () async {
    final result = buildSequencedRepository(<String>[
      seasonPageJson(<Map<String, dynamic>>[
        animeNode(1, "Low", 7.5),
        animeNode(5, "High A", 9.1),
        animeNode(2, "High B", 9.1),
      ], withNext: true),
      seasonPageJson(<Map<String, dynamic>>[
        animeNode(3, "Mid", 8.0),
        animeNode(4, "Unscored", null),
      ]),
    ]);

    final List<Anime> sorted = await result.repository
        .fetchSeasonalAnimeByScore(
          const SeasonRef(year: 2023, season: MediaSeason.summer),
        );

    expect(result.requests, hasLength(2));
    expect(result.requests[0].url.path, "/v2/anime/season/2023/summer");
    expect(
      result.requests[0].url.queryParameters["sort"],
      "anime_num_list_users",
    );
    expect(result.requests[0].url.queryParameters["limit"], "500");
    expect(result.requests[0].url.queryParameters["offset"], "0");
    expect(result.requests[1].url.queryParameters["offset"], "3");

    expect(
      sorted.map((Anime anime) => anime.id).toList(),
      <int>[2, 5, 3, 1, 4],
    );
  });

  test("fetchAnimeRanking sends the ranking type", () async {
    final result = buildRepository(animePageJson());

    final PageResult<Anime> page = await result.repository.fetchAnimeRanking(
      type: AnimeRankingType.upcoming,
      offset: 100,
    );

    final http.Request request = result.requests.single;
    expect(request.url.path, "/v2/anime/ranking");
    expect(request.url.queryParameters["ranking_type"], "upcoming");
    expect(request.url.queryParameters["offset"], "100");
    expect(page.hasMore, isFalse);
  });

  test("fetchMangaRanking parses manga nodes", () async {
    final result = buildRepository(mangaPageJson());

    final PageResult<Manga> page = await result.repository.fetchMangaRanking(
      type: MangaRankingType.novels,
      offset: 0,
    );

    final http.Request request = result.requests.single;
    expect(request.url.path, "/v2/manga/ranking");
    expect(request.url.queryParameters["ranking_type"], "novels");
    expect(page.items.single.title, "Manga One");
    expect(page.items.single.totalVolumes, 8);
    expect(page.items.single.rank, 2);
  });

  test("fetchSuggestedAnime hits the suggestions endpoint", () async {
    final result = buildRepository(animePageJson());

    await result.repository.fetchSuggestedAnime(offset: 0, limit: 12);

    final http.Request request = result.requests.single;
    expect(request.url.path, "/v2/anime/suggestions");
    expect(request.url.queryParameters["limit"], "12");
  });

  test("fetchCurrentUser requests and parses lifetime statistics", () async {
    final result = buildRepository(
      jsonEncode(<String, dynamic>{
        "name": "tester",
        "picture": "https://example.com/p.jpg",
        "anime_statistics": <String, dynamic>{
          "num_items": 12,
          "num_episodes": 345,
          "num_times_rewatched": 4,
          "mean_score": 7.7,
        },
        "manga_statistics": <String, dynamic>{
          "num_items": 3,
          "num_chapters": 40,
          "num_volumes": 5,
          "mean_score": 8.1,
        },
      }),
    );

    final User user = await result.repository.fetchCurrentUser();

    expect(
      result.requests.single.url.queryParameters["fields"],
      contains("anime_statistics"),
    );
    expect(
      result.requests.single.url.queryParameters["fields"],
      contains("manga_statistics"),
    );
    expect(user.name, "tester");
    expect(user.animeStatistics?.items, 12);
    expect(user.animeStatistics?.episodes, 345);
    expect(user.animeStatistics?.timesRewatched, 4);
    expect(user.animeStatistics?.meanScore, 7.7);
    expect(user.mangaStatistics?.chapters, 40);
    expect(user.mangaStatistics?.volumes, 5);
  });

  test("an empty page reports no more results", () async {
    final result = buildRepository(
      jsonEncode(<String, dynamic>{"data": <dynamic>[]}),
    );

    final PageResult<Anime> page = await result.repository.fetchAnimeRanking(
      type: AnimeRankingType.all,
      offset: 0,
    );

    expect(page.items, isEmpty);
    expect(page.hasMore, isFalse);
  });
}
