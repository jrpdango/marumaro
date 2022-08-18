import 'package:get/get.dart';
import 'package:miru/services/global_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDataRequest {
  final String mode;
  final bool isFull;

  const UserDataRequest({
    required this.mode,
    this.isFull = false,
  });

  Future<Map> createRequest() async {
    final _client = Get.put(GlobalController()).client;
    Uri uri;

    if (mode == 'MAL') {
      uri = Uri(
        scheme: "https",
        host: "api.myanimelist.net",
        path: "v2/users/@me",
      );
    } else {
      uri = Uri(
        scheme: "https",
        host: "api.jikan.moe",
        path: "v4/users/${_client.username}/${isFull ? 'full' : ''}",
      );
    }

    // MAL URL: 'https://api.myanimelist.net/v2/users/@me';
    // JIKAN URL: https://api.jikan.moe/v4/users/{username}/full
    try {
      http.Response response = await _client.userClient.get(uri,
          headers: {"Authorization": "Bearer ${_client.token.accessToken}"});
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
