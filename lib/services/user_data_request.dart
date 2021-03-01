import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class UserDataRequest {
  static Future<Map> createRequest(MALClient client) async {
    String url = 'https://api.myanimelist.net/v2/users/@me';
    Response response = await client.userClient.get(url,
        headers: {"Authorization": "Bearer ${client.token.accessToken}"});
    Map respMap = Map();
    try {
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
      return Map();
    }
  }
}
