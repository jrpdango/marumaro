import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/models/token.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:miru/services/oauth_request.dart';
import 'package:miru/services/pkce_code_gen.dart';
import 'package:miru/services/user_data_request.dart';

class MALClient {
  static const String CLIENTID = "b6cd1c6e3172ade1142272d4c288bdf2";
  late String accessCode;
  late Client userClient = Client();
  final OAuthRequest oAuthRequest =
      OAuthRequest(codeVerifier: CodeGenerator.genCodeVerifier());
  late Token token;
  late RxMap<String, dynamic> clientAnimeList;
  String? username;

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
  }

  Future<void> refreshTokens() async {
    this.token = await oAuthRequest.refreshTokens(this, this.token);
  }

  Future<Map> getUserData(UserDataRequest userDataRequest) async {
    return await userDataRequest.createRequest(this);
  }

  Future<Map<String, dynamic>> getAnimeList(
      AnimeListRequest animeListRequest) async {
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

    /*
    New:
    {
      <all statuses (watching...plan to watch)>: [list of Anime],
      paging: {next: url to next page},
      status_code: int
    }
     */
    return await animeListRequest.createRequest(this);
  }

  Future<Map<String, dynamic>> getAnimeDetails(
      AnimeDetailsRequest animeDetailsRequest) async {
    return await animeDetailsRequest.createRequest(this);
  }

  Future<String> updateList(UpdateListRequest updateListRequest) async {
    String response = await updateListRequest.createRequest(this);
    print(response);
    return response;
  }

  void logout() {
    this.userClient.close();
  }
}
