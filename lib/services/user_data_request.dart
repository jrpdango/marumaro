import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class UserDataRequest {
  static void createRequest(MALClient client) async {
    String url = 'https://api.myanimelist.net/v2/users/@me';
    Response response = await client.userClient.get(url,
        headers: {"Authorization": "Bearer ${client.token.accessToken}"});
    Map respMap = json.decode(response.body);
    //respMap gives a json response of keys {id, name, birthday, location, joined_at}
    print("User name is ${respMap["name"]}");
    print(respMap);
  }
}
