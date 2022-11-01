import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/models/anime.dart';
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
  /// Verify token validity and initialization of anime list.
  ///
  void _setupMALConnection({required bool deleteTokens}) async {
    if (deleteTokens) deleteLocalTokens();
    await TokenValidator.verifyTokenPair();

    final Map<AnimeListType, List<Anime>> result = await Globals.client
        .requestAnimeList(limit: constants.limitOfListItems);

    Globals.client.animeMap = result;

    Globals.client.username = (await Globals.client.requestUserData())['name'];

    Get.off(() => const Home());
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
