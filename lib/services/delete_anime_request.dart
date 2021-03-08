import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';

class DeleteAnimeRequest {
  String animeID;

  DeleteAnimeRequest({this.animeID = ""});

  Future<String> createRequest(MALClient client) async {
    try {
      String url =
          "https://api.myanimelist.net/v2/anime/${this.animeID}/my_list_status";
      Response response = await client.userClient.delete(url,
          headers: {"Authorization": "Bearer ${client.token.accessToken}"});
      if (response.statusCode == 200) {
        return "Anime deleted successfully!";
      } else if (response.statusCode == 404) {
        return "Anime delete request sent, but it looks like it's not in your list. Status code: ${response.statusCode}";
      } else {
        return "Anime delete request sent, but something went wrong. Status code: ${response.statusCode}";
      }
    } catch (exception) {
      return "Oops! Something went wrong. $exception";
    }
  }
}
