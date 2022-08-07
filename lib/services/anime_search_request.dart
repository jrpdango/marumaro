import 'package:miru/models/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AnimeSearchRequest {
  final String query;
  final int limit;
  final int? offset;
  final String? fields;

  AnimeSearchRequest({
    required this.query,
    this.limit = 100,
    this.offset,
    this.fields,
  });

  Uri setParams(Uri url) {
    Map<String, dynamic> parameters = {
      "q": query,
      if (fields != null) "fields": fields!,
      if (offset != null) "offset": offset!.toString(),
      "limit": limit.toString()
    };
    url = url.replace(queryParameters: parameters);
    return url;
  }

  Future<Map> createRequest(MALClient client) async {
    try {
      Uri url =
          Uri(scheme: "https", host: "api.myanimelist.net", path: "v2/anime");
      url = setParams(url);
      Response response = await client.userClient.get(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("Anime searched successfully!");
        respMap["status_code"] = 200;
      } else {
        print(
            "Anime search request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return Map();
    }
  }
}
