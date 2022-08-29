import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/token.dart';
import 'package:miru/utils/mal_client.dart';

import 'package:miru/constants.dart' as constants;

class TokenGenerateRequest {
  final String? accessCode;

  const TokenGenerateRequest({
    this.accessCode,
  });

  Future<Token> send() async {
    Uri url = Uri.parse(constants.apiTokenUrl);
    Map<String, String> data = {
      "client_id": MALClient.clientId,
      "code": accessCode ?? '',
      "code_verifier": Globals.client.codeChallenge,
      "grant_type": "authorization_code"
    };
    Response response = await Globals.client.userClient.post(url, body: data);
    Map responseMap = json.decode(response.body);
    Token token = Token(
        accessToken: responseMap["access_token"],
        refreshToken: responseMap["refresh_token"]);
    debugPrint("Status Code for token generation: ${response.statusCode}");
    debugPrint(responseMap.toString());
    return token;
  }
}
