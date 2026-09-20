import 'package:http/http.dart';
import 'package:miru/services/anime_details_request.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/auth_repository.dart';
import 'package:miru/services/token_store.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:miru/services/user_data_request.dart';

class MALClient {
  late Client userClient = Client();
  late final AuthRepository auth = AuthRepository(
    httpClient: userClient,
    tokenStore: TokenStore(),
  );
  String? username;

  String? get accessToken => auth.accessToken;

  Future<Map> getUserData(UserDataRequest userDataRequest) async {
    return await userDataRequest.createRequest(this);
  }

  Future<Map<String, dynamic>> getAnimeList(
      AnimeListRequest animeListRequest) async {
    return await animeListRequest.createRequest(this);
  }

  Future<Map<String, dynamic>> getAnimeDetails(
      AnimeDetailsRequest animeDetailsRequest) async {
    return await animeDetailsRequest.createRequest(this);
  }

  Future<String> updateList(UpdateListRequest updateListRequest) async {
    return await updateListRequest.createRequest(this);
  }

  Future<void> logout() async {
    await auth.signOut();
    userClient.close();
  }
}
