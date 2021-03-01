import 'package:http/http.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/token.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:miru/services/oauth_request.dart';
import 'package:miru/services/pkce_code_gen.dart';
import 'package:miru/services/user_data_request.dart';

class MALClient {
  static const String CLIENTID = "b6cd1c6e3172ade1142272d4c288bdf2";
  String accessCode;
  Client userClient = Client();
  OAuthRequest oAuthRequest =
      OAuthRequest(codeChallenge: CodeGenerator.genPKCEcode());
  Token token;

  String getAuthURL() {
    String url;
    try {
      // Receive URL with PKCE challenge
      url = oAuthRequest.createRequest(this);
    } catch (e) {
      url = "Something happened here";
    }
    return url;
  }

  Future<void> getTokens() async {
    this.token = await oAuthRequest.generateTokens(this, this.accessCode);
    print("DEBUG: Tokens received:");
    print("Access token: ${this.token.accessToken}");
    print("Refresh token: ${this.token.refreshToken}");
  }

  Future<void> refreshTokens() async {
    this.token = await oAuthRequest.refreshTokens(this, this.token);
    print("DEBUG: Tokens refreshed:");
    print("Access token: ${this.token.accessToken}");
    print("Refresh token: ${this.token.refreshToken}");
  }

  Future<Map> getUserData() async {
    return UserDataRequest.createRequest(this);
  }

  Future<Map> getAnimeList(AnimeListRequest animeListRequest) async {
    /*
    Returns:
    {
      data: [{node: {id, title, main_picture: {medium, large}}, 
      list_status: {status, score, num_episodes_watched, is_rewatching, updated_at}}
      for each anime in the list]
      paging: {url to next page}
      status_code: int
    }
    */
    return await animeListRequest.createRequest(this);
  }

  Future<void> updateList(UpdateListRequest updateListRequest) async {
    String response = await updateListRequest.createRequest(this);
    print(response);
  }

  void logout() {
    this.userClient.close();
  }
}
