import 'package:flutter/foundation.dart' show debugPrint;
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/interfaces/mal_request.dart';
import 'package:miru/services/base_request.dart';

//TODO: Test if new request works
class AnimeDeleteRequest implements MalRequest {
  final int animeID;

  AnimeDeleteRequest({required this.animeID});

  @override
  Future<Map<String, dynamic>> send() async {
    Uri uri = Uri(
        scheme: "https",
        host: "api.myanimelist.net",
        path: "v2/anime/$animeID/my_list_status");

    Map<String, dynamic> response = await BaseRequest(
      uri: uri,
      httpRequestType: MiruHttpRequestType.delete,
    ).send();
    debugPrint('Anime deleted successfully.');
    return response;
  }
}
