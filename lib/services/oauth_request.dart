import 'package:miru/utils/mal_client.dart' show MALClient;
import 'package:http/http.dart' as http;
import 'package:miru/models/token.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:miru/utils/global_controller.dart';

class OAuthRequest {
  final String codeChallenge;
  final MALClient _client = Get.put(GlobalController()).client;

  OAuthRequest({required this.codeChallenge});

  String createRequest() {
    String url =
        "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${_client.clientId}&code_challenge=$codeChallenge";
    return url;
  }

  Future<Token> generateTokens(String code) async {
    Uri url = Uri.parse("https://myanimelist.net/v1/oauth2/token");
    // String url = "https://myanimelist.net/v1/oauth2/token";
    Map<String, String> data = {
      "client_id": _client.clientId,
      "code": code,
      "code_verifier": this.codeChallenge,
      "grant_type": "authorization_code"
    };
    http.Response response = await _client.userClient.post(url, body: data);
    Map responseMap = json.decode(response.body);
    Token token = Token(
        accessToken: responseMap["access_token"],
        refreshToken: responseMap["refresh_token"]);
    print("Status Code for token generation: ${response.statusCode}");
    print(responseMap);
    return token;
  }

  Future<Token> refreshTokens(Token token) async {
    Uri url = Uri.parse("https://myanimelist.net/v1/oauth2/token");
    // String url = "https://myanimelist.net/v1/oauth2/token";
    Map<String, String> data = {
      "client_id": _client.clientId,
      "grant_type": "refresh_token",
      "refresh_token": token.refreshToken
    };
    http.Response response = await _client.userClient.post(url, body: data);
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
