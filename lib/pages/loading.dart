import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/token_verifier.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:get/get.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  MALClient client = MALClient();

  Future<List<Map>> testFunc() async {
    List<Map> animeList = List();
    Map response = await client.getAnimeList(AnimeListRequest());
    response["data"].forEach((element) {
      animeList.add(element);
    });
    print(response);
    return animeList;
  }

  void setupMALConnection() async {
    await TokenVerifier.verifyTokens(this.client);
    Get.offNamed("/home", arguments: {"animeList": await this.testFunc()});
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
