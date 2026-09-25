import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tamarun/core/core.dart';

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
        },
        "ranking": <String, dynamic>{"rank": 1},
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
    expect(page.items.single.rank, 1);
    expect(page.hasMore, isTrue);
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
