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
}
