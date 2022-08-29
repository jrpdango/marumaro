import 'package:flutter/foundation.dart';
import 'package:miru/models/token.dart';
import 'package:miru/services/token_generate_request.dart';
import 'package:miru/services/token_refresh_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miru/globals.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

class TokenController {
  Future<void> _getTokens() async {
    Globals.client.token = await const TokenGenerateRequest().send();
    debugPrint("DEBUG: Tokens received:");
    debugPrint("Access token: ${Globals.client.token.accessToken}");
    debugPrint("Refresh token: ${Globals.client.token.refreshToken}");
  }

  Future<void> _refreshTokens() async {
    Globals.client.token = await const TokenRefreshRequest().send();
    debugPrint("DEBUG: Tokens refreshed:");
    debugPrint("Access token: ${Globals.client.token.accessToken}");
    debugPrint("Refresh token: ${Globals.client.token.refreshToken}");
  }

  // Method to write tokens to device
  Future<File> _writeTokensToFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruTokens.json");
    String data = json.encode({
      "access_token": Globals.client.token.accessToken,
      "refresh_token": Globals.client.token.refreshToken
    });
    if (file.readAsStringSync().isNotEmpty) {
      await File("${directory.path}/miruTokens.json").delete();
      file = await File("${directory.path}/miruTokens.json").create();
    }
    return await file.writeAsString(data);
  }

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
      debugPrint("Tokens found on file. Assigning to client.");
    } else {
      debugPrint(
          "No valid tokens found on file. Attempting to get new tokens.");
      await oAuthNewTokens();
    }
  }

  Future<bool> checkValidAccessToken() async {
    return (await Globals.client.userDataRequest()).isNotEmpty;
  }

  Future<void> oAuthNewTokens() async {
    await Get.toNamed("/login");
    debugPrint("No valid tokens. Gotta auth and get new ones.");
    String url = Globals.client.generateAuthURL();
    dynamic result = await Get.toNamed(
      "/mal_web_view",
      arguments: <String, String>{
        "url": url,
      },
    );
    Uri params = result["accessCode"];
    // Access code from URL parameter
    Globals.client.accessCode = params.queryParameters["code"]!;
    await _getTokens();
    await _writeTokensToFile();
  }

  Future<void> verifyTokens() async {
    await assignTokenFromFile();
    bool isAccessTokenValid = await checkValidAccessToken();
    if (isAccessTokenValid) {
      // Access token is valid, client can make calls
      debugPrint("Access code in file is valid, ez calls (line 38)");
    } else {
      debugPrint("Access code in file is not valid, gonna refresh (line 41)");
      await _refreshTokens();
      // Attempt to refresh tokens
      if (Globals.client.token.accessToken == "invalid_token") {
        debugPrint(
            "Refresh code in file isn't valid, need to get new tokens (line 45)");
        await oAuthNewTokens();
      } else {
        debugPrint("Refresh code in file is valid, ez refresh (line 61)");
        // Tokens are refreshed, access token is now valid, write to file
        _writeTokensToFile();
      }
    }
  }
}
