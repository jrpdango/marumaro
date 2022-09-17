import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/token_pair.dart';
import 'package:miru/utils/mal_client.dart';

import 'package:miru/constants.dart' as constants;

class TokenRefreshRequest {
  const TokenRefreshRequest();

  Future<TokenPair> send() async {
    Uri url = Uri.parse(constants.apiTokenUrl);
    Map<String, String?> data = {
      'client_id': MALClient.clientId,
      'grant_type': 'refresh_token',
      'refresh_token': Globals.client.tokenPair?.refreshToken
    };
    TokenPair refreshedTokenPair;

    try {
      Response response = await Globals.client.userClient.post(
        url,
        body: data,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = json.decode(response.body);
        refreshedTokenPair = TokenPair(
          accessToken: responseMap['access_token'],
          refreshToken: responseMap['refresh_token'],
        );
        debugPrint('Status Code for token refresh: ${response.statusCode}');
        debugPrint(responseMap.toString());
      } else {
        throw Exception(
          'Something went wrong with requesting for a token refresh: Status ${response.statusCode}',
        );
      }

      return refreshedTokenPair;
    } catch (e) {
      refreshedTokenPair = TokenPair(
        accessToken: 'invalid_token',
        refreshToken: 'invalid_token',
      );

      debugPrint('Something went wrong. $e');
    }

    return refreshedTokenPair;
  }
}
