import 'package:miru/enums/miru_http_request_type.dart';
import 'package:miru/globals.dart';
import 'package:miru/interfaces/mal_request.dart';
import 'package:miru/services/base_request.dart';

class UserDataRequest implements MalRequest {
  final String mode;
  final bool? isFullImage;

  const UserDataRequest({
    required this.mode,
    this.isFullImage,
  });

  @override
  Future<Map<String, dynamic>> send() async {
    Uri uri;

    if (mode == 'MAL') {
      uri = Uri(
        scheme: 'https',
        host: 'api.myanimelist.net',
        path: 'v2/users/@me',
      );
    } else {
      uri = Uri(
        scheme: 'https',
        host: 'api.jikan.moe',
        path:
            'v4/users/${Globals.client.username}/${(isFullImage ?? false) ? 'full' : ''}',
      );
    }

    // MAL URL: 'https://api.myanimelist.net/v2/users/@me';
    // JIKAN URL: https://api.jikan.moe/v4/users/{username}/full
    return BaseRequest(
      uri: uri,
      httpRequestType: MiruHttpRequestType.get,
    ).send();
  }
}
