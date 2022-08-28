import 'package:miru/models/token.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/services/user_data_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';

class TokenVerifier {
  static Future<void> assignTokenFromFile(MALClient client) async {
    Directory directory = await getApplicationDocumentsDirectory();
    // If a file exists, use it. If it doesn't, create one.
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
      print("Tokens found on file. Assigning to client.");
    } else {
      print("No valid tokens found on file. Attempting to get new tokens.");
      await oAuthNewTokens(client);
    }
  }

  static Future<Map> checkValidAccessToken(
      MALClient client, Token token) async {
    Map checker = await (UserDataRequest(mode: 'MAL').createRequest());
    return checker;
  }

  static Future<void> oAuthNewTokens(MALClient client) async {
    await Get.toNamed("/login");
    print("No valid tokens. Gotta auth and get new ones.");
    String url = client.getAuthURL();
    dynamic result = await Get.toNamed(
      "/malweb",
      arguments: <String, String>{
        "url": url,
      },
    );
    Uri params = result["accessCode"];
    // Access code from URL parameter
    client.accessCode = params.queryParameters["code"]!;
    await client.getTokens();
    await client.token.writeToFile();
  }

  static Future<void> verifyTokens(MALClient client) async {
    await assignTokenFromFile(client);
    Map checkResult = await checkValidAccessToken(client, client.token);
    if (checkResult["status_code"] == 200) {
      // Access token is valid, client can make calls
      print("Access code in file is valid, ez calls (line 38)");
    } else if (checkResult["status_code"] == "invalid_code") {
      print(
          "Device is offline. Showing list stored in file. Status code: ${checkResult["status_code"]}");
    } else {
      print("Access code in file is not valid, gonna refresh (line 41)");
      await client.refreshTokens();
      // Attempt to refresh tokens
      if (client.token.accessToken == "invalid_token") {
        print(
            "Refresh code in file isn't valid, need to get new tokens (line 45)");
        await oAuthNewTokens(client);
      } else {
        print("Refresh code in file is valid, ez refresh (line 61)");
        // Tokens are refreshed, access token is now valid, write to file
        client.token.writeToFile();
      }
    }
  }
}
