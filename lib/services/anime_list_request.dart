import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:miru/enums/anime_airing_status.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/interfaces/mal_request.dart';
import 'package:miru/models/anime.dart';

import 'package:miru/services/base_request.dart';

class AnimeListRequest implements MalRequest {
  final int? limit;
  final int? offset;
  final String? username;
  final String? status;
  final String? sort;
  final String? fields;
  Uri? uri;

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
    Map<String, dynamic> animeMap = <String, dynamic>{};
    animeMap['watching'] = <Anime>[].obs;
    animeMap['completed'] = <Anime>[].obs;
    animeMap['plan_to_watch'] = <Anime>[].obs;
    animeMap['on_hold'] = <Anime>[].obs;
    animeMap['dropped'] = <Anime>[].obs;
    for (Map element in rawMap['data']) {
      Anime currentAnime = Anime(
        id: element['node']['id'],
        title: element['node']['title'],
        pictureMedium: Uri.parse(element['node']['main_picture']['medium']),
        pictureLarge: Uri.parse(element['node']['main_picture']['large']),
        totalEpisodes: element['node']['num_episodes'],
        airingStatus: _getAiringStatus(element['node']['status']),
        userStatus: element['list_status']['status'],
        userEpisodesWatched: element['list_status']['num_episodes_watched'],
        userScore: element['list_status']['score'],
      );
      animeMap[element['list_status']['status']]?.add(currentAnime);
    }
    animeMap['paging'] = rawMap['paging'];
    return animeMap;
  }

  /// Converts a String [rawStatus] to an [AnimeAiringStatus].
  ///
  AnimeAiringStatus _getAiringStatus(String rawStatus) {
    switch (rawStatus) {
      case 'finished_airing':
        return AnimeAiringStatus.finishedAiring;
      case 'currently_airing':
        return AnimeAiringStatus.currentlyAiring;
      case 'not_yet_aired':
        return AnimeAiringStatus.notYetAired;
      default:
        return AnimeAiringStatus.currentlyAiring;
    }
  }

  // TODO: Add comments
  Map<AnimeListType, RxList<Anime>> _createCompleteMap(
      Map<String, dynamic> rawMap) {
    Map<AnimeListType, RxList<Anime>> animeMap = {};
    animeMap[AnimeListType.watching] = rawMap['watching'];
    animeMap[AnimeListType.completed] = rawMap['completed'];
    animeMap[AnimeListType.planToWatch] = rawMap['plan_to_watch'];
    animeMap[AnimeListType.onHold] = rawMap['on_hold'];
    animeMap[AnimeListType.dropped] = rawMap['dropped'];
    return animeMap;
  }

  @override
  Future<Map<AnimeListType, RxList<Anime>>> send() async {
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
      return _createCompleteMap(response);
    } catch (e) {
      debugPrint(e.toString());
    }

    return {};
  }
}
