import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/services/token_verifier.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:get/get.dart';
import 'package:miru/constants.dart' as Constants show limitOfListItems;
import 'package:miru/services/user_data_request.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  // late MALClient _client = MALClient();
  final _controller = Get.put(GlobalController());
  late MALClient _client = _controller.client.value;
  late RxList<Anime> _globalAnimeList = _controller.globalAnimeList;

  /// Initializes the user's anime list.
  ///
  Future<Map<String, dynamic>> initializeAnimeList(_limit) async {
    Map<String, dynamic> newMap = Map();
    final Map<String, dynamic> result = await _client.getAnimeList(
      AnimeListRequest(limit: _limit),
    );
    for (String item in result.keys) {
      if (item != "paging" && item != "status_code") {
        _globalAnimeList.addAll(result[item]);
      }
    }
    try {
      while (result["paging"]["next"] != null) {
        newMap = await _client.getAnimeList(
          AnimeListRequest(
            limit: _limit,
            url: Uri.parse(result["paging"]["next"]),
          ),
        );
        for (String item in newMap.keys) {
          if (item != "paging" && item != "status_code") {
            result[item].addAll(newMap[item]);
            _globalAnimeList.addAll(newMap[item]);
          }
        }
        result["paging"]["next"] = newMap["paging"]!["next"];
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  /// Verify internet connectivity, token validity, and initialization of anime list.
  ///
  void setupMALConnection() async {
    await TokenVerifier.verifyTokens(_client);
    Map<String, dynamic> result =
        await initializeAnimeList(Constants.limitOfListItems);
    _client.clientAnimeList = result.obs;
    _client.username =
        (await _client.getUserData(UserDataRequest(mode: 'MAL')))['name'];

    Get.off(
      () => Home(),
      // TODO: EDIT LATER
      arguments: {"connStatus": true},
    );
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
