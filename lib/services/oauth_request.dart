import 'package:miru/utils/mal_client.dart';

class OAuthRequest {
  final String codeChallenge;

  OAuthRequest({required this.codeChallenge});

  // TODO: Put this and other requests in a try-catch
  String createRequest(MALClient client) {
    String url =
        "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=${MALClient.CLIENTID}&code_challenge=$codeChallenge";
    return url;
  }
}
