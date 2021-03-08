import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Token {
  String accessToken;
  String refreshToken;

  Token({this.accessToken, this.refreshToken});

  // Method to write tokens to device
  Future<File> writeToFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruTokens.json");
    String data = json.encode(
        {"access_token": this.accessToken, "refresh_token": this.refreshToken});
    if (file.readAsStringSync().isNotEmpty) {
      await File("${directory.path}/miruTokens.json").delete();
      file = await File("${directory.path}/miruTokens.json").create();
    }
    return await file.writeAsString(data);
  }
}
