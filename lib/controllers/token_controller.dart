import 'package:miru/models/token.dart';
import 'package:miru/utils/mal_client.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miru/globals.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

class TokenController {
  Future<void> assignTokenFromFile() async {
    Directory directory = await getApplicationDocumentsDirectory();

    // If a file exists, use it. If it doesn't, create one.
    File file = File("${directory.path}/miruTokens.json").existsSync()
        ? File("${directory.path}/miruTokens.json")
        : await File("${directory.path}/miruTokens.json").create();

    Map<String, dynamic> fileContent = file.readAsStringSync().isNotEmpty
        ? json.decode(file.readAsStringSync())
        : <String, dynamic>{};

    if (fileContent.isNotEmpty &&
        fileContent["access_token"] != "invalid_token") {
      // File is not empty or 'invalid_token'. Check if access token is valid
      Globals.client.token = Token(
        accessToken: fileContent["access_token"],
        refreshToken: fileContent["refresh_token"],
      );
      print("Tokens found on file. Assigning to client.");
    } else {
      print("No valid tokens found on file. Attempting to get new tokens.");
      await oAuthNewTokens();
    }
  }

  Future<bool> checkValidAccessToken() async {
    return (await Globals.client.userDataRequest()).isNotEmpty;
  }

  Future<void> oAuthNewTokens() async {
    await Get.toNamed("/login");
    print("No valid tokens. Gotta auth and get new ones.");
    String url = Globals.client.getAuthURL();
    dynamic result = await Get.toNamed(
      "/mal_web_view",
      arguments: <String, String>{
        "url": url,
      },
    );
    Uri params = result["accessCode"];
    // Access code from URL parameter
    Globals.client.accessCode = params.queryParameters["code"]!;
    await Globals.client.getTokens();
    await Globals.client.writeTokensToFile();
  }

  Future<void> verifyTokens() async {
    await assignTokenFromFile();
    bool isAccessTokenValid = await checkValidAccessToken();
    if (isAccessTokenValid) {
      // Access token is valid, client can make calls
      print("Access code in file is valid, ez calls (line 38)");
    } else {
      print("Access code in file is not valid, gonna refresh (line 41)");
      await Globals.client.refreshTokens();
      // Attempt to refresh tokens
      if (Globals.client.token.accessToken == "invalid_token") {
        print(
            "Refresh code in file isn't valid, need to get new tokens (line 45)");
        await oAuthNewTokens();
      } else {
        print("Refresh code in file is valid, ez refresh (line 61)");
        // Tokens are refreshed, access token is now valid, write to file
        Globals.client.writeTokensToFile();
      }
    }
  }
}
