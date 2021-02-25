import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/services/update_list_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miru/services/token.dart';
import 'dart:io';
import 'dart:convert';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  MALClient client = MALClient();

  // Temporary, move this to dedicated service later on
  Future<bool> hasValidAccessToken(Token token) async {
    Map checker = await client.getUserData();
    return checker["status_code"] == 200;
  }

  void setupMALConnection() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruTokens.json").existsSync()
        ? File("${directory.path}/miruTokens.json")
        : await File("${directory.path}/miruTokens.json").create();
    dynamic fileContent = file.readAsStringSync().isNotEmpty
        ? json.decode(file.readAsStringSync())
        : file.readAsStringSync();
    if (fileContent.isNotEmpty &&
        fileContent["access_token"] != "invalid_token") {
      // File is not empty or 'invalid_token'. Check if access token is valid
      client.token = Token(
          accessToken: fileContent["access_token"],
          refreshToken: fileContent["refresh_token"]);
      if (await hasValidAccessToken(client.token)) {
        // Access token is valid, client can make calls
        print("Access code in file is valid, ez calls (line 38)");
      } else {
        print("Access code in file is not valid, gonna refresh (line 41)");
        await client.refreshTokens();
        // Attempt to refresh tokens
        if (client.token.accessToken == "invalid_token") {
          print(
              "Refresh code in file isn't valid, need to get new tokens (line 45)");
          // If refresh token is invalid, get new tokens
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            String url = client.getAuthURL();
            dynamic result = await Navigator.pushNamed(context, "/malweb",
                arguments: <String, String>{"url": url});
            Uri params = Uri(query: result["accessCode"]);
            // Access code from URL parameter
            client.accessCode =
                params.queryParameters["http://localhost/oauth?code"];
            await client.getTokens();
            // New tokens written to file, tokens are now valid
            await client.token.writeToFile();
          });
        } else {
          print("Refresh code in file is valid, ez refresh (line 61)");
          // Tokens are refreshed, access token is now valid, write to file
          client.token.writeToFile();
        }
      }
    } else {
      print("No tokens found in file. Gotta auth and get tokens.");
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        String url = client.getAuthURL();
        dynamic result = await Navigator.pushNamed(context, "/malweb",
            arguments: <String, String>{"url": url});
        Uri params = Uri(query: result["accessCode"]);
        // Access code from URL parameter
        client.accessCode =
            params.queryParameters["http://localhost/oauth?code"];
        await client.getTokens();
        await client.token.writeToFile();
      });
    }

    await client
        .updateList(UpdateListRequest(animeID: "42897", episodesWatched: "6"));
    client.logout();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   String url = client.getAuthURL();
    //   dynamic result = await Navigator.pushNamed(context, "/malweb",
    //       arguments: <String, String>{"url": url});
    //   Uri params = Uri(query: result["accessCode"]);
    // Access code from URL parameter
    // client.accessCode =
    //     params.queryParameters["http://localhost/oauth?code"];
    // await client.getTokens();
    // client.getUserData();
    // Test list update
    // await client
    //     .updateList(UpdateListRequest(animeID: "42897", episodesWatched: "5"));
    // client.logout();
    // });
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
