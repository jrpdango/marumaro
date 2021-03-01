import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AnimeListRequest {
  String username;
  String status;
  String sort;
  String limit;
  String offset;

  AnimeListRequest(
      {this.status = "",
      this.sort = "",
      this.limit = "",
      this.offset = "",
      this.username = "@me"});

  Future<Map> createRequest(MALClient client) async {
    try {
      String url =
          "https://api.myanimelist.net/v2/users/${this.username}/animelist?fields=list_status" +
              this.status +
              this.sort +
              this.limit +
              this.offset;
      Response response = await client.userClient.get(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("List retrieved successfully!");
        respMap["status_code"] = 200;
      } else {
        print(
            "List retrieval request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return Map();
    }
  }
}
