import 'package:miru/pages/home.dart';
import 'package:miru/utils/token_deleter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/globals.dart';
import 'package:miru/utils/token_validator.dart';
import 'package:miru/constants.dart' as constants show limitOfListItems;

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  /// Initializes the user's anime list.
  ///
  Future<Map<String, dynamic>> _initializeAnimeList(limit) async {
    final Map<String, dynamic> result =
        await Globals.client.requestAnimeList(limit: limit);
    return result;
  }

  /// Verify token validity and initialization of anime list.
  ///
  void _setupMALConnection({required bool deleteTokens}) async {
    if (deleteTokens) deleteLocalTokens();
    await TokenValidator.verifyTokenPair();

    Map<String, dynamic> result =
        await _initializeAnimeList(constants.limitOfListItems);

    Globals.client.animeMap = result.obs;

    Globals.client.username = (await Globals.client.userDataRequest())['name'];

    Get.to(() => const Home());
  }

  @override
  void initState() {
    super.initState();
    _setupMALConnection(deleteTokens: false);
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
