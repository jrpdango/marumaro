import 'dart:io' show Directory, File;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/utils/global_controller.dart';
import 'package:miru/utils/token_verifier.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/constants.dart' as constants show limitOfListItems;

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  // Initialize controller for access to globals.
  final _controller = Get.put(GlobalController());

  /// Initializes the user's anime list.
  ///
  Future<Map<String, dynamic>> _initializeAnimeList(limit) async {
    Map<String, dynamic> newMap = {};

    final Map<String, dynamic> result =
        await AnimeListRequest(limit: limit).createRequest();

    for (String item in result.keys) {
      if (item != 'paging' && item != 'status_code') {
        _controller.globalAnimeList.addAll(result[item]);
      }
    }

    try {
      while (result['paging']['next'] != null) {
        newMap = await AnimeListRequest(
          limit: limit,
          uri: Uri.parse(result['paging']['next']),
        ).createRequest();

        for (String item in newMap.keys) {
          if (item != 'paging' && item != 'status_code') {
            result[item].addAll(newMap[item]);
            _controller.globalAnimeList.addAll(newMap[item]);
          }
        }

        result['paging']['next'] = newMap['paging']!['next'];
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  /// Verify token validity and initialization of anime list.
  ///
  void _setupMALConnection({required bool deleteTokens}) async {
    if (deleteTokens) _deleteLocalTokens();
    await TokenVerifier().verifyTokens();

    Map<String, dynamic> result =
        await _initializeAnimeList(constants.limitOfListItems);

    _controller.client.clientAnimeList = result.obs;

    _controller.client.username =
        (await _controller.client.userDataRequest())['name'];

    // TODO: Add home page
    // Get.offNamed('/home');
  }

  /// Deletes locally-stored tokens.
  ///
  void _deleteLocalTokens() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File('${directory.path}/miruTokens.json').deleteSync();
  }

  @override
  void initState() {
    super.initState();
    _setupMALConnection(deleteTokens: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: const Center(
          child: SpinKitThreeBounce(
            color: Colors.white60,
          ),
        ),
      ),
    );
  }
}
