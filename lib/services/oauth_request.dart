import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'package:miru/services/token.dart';
import 'dart:convert';

class LoginRequest {
  String codeChallenge;

  LoginRequest({this.codeChallenge});

  String createRequest(MALClient client) {
    String url =
        "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${MALClient.CLIENTID}&code_challenge=$codeChallenge";
    return url;
  }

  Future<Token> generateToken(MALClient client, String code) async {
    String url = "https://myanimelist.net/v1/oauth2/token";
    Map<String, String> data = {
      "client_id": MALClient.CLIENTID,
      "code": code,
      "code_verifier": this.codeChallenge,
      "grant_type": "authorization_code"
    };
    Response response = await client.userClient.post(url, body: data);
    Map responseMap = json.decode(response.body);
    Token token = Token(
        accessToken: responseMap["access_token"],
        refreshToken: responseMap["refresh_token"]);
    print("Status Code for token generation: ${response.statusCode}");
    print(responseMap);
    return token;
  }

  Future<void> refreshToken(MALClient client, Token token) async {
    String url = "https://myanimelist.net/v1/oauth2/token";
    Map<String, String> data = {
      "client_id": MALClient.CLIENTID,
      "grant_type": "refresh_token",
      "refresh_token": token.refreshToken
    };
    Response response = await client.userClient.post(url, body: data);
    Map responseMap = json.decode(response.body);
    Token refreshedToken = Token(
        accessToken: responseMap["access_token"],
        refreshToken: responseMap["refresh_token"]);
    print("Status Code for token refresh: ${response.statusCode}");
    print(responseMap);
    return refreshedToken;
  }
}
