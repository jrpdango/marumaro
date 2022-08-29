import 'package:miru/globals.dart';
import 'package:miru/utils/mal_client.dart';
import 'package:http/http.dart';
import 'package:miru/models/token.dart';
import 'dart:convert';

class OAuthRequest {
  final String codeChallenge;
  // final _client = Globals.client;

  OAuthRequest({required this.codeChallenge});

  // TODO: Put this and other requests in a try-catch
  String createRequest(MALClient client) {
    String url =
        "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${MALClient.CLIENTID}&code_challenge=$codeChallenge";
    return url;
  }

  // TODO: Create a separate service for this and refresh

  Future<Token> refreshTokens() async {
    Uri url = Uri.parse("https://myanimelist.net/v1/oauth2/token");
    // String url = "https://myanimelist.net/v1/oauth2/token";
    Map<String, String> data = {
      "client_id": MALClient.CLIENTID,
      "grant_type": "refresh_token",
      "refresh_token": Globals.client.token.refreshToken
    };
    Response response = await Globals.client.userClient.post(url, body: data);
    Map? responseMap;
    Token refreshedToken;
    if (response.statusCode == 200) {
      responseMap = json.decode(response.body);
      refreshedToken = Token(
          accessToken: responseMap!["access_token"],
          refreshToken: responseMap["refresh_token"]);
    } else {
      refreshedToken =
          Token(accessToken: "invalid_token", refreshToken: "invalid_token");
    }
    print("Status Code for token refresh: ${response.statusCode}");
    print(responseMap);
    return refreshedToken;
  }
}
