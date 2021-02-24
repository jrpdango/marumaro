import 'dart:io';
import 'package:miru/services/mal_client.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Token {
  String accessToken;
  String refreshToken;

  Token({this.accessToken, this.refreshToken});

  Future<bool> isValid() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    File file = File("${appDir.path}/miruTokens.json").existsSync()
        ? File("${appDir.path}/miruTokens.json")
        : File("${appDir.path}/miruTokens.json").create();
  }
  //TODO: method to write tokens to device

}
