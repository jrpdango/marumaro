import 'package:flutter/foundation.dart';
import 'package:miru/models/token.dart';
import 'package:miru/services/oauth_request.dart';
import 'package:miru/services/token_generate_request.dart';
import 'package:miru/services/token_refresh_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miru/globals.dart';
import 'dart:io';
import 'dart:convert';

class TokenController {
  String? _accessCode;

  Future<void> _getTokens() async {
    Globals.client.tokenPair =
        await TokenGenerateRequest(accessCode: _accessCode).send();
    debugPrint('DEBUG: Tokens received:');
    debugPrint('Access token: ${Globals.client.tokenPair.accessToken}');
    debugPrint('Refresh token: ${Globals.client.tokenPair.refreshToken}');
  }

  Future<void> _refreshTokens() async {
    Globals.client.tokenPair = await const TokenRefreshRequest().send();
    debugPrint('DEBUG: Tokens refreshed:');
    debugPrint('Access token: ${Globals.client.tokenPair.accessToken}');
    debugPrint('Refresh token: ${Globals.client.tokenPair.refreshToken}');
  }

  // Method to write tokens to device
  Future<File> _writeTokensToFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/miruTokens.json');
    String data = json.encode({
      'access_token': Globals.client.tokenPair.accessToken,
      'refresh_token': Globals.client.tokenPair.refreshToken
    });
    if (file.readAsStringSync().isNotEmpty) {
      await File('${directory.path}/miruTokens.json').delete();
      file = await File('${directory.path}/miruTokens.json').create();
    }
    return await file.writeAsString(data);
  }

  Future<void> assignTokenFromFile() async {
    Directory directory = await getApplicationDocumentsDirectory();

    // If a file exists, use it. If it doesn't, create one.
    File file = File('${directory.path}/miruTokens.json').existsSync()
        ? File('${directory.path}/miruTokens.json')
        : await File('${directory.path}/miruTokens.json').create();

    Map<String, dynamic> fileContent = file.readAsStringSync().isNotEmpty
        ? json.decode(file.readAsStringSync())
        : <String, dynamic>{};

    // Assign locally-stored tokens to client if they exist.
    if (fileContent.isNotEmpty) {
      Globals.client.tokenPair = TokenPair(
        accessToken: fileContent['access_token'],
        refreshToken: fileContent['refresh_token'],
      );
    }
  }

  Future<bool> isValidAccessToken() async {
    return (await Globals.client.userDataRequest()).isNotEmpty;
  }

  Future<void> oAuthNewTokens() async {
    _accessCode = await OAuthRequest().send();
    await _getTokens();
    await _writeTokensToFile();
  }

  Future<void> verifyTokens() async {
    await assignTokenFromFile();
    if (await isValidAccessToken()) {
      // Access token is valid, client can make calls
      debugPrint('Access code in file is valid, assigned to client.');
    } else {
      debugPrint(
          'Access code in file is not valid, attempting to refresh with refresh token.');
      // Attempt to refresh tokens
      await _refreshTokens();
      if (Globals.client.tokenPair.accessToken == 'invalid_token') {
        debugPrint(
            'Refresh code in file isn\'t valid, need to get new token pair.');
        // Request for new tokens as long as the current ones aren't valid
        while (!(await isValidAccessToken())) {
          await oAuthNewTokens();
        }
      } else {
        debugPrint(
            'Refresh code in file is valid, tokens have been refreshed.');
        // Tokens are refreshed, access token is now valid, write to file
        _writeTokensToFile();
      }
    }
  }
}
