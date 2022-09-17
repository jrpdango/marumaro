import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/token_pair.dart';
import 'package:miru/utils/mal_client.dart';

import 'package:miru/constants.dart' as constants;

class TokenGenerateRequest {
  final String? accessCode;

  const TokenGenerateRequest({
    this.accessCode,
  });

  Future<TokenPair> send() async {
    Uri url = Uri.parse(constants.apiTokenUrl);
    Map<String, String> data = {
      'client_id': MALClient.clientId,
      'code': accessCode ?? '',
      'code_verifier': Globals.client.codeChallenge,
      'grant_type': 'authorization_code'
    };
    TokenPair newTokenPair;

    try {
      Response response = await Globals.client.userClient.post(
        url,
        body: data,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = json.decode(response.body);
        newTokenPair = TokenPair(
          accessToken: responseMap['access_token'],
          refreshToken: responseMap['refresh_token'],
        );
        debugPrint('Status Code for token generation: ${response.statusCode}');
        debugPrint(responseMap.toString());
      } else {
        throw Exception(
          'Something went wrong with requesting for token generation: Status ${response.statusCode}',
        );
      }

      return newTokenPair;
    } catch (e) {
      newTokenPair = TokenPair(
        accessToken: 'invalid_token',
        refreshToken: 'invalid_token',
      );

      debugPrint('Something went wrong. $e');
    }

    return newTokenPair;
  }
}
