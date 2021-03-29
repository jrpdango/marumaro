import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AnimeListRequest {
  String username;
  String status;
  String sort;
  String limit;
  String offset;

  AnimeListRequest(
      {this.status, this.sort, this.limit, this.offset, this.username = "@me"});

  void setParams() {
    this.status = this.status == null ? "" : "&status=${this.status}";
    this.sort = this.sort == null ? "" : "&sort=${this.sort}";
    this.limit = this.limit == null ? "" : "&limit=${this.limit}";
    this.offset = this.offset == null ? "" : "&offset=${this.offset}";
  }

  static Future<File> writeToFile(Map listInfo) async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/miruList.json").existsSync()
        ? File("${directory.path}/miruList.json")
        : await File("${directory.path}/miruList.json").create();
    String data = json.encode(listInfo["data"]);
    if (file.readAsStringSync().isNotEmpty) {
      await File("${directory.path}/miruList.json").delete();
      file = await File("${directory.path}/miruList.json").create();
    }
    return await file.writeAsString(data);
  }

  Future<Map> createRequest(MALClient client) async {
    this.setParams();
    try {
      String url =
          "https://api.myanimelist.net/v2/users/${this.username}/animelist?fields=list_status,num_episodes,status" +
              this.status +
              this.sort +
              this.limit +
              this.offset;
      Response response = await client.userClient.get(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      Map respMap = Map();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("List retrieved successfully!");
        writeToFile(respMap);
        respMap["status_code"] = 200;
      } else {
        print(
            "List retrieval request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      return Map();
    }
  }
}
