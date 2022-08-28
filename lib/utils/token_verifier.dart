import 'package:miru/models/token.dart';
import 'package:miru/utils/mal_client.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miru/utils/global_controller.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

class TokenVerifier {
  final _client = Get.put(GlobalController()).client;

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
      _client.token = Token(
        accessToken: fileContent["access_token"],
        refreshToken: fileContent["refresh_token"],
      );
      print("Tokens found on file. Assigning to client.");
    } else {
      print("No valid tokens found on file. Attempting to get new tokens.");
      await oAuthNewTokens();
    }
  }

  Future<Map> checkValidAccessToken(MALClient client, Token token) async {
    Map checker = await (UserDataRequest(mode: 'MAL').createRequest());
    return checker;
  }

  Future<void> oAuthNewTokens() async {
    await Get.toNamed("/login");
    print("No valid tokens. Gotta auth and get new ones.");
    String url = _client.getAuthURL();
    dynamic result = await Get.toNamed(
      "/mal_web_view",
      arguments: <String, String>{
        "url": url,
      },
    );
    Uri params = result["accessCode"];
    // Access code from URL parameter
    _client.accessCode = params.queryParameters["code"]!;
    await _client.getTokens();
    await _client.writeTokensToFile();
  }

  Future<void> verifyTokens() async {
    await assignTokenFromFile();
    Map checkResult = await checkValidAccessToken(_client, _client.token);
    if (checkResult["status_code"] == 200) {
      // Access token is valid, client can make calls
      print("Access code in file is valid, ez calls (line 38)");
    } else if (checkResult["status_code"] == "invalid_code") {
      print(
          "Device is offline. Showing list stored in file. Status code: ${checkResult["status_code"]}");
    } else {
      print("Access code in file is not valid, gonna refresh (line 41)");
      await _client.refreshTokens();
      // Attempt to refresh tokens
      if (_client.token.accessToken == "invalid_token") {
        print(
            "Refresh code in file isn't valid, need to get new tokens (line 45)");
        await oAuthNewTokens();
      } else {
        print("Refresh code in file is valid, ez refresh (line 61)");
        // Tokens are refreshed, access token is now valid, write to file
        _client.writeTokensToFile();
      }
    }
  }
}
