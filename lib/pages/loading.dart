import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setupMALConnection() async {
    Directory directory = await getApplicationDocumentsDirectory();

    //TODO: Check if token is written on file
    if (File("${directory.path}/miruTokens.json").existsSync()) {
      // check if file is empty
    } else {}
    /*
    TODO:
      - If yes, check if access token is valid
        - If yes, then use access token ----- end
        - If no, check if refresh token is valid
          - If yes, refresh token, then rewrite file with updated token, then use new access token ----- end
          - If no, generate new token (authenticate), then rewrite file with updated token, then use new access token ----- end
      - If no, generate new token (authenticate) and write to file, then use new access token ----- end
    */
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MALClient client = MALClient();
      String url = client.login();
      dynamic result = await Navigator.pushNamed(context, "/malweb",
          arguments: <String, String>{"url": url});
      Uri params = Uri(query: result["accessCode"]);
      // Access code from URL parameter
      client.accessCode =
          params.queryParameters["http://jpmiru.com/oauth?code"];
      await client.getToken();
      // client.getUserData();
      // Test list update
      await client
          .updateList(UpdateListRequest(animeID: "1", episodesWatched: "1"));
      client.logout();
    });
  }

  Future<bool> haveTokensStored(Directory directory) async {
    return File("${directory.path}/miruTokens.json").existsSync();
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
