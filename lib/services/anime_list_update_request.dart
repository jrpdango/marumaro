import 'package:flutter/foundation.dart';
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/interfaces/mal_request.dart';
import 'package:miru/services/base_request.dart';

class AnimeListUpdateRequest implements MalRequest {
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

  @override
  Future<Map<String, dynamic>> send() async {
    Uri uri = Uri(
      scheme: "https",
      host: "api.myanimelist.net",
      path: "v2/anime/$animeID/my_list_status",
    );
    Map<String, dynamic> response = await BaseRequest(
      uri: uri,
      httpRequestType: MiruHttpRequestType.patch,
      body: {
        "status": status,
        "score": score,
        "num_watched_episodes": episodesWatched,
      },
    ).send();
    debugPrint('List updated successfully!');
    return response;
  }
}
