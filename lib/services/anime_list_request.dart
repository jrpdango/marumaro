import 'package:flutter/foundation.dart';
import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/globals.dart';
import 'package:miru/interfaces/mal_request.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/models/season.dart';
import 'package:miru/objectbox.g.dart';

import 'package:miru/services/base_request.dart';

class AnimeListRequest implements MalRequest {
  final int? limit;
  final int? offset;
  final String? username;
  final String? status;
  final String? sort;
  final String? fields;
  Uri? uri;

  final animeBox = Globals.store?.box<Anime>();

  AnimeListRequest({
    this.status,
    this.sort,
    this.limit,
    this.offset,
    this.username,
    this.uri,
    this.fields,
  });

  /// Sets parameters to the URI.
  ///
  Uri setParams(Uri uri) {
    Map<String, dynamic> parameters = {
      if (status != null) 'status': status!,
      if (offset != null) 'offset': offset!.toString(),
      'fields': fields,
      'sort': sort,
      'limit': limit.toString()
    };
    return uri.replace(queryParameters: parameters);
  }

  /// Sorts a [Map] by status.
  ///
  Map<String, dynamic> sortMap(Map rawMap) {
    List<String> statusTypes = [
      'watching',
      'completed',
      'plan_to_watch',
      'on_hold',
      'dropped',
    ];
    // Map with completely-detailed Anime for storage
    Map<String, dynamic> animeMap = <String, dynamic>{};

    for (String statusType in statusTypes) {
      animeMap[statusType] = <Anime>[];
    }
    for (Map element in rawMap['data']) {
      Query<Anime>? animeQuery =
          animeBox?.query(Anime_.animeId.equals(element['node']['id'])).build();
      Anime? queriedAnime = animeQuery?.findFirst();
      // If the Anime exists in the database, no need to create a new one
      if (queriedAnime != null) {
        continue;
      }
      animeQuery?.close();
      Anime currentAnime = Anime(
        animeId: element['node']['id'],
        title: element['node']['title'],
        pictureMedium: element['node']['main_picture'] != null
            ? Uri.parse(element['node']['main_picture']['medium'])
            : null,
        pictureLarge: element['node']['main_picture'] != null
            ? Uri.parse(element['node']['main_picture']['large'])
            : null,
        totalEpisodes: element['node']['num_episodes'],
        season: Season(
          name: element['node']['start_season']?['season'],
          year: element['node']['start_season']?['year'],
        ),
        airingStatus: _getAiringStatus(element['node']['status']),
        numListUsers: element['node']['num_list_users'],
        numScoringUsers: element['node']['num_scoring_users'],
        // This can either give a double, int, or null, so we convert it to double
        meanScore: element['node']['mean']?.toDouble(),
        rank: element['node']['rank'],
        popularity: element['node']['popularity'],
        // userListStatus: UserListStatus(
        //   status: _getAnimeListType(element['list_status']['status']),
        //   currentProgress: element['list_status']['num_episodes_watched'],
        //   score: element['list_status']['score'],
        // ),
        userCurrentStatus: _getAnimeListType(element['list_status']['status']),
        userCurrentProgress: element['list_status']['num_episodes_watched'],
        userCurrentScore: element['list_status']['score'],
      );
      animeMap[element['list_status']['status']]?.add(currentAnime);
    }
    animeMap['paging'] = rawMap['paging'];
    return animeMap;
  }

  /// Converts a String [rawStatus] to an [AnimeAiringStatus].
  ///
  AnimeAiringStatus? _getAiringStatus(String rawStatus) {
    switch (rawStatus) {
      case 'finished_airing':
        return AnimeAiringStatus.finishedAiring;
      case 'currently_airing':
        return AnimeAiringStatus.currentlyAiring;
      case 'not_yet_aired':
        return AnimeAiringStatus.notYetAired;
      default:
        return null;
    }
  }

  AnimeListType _getAnimeListType(String rawType) {
    switch (rawType) {
      case 'watching':
        return AnimeListType.watching;
      case 'plan_to_watch':
        return AnimeListType.planToWatch;
      case 'completed':
        return AnimeListType.completed;
      case 'on_hold':
        return AnimeListType.onHold;
      case 'dropped':
        return AnimeListType.dropped;
      default:
        return AnimeListType.watching;
    }
  }

  // TODO: Add comments
  Map<AnimeListType, List<Anime>> _createCompleteMap(
      Map<String, dynamic> rawMap) {
    Map<AnimeListType, List<Anime>> animeMap = {};
    animeMap[AnimeListType.watching] = rawMap['watching'];
    animeMap[AnimeListType.completed] = rawMap['completed'];
    animeMap[AnimeListType.planToWatch] = rawMap['plan_to_watch'];
    animeMap[AnimeListType.onHold] = rawMap['on_hold'];
    animeMap[AnimeListType.dropped] = rawMap['dropped'];
    return animeMap;
  }

  @override
  Future<Map<AnimeListType, List<Anime>>> send() async {
    animeBox?.removeAll();
    if (uri == null) {
      uri = Uri(
          scheme: 'https',
          host: 'api.myanimelist.net',
          path: 'v2/users/$username/animelist');
      uri = setParams(uri!);
    }
    debugPrint('Made it to anime list request');
    Map<String, dynamic> response = await BaseRequest(
      uri: uri!,
      httpRequestType: MiruHttpRequestType.get,
    ).send();
    debugPrint('List retrieved successfully!');

    /// If there are pages after the initially-retrieved list, make extra
    /// requests to get those until there no longer are any extra pages.
    try {
      response = sortMap(response);
      while (response['paging']['next'] != null) {
        Map<String, dynamic> newUnsortedResponse = await BaseRequest(
          uri: Uri.parse(response['paging']['next']),
          httpRequestType: MiruHttpRequestType.get,
        ).send();
        debugPrint('List retrieved successfully!');
        newUnsortedResponse = sortMap(newUnsortedResponse);

        for (String item in newUnsortedResponse.keys) {
          if (item != 'paging' && item != 'status_code') {
            response[item].addAll(newUnsortedResponse[item]);
          }
        }

        response['paging']['next'] = newUnsortedResponse['paging']['next'];
      }
      Map<AnimeListType, List<Anime>> fullMap = _createCompleteMap(response);
      fullMap.forEach((key, value) {
        animeBox?.putMany(value);
      });
      return fullMap;
    } catch (e) {
      debugPrint(e.toString());
    }

    return {};
  }
}
