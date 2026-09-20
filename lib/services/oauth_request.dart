import 'package:miru/models/mal_client.dart';
import 'package:http/http.dart';
import 'package:miru/models/token.dart';
import 'dart:convert';

class OAuthRequest {
  final String codeVerifier;

  OAuthRequest({required this.codeVerifier});

  String createRequest(MALClient client) {
    // MyAnimeList only supports the `plain` challenge method, so the verifier
    // is sent directly as the challenge.
    String url =
        "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${MALClient.CLIENTID}&code_challenge=$codeVerifier&code_challenge_method=plain";
    return url;
  }

  Future<Token> generateTokens(MALClient client, String code) async {
    Uri url = Uri.parse("https://myanimelist.net/v1/oauth2/token");
    Map<String, String> data = {
      "client_id": MALClient.CLIENTID,
      "code": code,
      "code_verifier": this.codeVerifier,
      "grant_type": "authorization_code"
    };
    Response response = await client.userClient.post(url, body: data);
    Map responseMap = json.decode(response.body);
    Token token = Token(
        accessToken: responseMap["access_token"],
        refreshToken: responseMap["refresh_token"]);
    print("Status Code for token generation: ${response.statusCode}");
    return token;
  }

  Future<Token> refreshTokens(MALClient client, Token token) async {
    Uri url = Uri.parse("https://myanimelist.net/v1/oauth2/token");
    Map<String, String> data = {
      "client_id": MALClient.CLIENTID,
      "grant_type": "refresh_token",
      "refresh_token": token.refreshToken
    };
    Response response = await client.userClient.post(url, body: data);
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
    return refreshedToken;
  }
}
