import 'package:http/http.dart';
import 'package:miru/globals.dart';

class AnimeListUpdateRequest {
  final int animeID;
  final String status;
  final String score;
  final String episodesWatched;

  AnimeListUpdateRequest({
    required this.animeID,
    this.status = "watching",
    this.score = "0",
    this.episodesWatched = "0",
  });

  Future<String> send() async {
    try {
      Uri url = Uri(
          scheme: "https",
          host: "api.myanimelist.net",
          path: "v2/anime/$animeID/my_list_status");
      Response response = await Globals.client.userClient.patch(url, headers: {
        "Authorization": "Bearer ${Globals.client.tokenPair?.accessToken}"
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
