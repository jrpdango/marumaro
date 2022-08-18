import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/services/token_verifier.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:miru/constants.dart' as Constants show limitOfListItems;

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  // Initialize controller for access to globals.
  final _controller = Get.put(GlobalController());

  /// Initializes the user's anime list.
  ///
  Future<Map<String, dynamic>> initializeAnimeList(_limit) async {
    Map<String, dynamic> newMap = Map();
    final Map<String, dynamic> result =
        await AnimeListRequest(limit: _limit).createRequest();
    for (String item in result.keys) {
      if (item != "paging" && item != "status_code") {
        _controller.globalAnimeList.addAll(result[item]);
      }
    }
    try {
      while (result["paging"]["next"] != null) {
        newMap = await AnimeListRequest(
          limit: _limit,
          uri: Uri.parse(result["paging"]["next"]),
        ).createRequest();
        for (String item in newMap.keys) {
          if (item != "paging" && item != "status_code") {
            result[item].addAll(newMap[item]);
            _controller.globalAnimeList.addAll(newMap[item]);
          }
        }
        result["paging"]["next"] = newMap["paging"]!["next"];
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  /// Verify token validity and initialization of anime list.
  ///
  void setupMALConnection() async {
    /**
     * Uncomment the deleteSync lines to remove locally-stored tokens.
     */
    // Directory directory = await getApplicationDocumentsDirectory();
    // File("${directory.path}/miruList.json").deleteSync();
    // File("${directory.path}/miruTokens.json").deleteSync();

    await TokenVerifier.verifyTokens(_controller.client);
    Map<String, dynamic> result =
        await initializeAnimeList(Constants.limitOfListItems);
    _controller.client.clientAnimeList = result.obs;
    _controller.client.username = (await _controller.client
        .getUserData(UserDataRequest(mode: 'MAL')))['name'];

    Get.offNamed('/home');
  }

  @override
  void initState() {
    super.initState();
    setupMALConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Center(
          child: SpinKitThreeBounce(
            color: Colors.white60,
          ),
        ),
      ),
    );
  }
}
