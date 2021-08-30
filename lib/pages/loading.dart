import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/token_verifier.dart';
// import 'package:miru/services/anime_list_request.dart';
import 'package:get/get.dart';
import 'package:miru/widgets/ListContainer.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  MALClient client = MALClient();

  Future<Map> getLocalList() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruList.json").existsSync()
        ? File("${directory.path}/miruList.json")
        : await File("${directory.path}/miruList.json").create();
    dynamic animeMap = file.readAsStringSync().isNotEmpty
        ? json.decode(file.readAsStringSync())
        : Map();
    print(animeMap.runtimeType);
    return animeMap;
  }

  Future<bool> testConnection() async {
    return await DataConnectionChecker().hasConnection;
  }

  void setupMALConnection() async {
    /**
     * Uncomment the deleteSync lines to remove locally-stored list and tokens.
     */
    // Directory directory = await getApplicationDocumentsDirectory();
    // File("${directory.path}/miruList.json").deleteSync();
    // File("${directory.path}/miruTokens.json").deleteSync();
    bool connStatus = await testConnection();
    Map localList = await getLocalList();

    await TokenVerifier.verifyTokens(this.client);
    Get.off(() => Home(animeMap: localList, client: this.client),
        arguments: {"connStatus": connStatus});
  }

  Future<List<ListContainer>> getTabContents() async {
    Map animeMap = await getLocalList();
    bool connStatus = await testConnection();
    List<String> tabNames = [
      "watching",
      "plan_to_watch",
      "completed",
      "on_hold",
      "dropped"
    ];
    List<ListContainer> tabContents = [];
    for (String tabName in tabNames) {
      tabContents.add(ListContainer(
        animeList: animeMap[tabName],
        client: this.client,
        listType: tabName,
        connStatus: connStatus,
      ));
    }
    return tabContents;
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
