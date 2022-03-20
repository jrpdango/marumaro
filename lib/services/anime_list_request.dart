import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

class AnimeListRequest {
  final int limit;
  final int? offset;
  final String username;
  final String? status;
  final String sort;
  final String fields;
  Uri? url;

  AnimeListRequest(
      {this.status,
      this.sort = "list_updated_at",
      this.limit = 100,
      this.offset,
      this.username = "@me",
      this.url,
      this.fields =
          "list_status,num_episodes,mean,status,rank,popularity,source,studios,rating,average_episode_duration,alternative_titles,synopsis,start_date,end_date,genres"});

  Uri setParams(Uri url) {
    Map<String, dynamic> parameters = {
      if (status != null) "status": status!,
      if (offset != null) "offset": offset!.toString(),
      "fields": fields,
      "sort": sort,
      "limit": limit.toString()
    };
    url = url.replace(queryParameters: parameters);
    return url;

    // this.status = this.status == null ? "" : "&status=${this.status}";
    // this.sort = this.sort == null ? "" : "&sort=${this.sort}";
    // this.limit = this.limit == null ? "" : "&limit=${this.limit}";
    // this.offset = this.offset == null ? "" : "&offset=${this.offset}";
  }

  /// Deprecated function, saving lists locally may be a future feature.
  ///
  // static Future<File> writeToFile(Map listInfo) async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   File file = File("${directory.path}/miruList.json").existsSync()
  //       ? File("${directory.path}/miruList.json")
  //       : await File("${directory.path}/miruList.json").create();
  //   String data = json.encode(listInfo);
  //   if (file.readAsStringSync().isNotEmpty) {
  //     await File("${directory.path}/miruList.json").delete();
  //     file = await File("${directory.path}/miruList.json").create();
  //   }
  //   return await file.writeAsString(data);
  // }

  /// Sort a [Map] by status.
  ///
  Map sortMap(Map rawMap) {
    Map animeMap = Map();
    animeMap["watching"] = [];
    animeMap["completed"] = [];
    animeMap["plan_to_watch"] = [];
    animeMap["on_hold"] = [];
    animeMap["dropped"] = [];
    for (Map element in rawMap["data"]) {
      animeMap[element["list_status"]["status"]].add(element);
    }
    animeMap["paging"] = rawMap["paging"];
    return animeMap;
  }

  /// Sends a request to update anime list to MAL servers through API.
  ///
  Future<Map> createRequest(MALClient client) async {
    try {
      if (url == null) {
        url = Uri(
            scheme: "https",
            host: "api.myanimelist.net",
            path: "v2/users/${this.username}/animelist");
        url = setParams(url!);
      }
      // url =
      //     "https://api.myanimelist.net/v2/users/${this.username}/animelist?fields=list_status,num_episodes,mean,status,rank,popularity,source,studios,rating,average_episode_duration,alternative_titles,synopsis,start_date,end_date,genres" +
      //         this.status! +
      //         this.sort +
      //         this.limit +
      //         this.offset;
      Response response = await client.userClient.get(url!,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("List retrieved successfully!");
        respMap = sortMap(respMap);
        respMap["status_code"] = 200;
      } else {
        print(
            "List retrieval request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. Anime_List_Request $exception");
      return Map();
    }
  }
}
