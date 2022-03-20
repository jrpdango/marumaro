import 'package:miru/models/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AnimeDetailsRequest {
  final int animeID;
  final String? fields;

  AnimeDetailsRequest({required this.animeID, this.fields});

  Uri setParams(Uri url) {
    url = url.replace(queryParameters: {
      if (fields != null) "fields": fields!,
    });
    return url;
  }

  Future<Map> createRequest(MALClient client) async {
    try {
      Uri url = Uri(
        scheme: "https",
        host: "api.jikan.moe",
        path: "v4/anime/${this.animeID}",
      );
      url = setParams(url);
      //"https://api.myanimelist.net/v2/anime/${this.animeID}" + this.fields;
      Response response = await client.userClient.get(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("Anime details retrieved successfully!");
        respMap["status_code"] = 200;
      } else {
        print(
            "Anime details request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return Map();
    }
  }
}
