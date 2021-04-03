import 'package:http/http.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/anime_search_request.dart';
import 'package:miru/services/delete_anime_request.dart';
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
      data: [{node: {id, title, main_picture: {medium, large}, num_episodes, mean, status, rank, popularity, source, studios, rating, average_episode_duration, alternative_titles, synopsis, start_date, end_date, genres}, 
      list_status: {status, score, num_episodes_watched, is_rewatching, updated_at}}
      for each anime in the list]
      paging: {next : url to next page}
      status_code: int
    }
    */
    return await animeListRequest.createRequest(this);
  }

  Future<Map> animeSearch(AnimeSearchRequest animeSearchRequest) async {
    return await animeSearchRequest.createRequest(this);
  }

  Future<Map> getAnimeDetails(AnimeDetailsRequest animeDetailsRequest) async {
    return await animeDetailsRequest.createRequest(this);
  }

  Future<void> updateList(UpdateListRequest updateListRequest) async {
    String response = await updateListRequest.createRequest(this);
    print(response);
  }

  Future<void> deleteAnime(DeleteAnimeRequest deleteAnimeRequest) async {
    String response = await deleteAnimeRequest.createRequest(this);
    print(response);
  }

  void logout() {
    this.userClient.close();
  }
}
