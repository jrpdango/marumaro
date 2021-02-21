import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AddAnimeRequest {
  String animeID;
  String status;
  String score;
  String episodesWatched;

  AddAnimeRequest(
      {this.animeID,
      this.status,
      this.score = "0",
      this.episodesWatched = "0"});

  Future<void> createRequest(MALClient client) async {
    Response response = await client.userClient
        .post("https://myanimelist.net/ownlist/anime/add.json",
            body: json.encode({
              "anime_id": this.animeID,
              "status": this.status,
              "score": this.score,
              "num_watched_episodes": this.episodesWatched,
              // "csrf_token": client.csrfToken,
            }));
    print(response.headers["set-cookie"]);
  }
}
