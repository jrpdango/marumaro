import 'dart:io';
import 'dart:convert';
import 'package:miru/services/token_generate_request.dart';
import 'package:path_provider/path_provider.dart';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
// import 'package:miru/services/anime_details_request.dart';
// import 'package:miru/services/anime_list_request.dart';
// import 'package:miru/services/anime_search_request.dart';
// import 'package:miru/services/delete_anime_request.dart';
import 'package:miru/models/token.dart';
// import 'package:miru/services/update_list_request.dart';
import 'package:miru/services/oauth_request.dart';
import 'package:miru/utils/pkce_code_generator.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:flutter/material.dart' show NetworkImage;

class MALClient {
  static const String CLIENTID = "b6cd1c6e3172ade1142272d4c288bdf2";
  final String codeChallenge = CodeGenerator.genPKCEcode();
  late String accessCode;
  final HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  late Client userClient = IOClient(httpClient);
  late Token token;
  late RxMap<String, dynamic> clientAnimeList;
  String? username;
  NetworkImage? userImage;

  String getAuthURL() {
    final OAuthRequest oAuthRequest =
        OAuthRequest(codeChallenge: codeChallenge);
    String url;
    try {
      // Receive URL with PKCE challenge
      url = oAuthRequest.createRequest(this);
    } catch (e) {
      url = "Something happened here";
    }
    return url;
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
    return const UserDataRequest(mode: 'MAL').createRequest();
  }

  void logout() {
    this.userClient.close();
  }
}
