import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:http/http.dart' as http;
import 'package:miru/services/global_controller.dart';
import 'dart:convert';

class AnimeListRequest {
  final _client = Get.put(GlobalController()).client;
  final int limit;
  final int? offset;
  final String username;
  final String? status;
  final String sort;
  final String fields;
  Uri? uri;

  AnimeListRequest(
      {this.status,
      this.sort = 'list_updated_at',
      this.limit = 100,
      this.offset,
      this.username = '@me',
      this.uri,
      this.fields =
          'list_status,num_episodes,mean,status,rank,popularity,source,studios,rating,average_episode_duration,alternative_titles,synopsis,start_date,end_date,genres'});

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

  /// Sort a [Map] by status.
  ///
  Map<String, dynamic> sortMap(Map rawMap) {
    Map<String, dynamic> animeMap = Map();
    animeMap['watching'] = <Anime>[].obs;
    animeMap['completed'] = <Anime>[].obs;
    animeMap['plan_to_watch'] = <Anime>[].obs;
    animeMap['on_hold'] = <Anime>[].obs;
    animeMap['dropped'] = <Anime>[].obs;
    for (Map element in rawMap['data']) {
      animeMap[element['list_status']['status']]!.add(Anime(
        id: element['node']['id'],
        title: element['node']['title'],
        picture: Uri.parse(element['node']['main_picture']['medium']),
        totalEpisodes: element['node']['num_episodes'],
        showStatus: element['node']['status'],
        userStatus: element['list_status']['status'],
        userEpisodesWatched: element['list_status']['num_episodes_watched'],
        userScore: element['list_status']['score'],
      ));
    }
    animeMap['paging'] = rawMap['paging'];
    return animeMap;
  }

  /// Sends a request to update anime list to MAL servers through API.
  ///
  Future<Map<String, dynamic>> createRequest() async {
    try {
      if (uri == null) {
        uri = Uri(
            scheme: 'https',
            host: 'api.myanimelist.net',
            path: 'v2/users/${this.username}/animelist');
        uri = setParams(uri!);
      }
      http.Response response = await _client.userClient.get(uri!,
          headers: {'Authorization': 'Bearer ${_client.token.accessToken}'});
      Map<String, dynamic> respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print('List retrieved successfully!');
        respMap = sortMap(respMap);
      } else {
        print(
            'List retrieval request sent, but something went wrong. Status code: ${response.statusCode}');
      }
      return respMap;
    } catch (exception) {
      print('Oops! Something went wrong. Anime_List_Request $exception');
      return Map();
    }
  }
}
