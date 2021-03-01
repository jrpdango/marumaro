import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AnimeSearchRequest {
  String query;
  String limit;
  String offset;
  String fields;

  AnimeSearchRequest(
      {this.query, this.limit = "", this.offset = "", this.fields = ""});

  Future<Map> createRequest(MALClient client) async {
    try {
      String url = "https://api.myanimelist.net/v2/anime?q=${this.query}" +
          this.limit +
          this.offset +
          this.fields;
      Response response = await client.userClient.get(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("Searched successfully!");
        respMap["status_code"] = 200;
      } else {
        print(
            "Search request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return Map();
    }
  }
}
