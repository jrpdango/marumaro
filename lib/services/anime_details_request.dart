import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AnimeDetailsRequest {
  String animeID;
  String fields;

  AnimeDetailsRequest({this.animeID, this.fields});

  void setParams() {
    this.fields = this.fields == null ? "" : "?fields=${this.fields}";
  }

  Future<Map> createRequest(MALClient client) async {
    this.setParams();
    try {
      String url =
          "https://api.myanimelist.net/v2/anime/${this.animeID}" + this.fields;
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
