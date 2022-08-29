import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/token.dart';
import 'package:miru/utils/mal_client.dart';

import 'package:miru/constants.dart' as constants;

class TokenRefreshRequest {
  const TokenRefreshRequest();

  Future<Token> send() async {
    Uri url = Uri.parse(constants.apiTokenUrl);
    Map<String, String> data = {
      "client_id": MALClient.clientId,
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
    debugPrint("Status Code for token refresh: ${response.statusCode}");
    debugPrint(responseMap.toString());
    return refreshedToken;
  }
}
