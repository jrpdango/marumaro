import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';

class UpdateListRequest {
  String animeID;
  String status;
  String score;
  String episodesWatched;

  UpdateListRequest(
      {this.animeID,
      this.status = "watching",
      this.score = "0",
      this.episodesWatched = "0"});

  Future<String> createRequest(MALClient client) async {
    try {
      String url =
          "https://api.myanimelist.net/v2/anime/${this.animeID}/my_list_status";
      Response response = await client.userClient.patch(url, headers: {
        "Authorization": "Bearer ${client.token.accessToken}"
      }, body: {
        "status": this.status,
        "score": this.score,
        "num_watched_episodes": this.episodesWatched
      });
      if (response.statusCode == 200) {
        return "200";
      } else {
        return "List update request sent, but something went wrong. Status code: ${response.statusCode}";
      }
    } catch (exception) {
      return "Oops! Something went wrong. $exception";
    }
  }
}
