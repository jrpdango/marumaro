import 'package:miru/models/mal_client.dart';
import 'package:http/http.dart';

class UpdateListRequest {
  final int animeID;
  final String status;
  final String score;
  final String episodesWatched;

  UpdateListRequest({
    required this.animeID,
    this.status = "watching",
    this.score = "0",
    this.episodesWatched = "0",
  });

  Future<String> createRequest(MALClient client) async {
    try {
      Uri url = Uri(
          scheme: "https",
          host: "api.myanimelist.net",
          path: "v2/anime/${this.animeID}/my_list_status");
      // String url =
      //     "https://api.myanimelist.net/v2/anime/${this.animeID}/my_list_status";
      Response response = await client.userClient.patch(url, headers: {
        "Authorization": "Bearer ${client.accessToken}"
      }, body: {
        "status": status,
        "score": score,
        "num_watched_episodes": episodesWatched
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
