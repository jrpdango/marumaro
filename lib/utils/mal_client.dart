import 'dart:io';
import 'dart:convert';
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
  final String clientId = "b6cd1c6e3172ade1142272d4c288bdf2";
  // TODO: Probably move assigning of AccessCode
  // AccessCode received from oAuthNewTokens method in token_controller
  late String accessCode;
  final HttpClient httpClient = new HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  late Client userClient = IOClient(httpClient);
  final OAuthRequest oAuthRequest =
      OAuthRequest(codeChallenge: CodeGenerator.genPKCEcode());
  late Token token;
  late RxMap<String, dynamic> clientAnimeList;
  String? username;
  NetworkImage? userImage;

  String getAuthURL() {
    String url;
    try {
      // Receive URL with PKCE challenge
      url = oAuthRequest.createRequest();
    } catch (e) {
      url = "Something happened here";
    }
    return url;
  }

  // TODO - maybe replace checkValidAccessToken in token_verifier
  // Future<bool> hasValidAccessToken() async {
  //   Map checker = await this.getUserData();
  //   if (checker["status_code"] == 200) return true;
  //   return false;
  // }

  Future<void> refreshTokens() async {
    token = await oAuthRequest.refreshTokens(token);
    print("DEBUG: Tokens refreshed:");
    print("Access token: ${token.accessToken}");
    print("Refresh token: ${token.refreshToken}");
  }

  // Method to write tokens to device
  Future<File> writeTokensToFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruTokens.json");
    String data = json.encode({
      "access_token": token.accessToken,
      "refresh_token": token.refreshToken
    });
    if (file.readAsStringSync().isNotEmpty) {
      await File("${directory.path}/miruTokens.json").delete();
      file = await File("${directory.path}/miruTokens.json").create();
    }
    return await file.writeAsString(data);
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
