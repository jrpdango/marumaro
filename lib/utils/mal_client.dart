import 'dart:io';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/anime_update_request.dart';
import 'package:miru/utils/oauth_url_generator.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
// import 'package:miru/services/anime_details_request.dart';
// import 'package:miru/services/anime_list_request.dart';
// import 'package:miru/services/anime_search_request.dart';
// import 'package:miru/services/delete_anime_request.dart';
import 'package:miru/models/token_pair.dart';
import 'package:miru/utils/pkce_code_generator.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:flutter/material.dart' show NetworkImage;

class MALClient {
  static const String clientId = 'b6cd1c6e3172ade1142272d4c288bdf2';
  static final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  final String codeChallenge = CodeGenerator.genPKCEcode();
  final Client userClient = IOClient(_httpClient);
  TokenPair? tokenPair;
  String? username;
  NetworkImage? userImage;

  String generateAuthURL() {
    final OAuthURLGenerator oAuthURLGenerator =
        OAuthURLGenerator(codeChallenge: codeChallenge);
    // Return URL with PKCE challenge
    return oAuthURLGenerator.generate();
  }

  // Future<Map> animeSearch(AnimeSearchRequest animeSearchRequest) async {
  //   return await animeSearchRequest.createRequest(this);
  // }

  // Future<Map<String, dynamic>> getAnimeDetails(
  //     AnimeDetailsRequest animeDetailsRequest) async {
  //   return await animeDetailsRequest.createRequest(this);
  // }

  Future<Map<String, dynamic>> updateAnimeList({
    int? animeId,
    UserListStatus? userListStatus,
  }) async {
    return await AnimeUpdateRequest(
      animeId: animeId,
      userListStatus: userListStatus,
    ).send();
  }

  // Future<void> deleteAnime(DeleteAnimeRequest deleteAnimeRequest) async {
  //   String response = await deleteAnimeRequest.createRequest(this);
  //   print(response);
  // }

  Future<Map<String, dynamic>> requestUserData({
    String mode = 'MAL',
    bool? isFullImage,
  }) {
    return UserDataRequest(mode: mode, isFullImage: isFullImage).send();
  }

  Future<Map<AnimeListType, List<Anime>>> requestAnimeList({
    String? status,
    String? sort = 'list_updated_at',
    int? limit = 100,
    int? offset,
    String? username = '@me',
    Uri? uri,
    String? fields =
        'list_status,num_episodes,start_season,mean,status,rank,popularity,source,'
            'studios,rating,average_episode_duration,alternative_titles,'
            'synopsis,start_date,end_date,genres,num_list_users,num_scoring_users',
  }) {
    return AnimeListRequest(
      status: status,
      sort: sort,
      limit: limit,
      offset: offset,
      username: username,
      uri: uri,
      fields: fields,
    ).send();
  }

  void logout() {
    userClient.close();
  }
}
