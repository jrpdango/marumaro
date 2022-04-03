import 'package:miru/models/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AnimeDetailsRequest {
  final int animeID;
  final String? fields;

  AnimeDetailsRequest({
    required this.animeID,
    this.fields,
  });

  Uri setParams(Uri url) {
    if (fields != null) {
      url = url.replace(queryParameters: {
        "fields": fields!,
      });
    } else {
      url = url.replace(queryParameters: {
        "fields":
            "title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,pictures,background,related_anime,related_manga,recommendations,studios,statistics",
      });
    }
    return url;
  }

  Future<Map<String, dynamic>> createRequest(MALClient client) async {
    try {
      Uri url = Uri(
        scheme: "https",
        host: "api.myanimelist.net",
        path: "v2/anime/${this.animeID}",
      );
      url = setParams(url);
      //"https://api.myanimelist.net/v2/anime/${this.animeID}" + this.fields;
      Response response = await client.userClient.get(
        url,
        headers: {"Authorization": "Bearer ${client.token.accessToken}"},
      );
      Map<String, dynamic> respMap = Map<String, dynamic>();
      respMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("Anime details retrieved successfully!");
        respMap["status_code"] = 200;
      } else {
        print(
            "Anime details request sent, but something went wrong. Status code: ${response.statusCode}");
        respMap["status_code"] = [response.statusCode];
      }
      // TODO
      // return AnimeDetails(
      //     url: Uri.parse(respMap["data"]["url"]),
      //     mediumImageUrl:
      //         Uri.parse(respMap["data"]["images"]["jpg"]["image_url"]),
      //     largeImageUrl:
      //         Uri.parse(respMap["data"]["images"]["jpg"]["large_image_url"]),
      //     title: respMap["data"]["title"],
      //     englishTitle: respMap["data"]["title_english"],
      //     japaneseTitle: respMap["data"]["title_japanese"],
      //     titleSynonyms: respMap["data"]["title_synonyms"],
      //     type: respMap["data"]["type"],
      //     source: respMap["data"]["source"],
      //     totalEpisodes: respMap["data"]["episodes"],
      //     showStatus: respMap["data"]["status"],
      //     airedFromTo: respMap["data"]["aired"]["string"],
      //     episodeDuration: respMap["data"]["duration"],
      //     rating: respMap["data"]["rating"],
      //     meanScore: respMap["data"]["score"],
      //     scoredBy: respMap["data"]["scored_by"],
      //     rank: respMap["data"]["rank"],
      //     popularity: respMap["data"]["popularity"],
      //     members: respMap["data"]["members"],
      //     favorites: respMap["data"]["favorites"],
      //     synopsis: respMap["data"]["synopsis"],
      //     season: respMap["data"]["season"],
      //     year: respMap["data"]["year"],
      //     producers: respMap["data"]["producers"]);
      return respMap;
    } catch (exception) {
      print("Oops! Something went wrong. $exception");
      // print(client.token.accessToken);
      return Map<String, dynamic>();
    }
  }
}
