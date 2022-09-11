import 'dart:io';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/utils/oauth_url_generator.dart';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
// import 'package:miru/services/anime_details_request.dart';
// import 'package:miru/services/anime_list_request.dart';
// import 'package:miru/services/anime_search_request.dart';
// import 'package:miru/services/delete_anime_request.dart';
import 'package:miru/models/token.dart';
// import 'package:miru/services/update_list_request.dart';
import 'package:miru/utils/pkce_code_generator.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:flutter/material.dart' show NetworkImage;

class MALClient {
  static const String clientId = "b6cd1c6e3172ade1142272d4c288bdf2";
  static final HttpClient _httpClient = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  final String codeChallenge = CodeGenerator.genPKCEcode();
  final Client userClient = IOClient(_httpClient);
  TokenPair? tokenPair;
  late RxMap<String, dynamic> clientAnimeList;
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

  // Future<String> updateList(UpdateListRequest updateListRequest) async {
  //   String response = await updateListRequest.createRequest(this);
  //   print(response);
  //   return response;
  // }

  // Future<void> deleteAnime(DeleteAnimeRequest deleteAnimeRequest) async {
  //   String response = await deleteAnimeRequest.createRequest(this);
  //   print(response);
  // }

  Future<Map<String, dynamic>> userDataRequest() {
    return const UserDataRequest(mode: 'MAL').send();
  }

  Future<Map<String, dynamic>> requestAnimeList({
    String? status,
    String? sort,
    int? limit,
    int? offset,
    String? username,
    Uri? uri,
    String? fields,
  }) {
    return AnimeListRequest(
            status: status,
            sort: sort,
            limit: limit,
            offset: offset,
            username: username,
            uri: uri,
            fields: fields)
        .send();
  }

  void logout() {
    userClient.close();
  }
}
