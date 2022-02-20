import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/token_verifier.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:get/get.dart';
// import 'package:miru/widgets/ListContainer.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  MALClient client = MALClient();

  /// Legacy function, saving lists locally probably isn't the best idea for now
  ///
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

  Future<Map> initList() async {
    Map result = await client.getAnimeList(AnimeListRequest(limit: "500"));
    return result;
  }

  Future<bool> testConnection() async {
    return await DataConnectionChecker().hasConnection;
  }

  void setupMALConnection() async {
    /**
     * Uncomment the deleteSync lines to remove locally-stored tokens.
     */
    // Directory directory = await getApplicationDocumentsDirectory();
    // File("${directory.path}/miruList.json").deleteSync();
    // File("${directory.path}/miruTokens.json").deleteSync();
    bool connStatus = await testConnection();
    await TokenVerifier.verifyTokens(this.client);
    Map currentList = await initList();

    Get.off(() => Home(animeMap: currentList, client: this.client),
        arguments: {"connStatus": connStatus});
  }

  @override
  void initState() {
    super.initState();
    setupMALConnection();
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
