import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/token_verifier.dart';
// import 'package:miru/services/anime_list_request.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  MALClient client = MALClient();

  Future<List<dynamic>> getLocalList() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruList.json").existsSync()
        ? File("${directory.path}/miruList.json")
        : await File("${directory.path}/miruList.json").create();
    dynamic animeMap = file.readAsStringSync().isNotEmpty
        ? json.decode(file.readAsStringSync())
        : [];
    print(animeMap.runtimeType);
    return animeMap;
  }

  void setupMALConnection() async {
    await TokenVerifier.verifyTokens(this.client);
    Get.offNamed("/home", arguments: {
      "anime_map": await this.getLocalList(),
      "client": this.client
    });
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
