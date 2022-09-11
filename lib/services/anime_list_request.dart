import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/models/anime.dart';

import 'package:miru/services/base_request.dart';

class AnimeListRequest {
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
    animeMap['all'] = <Anime>[].obs;
    for (Map element in rawMap['data']) {
      Anime currentAnime = Anime(
        id: element['node']['id'],
        title: element['node']['title'],
        picture: Uri.parse(element['node']['main_picture']['medium']),
        totalEpisodes: element['node']['num_episodes'],
        showStatus: element['node']['status'],
        userStatus: element['list_status']['status'],
        userEpisodesWatched: element['list_status']['num_episodes_watched'],
        userScore: element['list_status']['score'],
      );
      animeMap[element['list_status']['status']]?.add(currentAnime);
      animeMap['all']?.add(currentAnime);
    }
    animeMap['paging'] = rawMap['paging'];
    return animeMap;
  }

  /// Sends a request to update anime list to MAL servers through API.
  ///
  Future<Map<String, dynamic>> send() async {
    if (uri == null) {
      uri = Uri(
          scheme: 'https',
          host: 'api.myanimelist.net',
          path: 'v2/users/$username/animelist');
      uri = setParams(uri!);
    }
    Map<String, dynamic> unsortedResponse = await BaseRequest(
      uri: uri!,
      httpRequestType: MiruHttpRequestType.get,
    ).send();
    debugPrint('List retrieved successfully!');
    return sortMap(unsortedResponse);
  }
}
