import 'package:miru/globals.dart';
import 'package:miru/services/base_get_request.dart';

class UserDataRequest {
  final String mode;
  final bool isFullImage;

  const UserDataRequest({
    required this.mode,
    this.isFullImage = false,
  });

  Future<Map<String, dynamic>> createRequest() async {
    Uri uri;

    if (mode == 'MAL') {
      uri = Uri(
        scheme: "https",
        host: "api.myanimelist.net",
        path: "v2/users/@me",
      );
    } else {
      uri = Uri(
        scheme: "https",
        host: "api.jikan.moe",
        path:
            "v4/users/${Globals.client.username}/${isFullImage ? 'full' : ''}",
      );
    }

    // MAL URL: 'https://api.myanimelist.net/v2/users/@me';
    // JIKAN URL: https://api.jikan.moe/v4/users/{username}/full
    return BaseGetRequest(uri: uri).send();
  }
}
