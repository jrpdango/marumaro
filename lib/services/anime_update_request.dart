import 'package:flutter/foundation.dart';
import 'package:miru/enums/anime_list_type.dart';
import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/interfaces/mal_request.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/services/base_request.dart';

class AnimeUpdateRequest implements MalRequest {
  final int? animeId;
  final UserListStatus? userListStatus;

  AnimeUpdateRequest({
    this.animeId,
    this.userListStatus,
  });

  @override
  Future<Map<String, dynamic>> send() async {
    if (animeId == null) return {};
    Uri uri = Uri(
      scheme: 'https',
      host: 'api.myanimelist.net',
      path: 'v2/anime/$animeId/my_list_status',
    );
    Map<String, dynamic> response = await BaseRequest(
      uri: uri,
      httpRequestType: MiruHttpRequestType.patch,
      body: {
        'status':
            userListStatus?.status?.apiName ?? AnimeListType.watching.apiName,
        'score': userListStatus?.score ?? 0,
        'num_watched_episodes': userListStatus?.currentProgress ?? 0,
      }.map((key, value) => MapEntry(key, value.toString())),
    ).send();
    debugPrint('List updated successfully!');
    return response;
  }
}
