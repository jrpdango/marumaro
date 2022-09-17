import 'package:miru/utils/mal_client.dart';

class OAuthURLGenerator {
  final String codeChallenge;

  OAuthURLGenerator({required this.codeChallenge});

  String generate() {
    String url =
        'https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${MALClient.clientId}&code_challenge=$codeChallenge';
    return url;
  }
}
