import 'package:miru/models/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class UserDataRequest {
  final String mode;

  const UserDataRequest({required this.mode});

  Future<Map> createRequest(MALClient client) async {
    Uri url;

    if (mode == 'MAL') {
      url = Uri(
        scheme: "https",
        host: "api.myanimelist.net",
        path: "v2/users/@me",
      );
    } else {
      url = Uri(
        scheme: "https",
        host: "api.myanimelist.net",
        path: "v2/users/@me",
      );
    }

    // MAL URL: 'https://api.myanimelist.net/v2/users/@me';
    // JIKAN URL: https://api.jikan.moe/v4/users/{username}/full
    try {
      Response response = await client.userClient.get(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      if (response.statusCode == 200) {
        //respMap gives a json response of keys {id, name, birthday, location, joined_at}
        respMap = json.decode(response.body);
        respMap["status_code"] = 200;
      } else {
        respMap["status_code"] = response.statusCode;
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return {"status_code": "invalid_code"};
    }
  }
}
