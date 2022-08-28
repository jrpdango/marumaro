import 'package:get/get.dart';
// import 'package:miru/utils/global_controller.dart';
import 'package:http/http.dart' as http;
import 'package:miru/globals.dart';
import 'dart:convert';

import 'package:miru/utils/mal_client.dart';

class UserDataRequest {
  final String mode;
  final bool isFullImage;

  const UserDataRequest({
    required this.mode,
    this.isFullImage = false,
  });

  Future<Map<String, dynamic>> createRequest() async {
    // final MALClient client = Get.find<GlobalController>().client;
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
        path:
            "v4/users/${Globals.client.username}/${isFullImage ? 'full' : ''}",
      );
    }

    // MAL URL: 'https://api.myanimelist.net/v2/users/@me';
    // JIKAN URL: https://api.jikan.moe/v4/users/{username}/full
    try {
      http.Response response = await Globals.client.userClient.get(uri,
          headers: {
            "Authorization": "Bearer ${Globals.client.token.accessToken}"
          });
      Map<String, dynamic> respMap = <String, dynamic>{};
      if (response.statusCode == 200) {
        //respMap gives a json response of keys {id, name, birthday, location, joined_at}
        respMap = json.decode(response.body);
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return {"status_code": "invalid_code"};
    }
  }
}
