import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/token_verifier.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:get/get.dart';
import 'package:miru/constants.dart' as Constants show limitOfListItems;
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  MALClient _client;

  // Legacy function, saving lists locally may be a future feature
  //
  // Future<Map> getLocalList() async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   File file = File("${directory.path}/miruList.json").existsSync()
  //       ? File("${directory.path}/miruList.json")
  //       : await File("${directory.path}/miruList.json").create();
  //   dynamic animeMap = file.readAsStringSync().isNotEmpty
  //       ? json.decode(file.readAsStringSync())
  //       : Map();
  //   print(animeMap.runtimeType);
  //   return animeMap;
  // }

  /// Initializes the user's anime list.
  ///
  Future<Map> initializeAnimeList(_limit) async {
    Map newMap = Map();
    Map result = await _client.getAnimeList(
      AnimeListRequest(limit: _limit),
    );
    while (result["paging"]["next"] != null) {
      newMap = await _client.getAnimeList(
        AnimeListRequest(limit: _limit, url: result["paging"]["next"]),
      );
      for (String item in newMap.keys) {
        if (item != "paging" && item != "status_code") {
          result[item].addAll(newMap[item]);
        }
      }
      result["paging"]["next"] = newMap["paging"]["next"];
    }
    return result;
  }

  /// Checks if user has internet connection.
  ///
  Future<bool> testConnection() async {
    return await DataConnectionChecker().hasConnection;
  }

  /// Verify internet connectivity, token validity, and initialization of anime list.
  ///
  void setupMALConnection() async {
    /**
     * Uncomment the deleteSync lines to remove locally-stored tokens.
     */
    // Directory directory = await getApplicationDocumentsDirectory();
    // File("${directory.path}/miruList.json").deleteSync();
    // File("${directory.path}/miruTokens.json").deleteSync();
    bool connStatus = await testConnection();
    await TokenVerifier.verifyTokens(_client);
    Map currentList = await initializeAnimeList(Constants.limitOfListItems);

    Get.off(
      () => Home(animeMap: currentList, client: _client),
      arguments: {"connStatus": connStatus},
    );
  }

  @override
  void initState() {
    super.initState();
    setupMALConnection();
    _client = MALClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.black87,
        ),
      ),
    );
  }
}
